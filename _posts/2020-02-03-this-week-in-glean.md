---
permalink: "/{{ year }}/{{ month }}/{{ day }}/this-week-in-glean"
title: "This Week in Glean: Cargo features - an investigation"
published_date: "2020-02-03 15:00:00 +0100"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
  - rust
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean. You can find an [index of all TWiG posts online](https://mozilla.github.io/glean/book/appendix/twig.html).)

The last blog post: [This Week in Glean: Glossary](https://brizental.github.io/2020/01/10/this-week-in-glean-glossary.html) by Bea.

---

As :chutten outlined in the first [TWiG blog post](https://chuttenblog.wordpress.com/2019/10/17/this-week-in-glean-glean-on-desktop-project-fog/) we're currently prototyping Glean on Desktop.
After a couple rounds of review, some adjustements and some learnings from doing Rust on mozilla-central, we were ready to land the first working prototype code earlier this year ([Bug 1591564][bz-landing]).

Unfortunately the patch set was [backed out nearly immediately][mc-backout] [^1] for 2 failures.
The first one was a "leak" (we missed cleaning up memory in a way to satisfy the rigorous Firefox test suite, that was fixed in [another patch](https://phabricator.services.mozilla.com/D59531)).
The second one was a build failure on a Windows platform.

This is what the log had to say about it (shortened to the relevant parts here, [see the full log output][logoutput]):

```
lld-link: error: undefined symbol: __rbt_backtrace_pcinfo
>>> referenced by gkrust_gtest.lib(backtrace-5286ea09b9822175.backtrace.3kzojw1m-cgu.3.rcgu.o)
lld-link: error: undefined symbol: __rbt_backtrace_create_state
>>> referenced by gkrust_gtest.lib(backtrace-5286ea09b9822175.backtrace.3kzojw1m-cgu.3.rcgu.o)
lld-link: error: undefined symbol: __rbt_backtrace_syminfo
>>> referenced by gkrust_gtest.lib(backtrace-5286ea09b9822175.backtrace.3kzojw1m-cgu.3.rcgu.o)
clang-9: error: linker command failed with exit code 1 (use -v to see invocation)
/builds/worker/workspace/build/src/config/rules.mk:608: recipe for target 'xul.dll' failed]
```

I set out to investigate this error.
While I had not seen that particular error before, I knew about the [`backtrace`][backtrace] crate. It caused me some trouble before (it depends on a C library, and won't work on all targets easily).
I knew that the Glean SDK doesn't really depend on its functionality[^2] and thus removing it from our dependency graph would probably solve the issue.
But first I had to find out why we depend on it somewhere and why it is causing these linker errors to begin with.

The first thing I noticed is that we didn't include anything new in the patch set that was now rejected.
Through some experimentation and use [`cargo-tree`][] I could tell that `backtrace` was included in the build before our Glean patch[^3], as a transitive dependency of another crate: [`failure`][].

So why didn't it fail the build before?
As per the errors above, the build failed only during linking, not compilation, which makes me believe those functions were never linked in previously, because no one passed around any errors that would cause these functions to be used.

As said before, the Glean SDK doesn't really need failure's backtrace feature, so I tried disabling its default features.
Due to how cargo currently works, this needs to be done across all transitive dependencies (the final feature set a crate is compiled with is the union across everything).

* [Disabling it in ffi-support in application-services](https://github.com/mozilla/application-services/pull/2448)
* [Disabling it in Glean (and depending on that changed ffi-support](https://github.com/mozilla/glean/commit/eed8f16f6afdbf8599301bf1a95d745c1eeab4b9)

I then changed mozilla-central to use the crates from git directly for testing.

Turns out that still fails with the same issue on the Windows target.
Something was re-enabling the "std" feature of `failure` in tree.

[`cargo-feature-set`][] was able to show me all enabled features for all dependencies I tracked it down further[^4].

Turns out the `quantum_render` feature enables the [webrender_bindings](https://searchfox.org/mozilla-central/source/gfx/webrender_bindings/) crate,
which then somehow pulls in `failure` through transitive dependencies again.
More trial-and-error revealed its a dependency of [the dirs crate](https://searchfox.org/mozilla-central/rev/a92ed79b0bc746159fc31af1586adbfa9e45e264/gfx/webrender_bindings/Cargo.toml#31), only used on Windows.
Except dirs doesn't _need_ `failure` for the target we're building for (`x86_64-pc-windows-gnu` or Mac or Linux).
It's again a transitive dependency for a crate called `redox_users`, which is [only pulled in when compiled for Redox](https://github.com/soc/dirs-rs/blob/3c3b61ff9611762bece3fc66fd6612b125819e3f/Cargo.toml#L15-L16)[^5].

Except that's not how Cargo works.
Cargo always pulls in all dependencies, merges all features and only later ignores the crates it doesn't actually need.
That's a long standing issue:

* [cargo#1796](https://github.com/rust-lang/cargo/issues/1796)
* [cargo#2589](https://github.com/rust-lang/cargo/issues/2589)
* [cargo#4361](https://github.com/rust-lang/cargo/issues/4361)

So now we identified who's pulling in the backtrace crate and maybe even identified why it was not a problem before.
How do we fix this?

As shown before, just disabling the backtrace feature in crates we use directly doesn't solve it, so one quick workaround was to force `failure` itself to not have that feature ever.
Easily done:

```patch
--- Cargo.toml
+++ Cargo.toml
@@ -23,5 +23,5 @@ members = [".", "failure_derive"]
 [features]
 default = ["std", "derive"]
 #small-error = ["std"]
-std = ["backtrace"]
+std = []
 derive = ["failure_derive"]
```

I [forked failure and commited that patch][failure-patch], then made mozilla-central use [my forked version][mc-patched-failure] instead.
Later I also removed `failure` from both Glean and application-services' `ffi-support`, as the small functionality we got from it was easily reimplemented manually.

Both approaches are short-term fixes for getting Glean into Firefox and it's clear that this issue might easily come up in some form soon again for either us or another team.
It's also a major hassle for lots of people outside of Mozilla, for example people working on embedded Rust frequently run into problems with `no_std` libraries suddenly linking in `libstd` again.

Initially I also planned to figure out a way forward for Cargo and come up with a fix for it, but as it turns out: Someone is already doing that!


[@ehuss][] started working on [adding a new feature resolver][feature-resolver].
While not yet final, it will bring a new `-Zfeatures` flag initially:

* `itarget` — Ignores features for target-specific dependencies for targets that don't match the current compile target.
* `build_dep` — Prevents features enabled on build dependencies from being enabled for normal dependencies.
* `dev_dep` — Prevents features enabled on dev dependencies from being enabled for normal dependencies.

I'm excited to see this being worked on and can't wait to try it out.
It will take longer for mozilla-central to rely on this of course, but I hope this will eventually solve one of the long standing issues with cargo.


<br>

---

<br>

[^1]: When patches are merged, a full set of tests are run on the Mozilla CI servers. If these tests fail the patch is reverted ("backed out") and the initial committer informed.

[^2]: Glean's error handling is pretty simplistic. We mostly only log errors on the FFI boundary and don't propagate them over this boundary. So far we didn't need a backtrace for errors there.

[^3]: The exact command enabling all the same features as the build I run in `toolkit/library/rust/shared` was (on the parent commit of my later patch to fix it: [7a3be2bbc][]):
```
cargo tree --features bitsdownload,cranelift_x86,cubeb-remoting,fogotype,gecko_debug,gecko_profiler,gecko_refcount_logging,moz_memory,moz_places,new_cert_storage,new_xulstore,quantum_render
```

[^4]: Same feature set as above, just running `cargo feature-set` this time.

[^5]: "[Redox](https://www.redox-os.org/) is a Unix-like Operating System written in Rust, aiming to bring the innovations of Rust to a modern microkernel and full set of applications". Firefox doesn't build on Redox.

[bz-landing]: https://bugzilla.mozilla.org/show_bug.cgi?id=1591564#c25
[mc-backout]: https://bugzilla.mozilla.org/show_bug.cgi?id=1591564#c27
[logoutput]: https://treeherder.mozilla.org/logviewer.html#/jobs?job_id=283842210&repo=autoland&lineNumber=93915
[backtrace]: https://docs.rs/backtrace/0.3.43/backtrace/
[bz-longexplanation]: https://bugzilla.mozilla.org/show_bug.cgi?id=1591564#c30
[failure-patch]: https://github.com/badboy/failure/commit/64af847bc5fdcb6d2438bec8a6030812a80519a5
[mc-patched-failure]: https://bugzilla.mozilla.org/show_bug.cgi?id=1608157
[`cargo-tree`]: https://crates.io/crates/cargo-tree
[`cargo-feature-set`]: https://crates.io/crates/cargo-feature-set
[7a3be2bbc]: https://hg.mozilla.org/integration/autoland/rev/7a3be2bbce032721ec01a9b75d88cc7c6b089825
[`failure`]: https://docs.rs/failure/0.1.6/failure/
[feature-resolver]: https://github.com/rust-lang/cargo/pull/7820
[@ehuss]: https://github.com/ehuss
