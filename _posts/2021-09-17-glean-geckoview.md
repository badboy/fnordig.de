---
permalink: "/{{ year }}/{{ month }}/{{ day }}/glean-geckoview"
title: "This Week in Glean: Glean & GeckoView"
published_date: "2021-09-17 13:00:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
  - rust
excerpt: |
  It took us several more weeks to put everything into place,
  but we're finally shipping the Rust parts of the Glean Android SDK with GeckoView
  and consume that in Android Components.
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog][datablog].

[datablog]: https://blog.mozilla.org/data/2021/09/17/this-week-in-glean-glean-geckoview/

---

This is a followup post to [Shipping Glean with GeckoView](/2021/07/26/shipping-glean-with-geckoview/).

<center>

## It landed!

</center>

It took us several more weeks to put everything into place, but we're finally shipping the Rust parts of the Glean Android SDK with GeckoView
and consume that in [Android Components](https://github.com/mozilla-mobile/android-components/pull/10828) and [Fenix](https://github.com/mozilla-mobile/fenix/pull/20889).
And it still all works, collects data and is sending pings!
Additionally this results in a slightly smaller APK as well.

This unblocks further work now.
Currently Gecko simply stubs out all calls to Glean when compiled for Android,
but we will enable recording Glean metrics within Gecko and exposing them in pings sent from Fenix.
We will also start work on moving other Rust components into mozilla-central in order for them to use the Rust API of Glean directly.
Changing how we deliver the Rust code also made testing Glean changes across these different components a bit more challenging,
so I want to invest some time to make that easier again.
