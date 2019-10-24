---
permalink: "/{{ year }}/{{ month }}/{{ day }}/this-week-in-glean"
title: "This Week in Glean: A Release"
published_date: "2019-10-24 17:30:00 +0200"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)

Last week's blog post: [This Week in Glean: Glean on Desktop (Project FOG)](https://chuttenblog.wordpress.com/2019/10/17/this-week-in-glean-glean-on-desktop-project-fog/) by chutten.

---

Back in June when [Firefox Preview shipped](https://blog.mozilla.org/futurereleases/2019/06/27/reinventing-firefox-for-android-a-preview/), it also shipped with Glean, our new Telemetry library, initially targeting mobile platforms.
Georg recently blogged about the design principles of Glean in [Introducing Glean — Telemetry for humans](https://medium.com/georg-fritzsche/introducing-glean-telemetry-for-humans-4e8b4788b8ad).

Plans for improving mobile telemetry for Mozilla go back as as far as December 2017.
The first implementation of the Glean SDK was started around August 2018, all written in Kotlin (though back then it was mostly ideas in a bunch of text documents).
This implementation shipped in [Firefox Preview](https://github.com/mozilla-mobile/fenix/) and was used up until now.

On March 18th I [created an initial Rust workspace](https://github.com/mozilla/glean/commit/95b6bcc03616c8d7c3e3e64e99ee9953aa06a474).
This kicked of a rewrite of Glean using Rust to become a cross-platform telemetry SDK to be used on Android, iOS and eventually coming back to desktop platforms again.

1382 commits later[^1] I tagged [v19.0.0](https://github.com/mozilla/glean/commit/1ac00bf63daea97f6e2d6fa36980279eecf5a800)[^2].

Obviously that doesn't make people use it right away, but given all consumers of Glean right now are Mozilla products, it's up on us to get them to use it.
So [Alessio did just that](https://github.com/mozilla-mobile/android-components/pull/4620) by upgrading Android Components, a collection of Android libraries to build browsers or browser-like applications, to this new version.

This will soon roll out to nightly releases of Firefox Preview and, given we don't hit any larger bugs, hit the release channel in about 2 weeks.
Additionally, that finally unblocks the Glean team to work on new features, ironing out some sharp edges and bringing Glean to Firefox on Desktop.
Oh, and of course we still need to actually release it for iOS.

## Thanks

Glean in Rust is the project I've been constantly working on since March.
But getting it to a release was a team effort with help from a multitude of people and teams.

Thanks to everyone on the Glean SDK team:

* [Alessio Placitelli](https://github.com/dexterp37/)
* [Michael Droettboom](https://github.com/mdboom/)
* [Travis Long](https://github.com/travis79/)
* [Georg Fritzsche](https://github.com/georgf/)
* [Chris Hutten-Czapski](https://github.com/chutten)
* [Beatriz Rizental](https://github.com/brizental)

Thanks to [Frank Bertsch](https://github.com/fbertsch) for a ton of backend work as well as the larger Glean pipeline team led by [Mark Reid](https://github.com/mreid-moz), to ensure we can handle the incoming telemetry data and also reliably analyse it.
Thanks to the Data Engineering team led by Katie Parlante.
Thanks to [Mihai Tabara](https://github.com/MihaiTabara), the Release Engineering team and the Cloud Operations team, to help us with the release on short notice.
Thanks to the [Application Services](https://github.com/mozilla/application-services) team for paving the way of developing mobile libraries with Rust and to the [Android Components](https://github.com/mozilla/application-services) team for constant help with Android development.

---

[^1]: Not all of which are just code for the Android version. There's [a](https://mozilla.github.io/glean/docs/glean_core/index.html) [lot](https://mozilla.github.io/glean/javadoc/glean/) [of](https://mozilla.github.io/glean/swift/) [documentation](https://mozilla.github.io/glean/book/index.html) too.

[^2]: This is the first released version. This is just the version number that follows after the Kotlin implementation. Version numbers are cheap.
