---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rustc-ios-and-an-m1"
title: "This Week in Glean: rustc, iOS and an M1"
published_date: "2021-04-16 15:00:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog]().

---

Back in February I got an M1 MacBook.
That's Apple's new ARM-based hardware.

I got it with the explicit task to ensure that we are able to develop and build [Glean] on it.
We maintain a [Swift language binding][swift lb], targeting iOS, and that one is used in [Firefox iOS].
Eventually these iOS developers will also have M1-based machines and want to test their code, thus Glean needs to work.

Here's what we need to get to work:

* Compile the Rust portions of Glean natively on an M1 machine
* Build & test the Kotlin & Swift language bindings on an M1 machine, even if non-native (e.g. Rosetta 2 emulation for x86_64)
* Build & test the Swift language bindings natively and in the iPhone simulator on an M1 machine
* Stretch goal: Get iOS projects using Glean running as well

## Rust on an M1

Work on getting Rust compiled on M1 hardware started last year in June already, with the availability of the first developer kits.
See [Rust issue 73908][m1 tracking] for all the work and details.
First and foremost this required a new target: `aarch64-apple-darwin`.
This landed in August and was promoted to Tier 2[^1] with the [December release of Rust 1.49.0][december release].

By the time I got my MacBook compiling Rust code on it was as easy as on an Intel MacBook.
Developers on Intel MacBooks can cross-compile just as easily:

```
rustup target add aarch64-apple-darwin
cargo build --target aarch64-apple-darwin
```

## Glean Python & Kotlin on an M1

Glean Python just ... worked.
We use `cffi` to load the native library into Python.
It gained `aarch64`[^2] macOS support in [v14.4.1][cffi].
My colleague glandium later [contributed support code][arm64-wheels] so we build release wheels for that target too.
So it's both possible to develop & test Glean Python, as well as use it as a dependency without having a full Rust development environment around.

Glean Android is not that straight forward.
Some of our transitive dependencies are based on years-old pre-built binaries of SQLite
and of course there's not much support behind updating those Java libraries.
It's possible. A friend managed to compile and run that library on an M1.
But for Glean development we simply recommend relying on Rosetta 2 (the x86_64 compatibility layer) for now.
It's as easy as:

```
arch -x86_64 $SHELL
make build-kotlin
```

At least if you have Java set up correctly...
The default Android emulator isn't usable on M1 hardware yet, but Google is working on a compatible one: [Android M1 emulator preview][android-emulator].
It's usable enough for some testing, but for that part I most often switch back to my Linux Desktop (that has the additional CPU power on top).

## Glean iOS on an M1

Now we're getting to the interesting part: Native iOS development on an M1.
Obviously for Apple this is a priority:
Their new machines should become the main machine people do iOS development on.
Thus Xcode gained `aarch64` support in version 12 long before the hardware was available.
That caused quite some issues with existing tooling, such as the [dependency manager Carthage][carthage silicon issue].
Here's the issue:

* When compiling for iOS hardware you would pick a target named `aarch64-apple-ios`,
  because ... iPhones and iPads are ARM-based since forever.
* When compiling for the iOS simulator you would pick a target named `x86_64-apple-ios`,
  because conveniently the simulator uses the host's CPU (that's what makes it fast)

So when the compiler saw `x86_64` and `iOS` it knew "Ah, simulator target"
and when it saw `aarch64` and `ios` it knew "Ah, hardware".
And everyone went with this, Xcode happily built both targets and, if asked to, was able to bundle them into one package.

With the introduction of Apple Silicion[^3]
the iOS simulator run on these machines would _also_ be `aarch64`[^4],
and also contain `ios`, but not be for the iOS hardware.

Now Xcode and the compiler will get confused what to put where when building on M1 hardware for both iOS hardware and the host architecture.

So the compiler toolchain gained knowledge of a new thing: `arm64-apple-ios14.0-simulator`,
explicitly marking the simulator target.
The compiler knows from where to pick the libraries and other SDK files when using that target.
You still can't put code compiled for `arm64-apple-ios` and `arm64-apple-ios14.0-simulator` into the same universal binary[^5],
because you can have each architecture only once (the `arm64` part in there).
That's what Carthage and others stumbled over.

Again Apple prepared for that and for a long time they have wanted you to use [XCFramework bundles][XCFramework bundles][^6].
Carthage just didn't used to support that.
The [0.37.0 release][carthage release] fixed that.

That still leaves Rust behind, as it doesn't know the new `-simulator` target.
But as always the Rust community is ahead of the game and [deg4uss3r] started adding a new target in [Rust PR #81966][rust sim target].
He got half way there when I jumped in to push it over the finish line.
How these targets work and how LLVM picks the right things to put into the compiled artifacts is severly underdocumented,
so I had to go the trial-and-error route in combination with looking at LLVM source code to find the missing pieces.
Turns out: the `14.0` in `arm64-apple-ios14.0-simulator` is actually important.

With the last missing piece in place, the new Rust target landed in February and is available in Nightly.
Contrary to the main `aarch64-apple-darwin` or `aarch64-apple-ios` target, the simulator target is not Tier 2 yet
and thus no prebuilt support is available.
`rustup target add aarch64-apple-darwin` does _not_ work right now.
I am now in discussions to [promote it to Tier 2][rust tier2 promotion],
but it's currently blocked by the [RFC: Target Tier Policy].

It works on nightly however and in combination with another cargo capability I'm able to build libraries for the M1 iOS simulator:

```
cargo +nightly build -Z build-std --target aarch64-apple-ios-sim
```

For now Glean iOS development on an M1 is possible, but [requires Nightly][glean arm64].
Goal achieved, I can actually work with this!

In a future blog post I want to explain in more detail how to teach Xcode about all the different targets it should build native code for.


## All The Other Projects

This was marked a stretch goal for a reason.
This involves all the other teams with Rust code and the iOS teams too.
We're not there yet and there's currently no explicit priority to make development of Firefox iOS on M1 hardware possible.
But when it comes to it, Glean will be ready for it and the team can assist others to get it over the finish line.

---

Want to hear more about Glean and our cross-platform Rust development?
Come to next week's [Rust Linz meetup][Rust Linz], where I will be talking about this.

---

_Footnotes:_

[^1]: See [Platform Support] for what the Tiers means.  
[^2]: The other name for that target.  
[^3]: "Apple Silicon" is yet another name for what is essentially the same as "M1" or "macOS aarch64"  
[^4]: Or `arm64` for that matter. Yes, yet another name for the same thing.  
[^5]: ["Universal Binaries"][apple universal binary] have existed for a long time now and allow for one binary to include the compiled artifacts for multiple targets. It's how there's only one Firefox for Mac download which runs natively on either Mac platform.  
[^6]: Yup, the main documentation they link to is a [WWDC 2019 talk recording video][binary framework video].


[glean]: https://github.com/mozilla/glean
[Rust Linz]: https://www.meetup.com/Rust-Linz/events/276521001/
[Firefox iOS]: https://github.com/mozilla-mobile/firefox-ios
[swift lb]: https://github.com/mozilla/glean/tree/main/glean-core/ios
[m1 tracking]: https://github.com/rust-lang/rust/issues/73908
[december release]: https://blog.rust-lang.org/2020/12/31/Rust-1.49.0.html#64-bit-arm-macos-and-windows-reach-tier-2
[Platform Support]: https://doc.rust-lang.org/nightly/rustc/platform-support.html
[cffi]: https://cffi.readthedocs.io/en/latest/whatsnew.html#v1-14-1
[arm64-wheels]: https://github.com/mozilla/glean/pull/1534
[android-emulator]: https://github.com/google/android-emulator-m1-preview
[carthage silicon issue]: https://github.com/Carthage/Carthage/issues/3019
[deg4uss3r]: https://github.com/deg4uss3r
[rust sim target]: https://github.com/rust-lang/rust/pull/81966/
[apple universal binary]: https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary
[xcframework bundles]: https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages
[binary framework video]: https://developer.apple.com/videos/play/wwdc2019/416/
[carthage release]: https://github.com/Carthage/Carthage/releases/tag/0.37.0
[rust tier2 promotion]: https://github.com/rust-lang/rust/issues/82412
[RFC: Target Tier Policy]: https://github.com/rust-lang/rfcs/pull/2803
[glean arm64]: https://github.com/mozilla/glean/pull/1498
