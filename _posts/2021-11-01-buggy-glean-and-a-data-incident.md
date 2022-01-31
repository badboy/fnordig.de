---
permalink: "/{{ year }}/{{ month }}/{{ day }}/crashes-and-a-buggy-glean"
title: "This Week in Glean: Crashes & a buggy Glean"
published_date: "2021-11-01 15:00:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
excerpt: |
  Shortly after we shipped Glean through GeckoView in a Fenix Nightly release
  we received a crash report pointing to code that we haven't touched in a long time.
  And yet the change of switching from a standalone Glean library
  to shipping Glean in GeckoView uncovered a crashing bug, that quickly rose to be the top crasher for Fenix for more than a week.
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog][datablog].

[datablog]: https://blog.mozilla.org/data/2021/11/01/this-week-in-glean-crashes-a-buggy-glean

---

In September I finally [landed work to ship Glean through GeckoView][geckoview-shipped].
Contrary to what that post said Fenix did not actually _use_ Glean coming from GeckoView immediately due to another bug that took us [another few days][ac-shipping-glean] to land.
Shortly after that was shipped in a Fenix Nightly release we received a crash report ([bug 1733757][bug]) pointing to code that we haven't touched in a long time.
And yet the change of switching from a standalone Glean library to shipping Glean in GeckoView uncovered a crashing bug, that quickly rose to be the top crasher for Fenix for more than a week.

When I picked up that bug after the weekend I was still thinking that this would be _just_ a bug, which we can identify & fix and then get into the next Fenix release.
But in data land nothing is ever _just_ a bug.

As I don't own an Android device myself I was initially restricted to the Android emulator,
but I was unsuccessful in triggering that bug in my simple use of Fenix or in any tests I wrote.
At some point I went as far as [leveraging physical devices in the Firebase test lab][phys-devices],
still with no success of hitting the bug.
Later that week I picked up an Android test device, hoping to find easy steps to reproduce the crash.
Thankfully we also have quality assurance people running tests and simply _using_ the browser
and reporting back steps to reproduce bugs and crashes.
And so that's what one of them, Delia, did: [Providing simple steps to reproduce the crash][str].
Simple here meant: open a website and leave the phone untouched for roughly 8-9 minutes.
With those steps I was able to reproduce the crash in both the emulator and my test device as well.

As I was waiting for the crash to occur I started reading the code again.
From the crash report I already knew the [exact place where the code panics][ffi-support-panic] and thus crashes the application,
I just didn't know how it got there.
While reading the code around the panic and the knowledge that it takes several minutes to get to the panic I finally stumbled upon a clue:
The map implementation that was used internally has [a maximum capacity of elements it can store][ffi-support-maxcap].
It even documents that it will panic[^1]!

```rust
/// The maximum capacity of a [`HandleMap`]. Attempting to instantiate one with
/// a larger capacity will cause a panic.
///
/// [...]
pub const MAX_CAPACITY: usize = (1 << 15) - 1;
```

I now knew that at some point Glean exhausts the map capacity,
slowly but eventually leading to a panic[^2].
Most of Glean is set up to not require dynamically allocating new things other than the data itself,
but we never store the data itself within such a map.
So where are we using a map and dynamically add new entries to it and potentially forget to remove them after use?

Luckily the stack trace from those crash reports gave me another clue:
All crashes were caused by [labeled counters].
Some instrument-the-code-paths-and-recompile cycles later I was able to pinpoint it to the exact metric that was causing the crash.

With all this information collected I was able to determine that while the panic was happening in a library we use,
the problem was that Glean had the wrong assumptions about how the use of labeled counters in Kotlin maps to objects in a Rust map.
On every subscript access to a labeled counter (`myCounter["label"]`) Glean would create a new object, store it in the map and return a handle to this object.
The solution was to avoid creating new entries in that map on every access from a foreign language and instead cache created objects by a unique identifier
and hand out already-created objects when re-accessed.
This fix [was implemented in a few lines][glean-fix], accompanied by an extensive commit message as well as tests in all of the 3 major foreign-language Glean SDKs.

That fix was released in [Glean v42.0.1][glean-release], and shortly after in Fenix Nightly and Beta.

The bug was fixed and the crash prevented, but that wasn't the end of it.
The code leading to the bug has been in Glean since at least March 2020
and yet we only started seeing crashes with the GeckoView change.
What was happening before? Did we miss these crashes for more than a year or were there simply no crashes?

To get a satisfying answer to these questions I had to retrace the issue in older Glean versions.
I took older versions of Glean & Fenix from just before the GeckoView-Glean changes,
added logging and built myself a Fenix to run in the emulator.
And as quickly as that[^3] `logcat` spit out the following lines repeatedly:

```
E  ffi_support::error: Caught a panic calling rust code: "called `Result::unwrap()` on an `Err` value: \"PoisonError { inner: .. }\""
E  glean_ffi::handlemap_ext: Glean failed (ErrorCode(-1)): called `Result::unwrap()` on an `Err` value: "PoisonError { inner: .. }"
```

No crashes! It panics, but it doesn't crash in old Fenix versions.
So why does it crash in new versions?
It's a combination of things.

First Glean data recording happens in a thread to avoid blocking the main thread.
Right now that thread is handled on the Kotlin side.
A panic in the Rust code base will bubble up the stack and crash the thread, thus poisoning the internal lock of the map,
but it will not abort the whole application by itself.
Subsequent calls will run on a new thread, handled by the Kotlin side.
When using a labeled counter again it will try to acquire the lock,
detect that it is poisoned and panic once more.
That panic is caught by the FFI layer of Glean and turned into a log message.

Second the standalone Glean library is compiled with [`panic=unwind`][panic-method], the default in Rust,
which unwinds the stack on panics.
If not caught the runtime will abort the current thread, writing a panic message to the error output.
`ffi-support` however catches it, logs it and returns without crashing or aborting.
Gecko on the other hand sets [`panic=abort`][gecko-panic].
In this mode a panic will immediately terminate the current process (after writing the crash message to the error output),
without ever trying to unwind the stack, giving no chance for the support library to catch it.
The Gecko crash reporter is able to catch those hard aborts and send them as crash reports.
As Glean is now part of the overall Gecko build all of Gecko's build flags will transitively apply to Glean and its dependencies, too.
So when Glean is shipped as part of GeckoView it runs in `panic=abort` mode, leading to internal panics aborting the whole application.

That behavior by itself is fine: Glean should only panic in exceptional cases and we'd like to know about them.
It's good to know that an application could continue running without Glean working correctly;
we won't be able to record and send telemetry data, but at least we're not interrupting someone using the application.
However unless we engineers run into those bugs and see the log we will not notice them and thus can't fix them.
So ultimately this change in (crashing) behavior is acceptable (and wanted) going forward.

After fixing the initial bug and being able to answer why it only started crashing recently my work was still not done.
We were likely not recording data in exceptional cases for quite some time, which is not acceptable for a telemetry library.
I had to explore our data, estimate how many metrics for how many clients were affected, inform relevant stakeholders and plan further mitigations.
But that part of the investigation is a story for another time.

_This bug investigation had help from a lot of people.
Thanks to Mike Droettboom for coordination,
Marissa Gorlick for pushing me to evaluate the impact on data & reaching the right people,
Travis Long for help with the Glean code & speedy reviews,
Alessio Placitelli for reviews on the Gecko side,
Delia Pop for the initial steps to reproduce the bug
& Christian Sadilek for help on the Android Components & Fenix side._

---

_Footnotes:_

[^1]: Except that it panics at a slightly different place than the explicit check in the code base would suggest.  
[^2]: That meant I could also _tune_ how quickly it crashed. A smaller maximum capacity means its reached more quickly, reducing my bug reproduction time significantly.  
[^3]: No, not after 9 minutes, but in just under 3 minutes after tuning the maximum map capacity, see [^2].

[geckoview-shipped]: /2021/09/17/glean-geckoview/
[phys-devices]: https://fnordig.de/2021/10/14/fenix-physical-device-testing/
[ac-shipping-glean]: https://github.com/mozilla-mobile/android-components/pull/11045
[bug]: https://bugzilla.mozilla.org/show_bug.cgi?id=1733757
[str]: https://github.com/mozilla-mobile/fenix/issues/21767
[ffi-support-panic]: https://github.com/mozilla/ffi-support/blob/0fdc22a8dfe3731be5fd39b311e4e4885219e26c/src/handle_map.rs#L409
[ffi-support-maxcap]: https://github.com/mozilla/ffi-support/blob/0fdc22a8dfe3731be5fd39b311e4e4885219e26c/src/handle_map.rs#L160-L166
[labeled counters]: https://mozilla.github.io/glean/book/reference/metrics/labeled_counters.html
[glean-fix]: https://github.com/mozilla/glean/commit/499309475f4f002bdd6c19db4aa051634760efe1#diff-fe013beaf77cb562dae30dd3e639f386b9c9f01d6bc6800538ccd72eb89ad68cR77-R107
[glean-release]: https://github.com/mozilla/glean/releases/tag/v42.0.1
[panic-method]: https://doc.rust-lang.org/cargo/reference/profiles.html#panic
[gecko-panic]: https://searchfox.org/mozilla-central/rev/a9e0a3f5e5f7cde941d419db967997aaa1f06b0f/Cargo.toml#63
