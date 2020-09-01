---
permalink: "/{{ year }}/{{ month }}/{{ day }}/leveraging-rust-to-build-cross-platform-mobile-libraries"
title: "This Week in Glean: Leveraging Rust to build cross-platform mobile libraries"
published_date: "2020-09-01 15:00:00 +0200"
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
This article is [cross-posted on the Mozilla Data blog](https://blog.mozilla.org/data/?p=232&preview=true).

---

A couple of weeks ago I gave a talk titled ["Leveraging Rust to build cross-platform mobile libraries"][video].
You can find my [slides as a PDF](https://fnordig.de/talks/2020/rustydays/slides.pdf).
It was part of the [Rusty Days][rustydays] Webference, an online conference that was initially planned to happen in Poland, but had to move online.
Definitely check out [the other talks][playlist].

[rustydays]: https://rusty-days.org/
[video]: https://www.youtube.com/watch?v=j5rczOF7pzg
[slides]: https://fnordig.de/talks/2020/rustydays/slides.pdf
[playlist]: https://www.youtube.com/watch?v=QaCvUKrxNLI&list=PLf3u8NhoEikhTC5radGrmmqdkOK-xMDoZ

One thing I wanted to achieve with that talk is putting that knowledge out there.
While multiple teams at Mozilla are already building cross-platform libraries, with a focus on mobile integration,
the available material and documentation is lacking.
I'd like to see better guides online, and I probably have to start with what we have done.
But that should also be encouragement for those out there doing similar things to blog, tweet & speak about it.

### Who else is using Rust to build cross-platform libraries, targetting mobile?

I'd like to hear about it.
Find me on Twitter ([@badboy\_](https://twitter.com/badboy_)) or drop me [an email](mailto:janerik@fnordig.de).

## The Glean SDK

I won't reiterate the full talk ([go watch it][video], really!), so this is just a brief overview of the Glean SDK itself.

The Glean SDK is our approach to build a modern Telemetry library, used in Mozilla's mobile products and soon in Firefox on Desktop as well.

The SDK consists of multiple components, spanning multiple programming languages for different implementations.
All of the Glean SDK lives in the GitHub repository at [mozilla/glean](https://github.com/mozilla/glean).
This is a rough diagram of the Glean SDK tech stack:

![Glean SDK Stack](https://tmp.fnordig.de/blog/2020/glean-stack.png)

On the very bottom we have `glean-core`, a pure Rust library that is the heart of the SDK.
It's responsible for controlling the database, storing data and handling additional logic (e.g. assembling pings, clearing data, ..).
As it is pure Rust we can rely on all Rust tooling for its development.
We can write tests that `cargo test` picks up. We can generate the full API documentation thanks to `rustdoc`
and we rely on `clippy` to tell us when our code is suboptimal.
Working on `glean-core` should be possible for everyone that knows some Rust.

On top of that sits `glean-ffi`.
This is the FFI layer connecting `glean-core` with everything else.
While glean-core is pure Rust, it doesn't actually provide the *nice API* we intend for users of Glean.
That one is later implemented on top of it all.
glean-ffi doesn't contain much logic.
It's a translation between the proper Rust API of glean-core and C-compatible functions exposed into the dynamic library.
In it we rely on the excellent [`ffi-support` crate](https://docs.rs/ffi-support/).
ffi-support knows how to translate between Rust and C types, offers a nice (and safer) abstraction for C strings.
glean-ffi holds *some* state: the instantiated global Glean object and metric objects.
We don't need to pass pointers back and forth. Instead we use opaque handles that index into a map held inside the FFI crate.

The top layer of the Glean SDK are the different [language implementations](https://mozilla.github.io/glean/book/dev/core/internal/implementations.html).
Language implementations expose a nice ergonomic API to initialize Glean and record metrics in the respective language.
Additionally each implementation handles some special cases for the platform they are running on, like gathering application and platform data or hooking into system events.
The nice API calls into the Glean SDK using the exposed FFI functions of `glean-ffi`.
Unfortunately at the moment different language implementations carry different amounts of actual logic in them.
Sometimes metric implementations require this (e.g. we rely on the clock source of Kotlin for timing metrics),
in other parts we just didn't move the logic out of the implementations yet.
We're actively working on [moving logic into the Rust part where we can](https://bugzilla.mozilla.org/show_bug.cgi?id=1651382) and might eventually use some code generation to unify the other parts.
[uniffi] is a current experiment for a multi-language bindings generator for Rust we might end up using.

[uniffi]: https://github.com/mozilla/uniffi-rs
