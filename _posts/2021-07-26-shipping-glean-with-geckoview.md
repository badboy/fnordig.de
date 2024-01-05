---
permalink: "/{{ year }}/{{ month }}/{{ day }}/shipping-glean-with-geckoview"
title: "This Week in Glean: Shipping Glean with GeckoView"
published_date: "2021-07-26 12:00:00 +0200"
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
This article is [cross-posted on the Mozilla Data blog][datablog].

---

## Glean SDK

The Glean SDK is Mozilla's telemetry library, used in most mobile products and now for Firefox Desktop as well.
By now it has grown to a sizable code base with a lot of functionality beyond just storing some metric data.
Since its first release as a Rust crate in 2019 we managed to move more and more logic from the language SDKs
(previously also known as "language bindings") into the core Rust crate.
This allows us to maintain business logic only once and can easily share that across different implementations and platforms.
The Rust core is shipped precompiled for multiple target platforms, with the language SDK distributed through the respective package manager.

I talked about how this all works in more detail
[last year](https://www.youtube.com/watch?v=j5rczOF7pzg),
[this year](https://www.youtube.com/watch?v=j5rczOF7pzg)
and blogged about it [in a previous TWiG][twig-crossplatform].

## GeckoView

[GeckoView][] is Mozilla's alternative implementation for WebViews on Android, based on Gecko, the web engine that also powers Firefox Desktop.
It is used as the engine behind [Firefox for Android][fenix] (also called Fenix).
The visible parts of what makes up Firefox for Android is written in Kotlin, but it all delegates to the underlying Gecko engine,
written in a combination of C++, Rust & JavaScript.

The GeckoView code resides in the mozilla-central repository, next to all the other Gecko code.
From there releases are pushed to Mozilla's own [Maven repository][maven-repo].

## One Glean too many

Initially Firefox for Android was the only user of the Glean SDK.
Up until today it consumes Glean through its release as part of [Android Components][ac], a collection of libraries to build browser-like applications.

But the Glean SDK is also available outside of Android Components, as its own package.
And additionally it's available for other languages and platforms too, including a [Rust crate][crate].
[Over the past year we've been busy][fog-report] getting Gecko to use Glean through the Rust crate to build its own telemetry on top.

With the Glean SDK used in all these applications we're in a difficult position:
There's a Glean in Firefox for Android that's reporting data.
Firefox for Android is using Gecko to render the web.
And Gecko is starting to use Glean to report data.

That's one Glean too many if we want coherent data from the full application.

## Shipping it all together, take one

Of course we knew about this scenario for a long time.
It's been one of the goals of Project FOG to transparently collect data from Gecko and the embedding application!

We set out to find a solution so that we can connect both sides and have only one Glean be responsible for the data collection & sending.

We started with more detailed planning all the way back in August of last year
and agreed on a design in October.
Due to changed priorities & availability of people we didn't get into the implementation phase until earlier this year.

By February I had a first rough prototype in place.
When Gecko was shipped as part of GeckoView it would automatically look up the Glean library that is shipped as a dynamic library with the Android application.
All function calls to record data from within Gecko would thus ultimately land in the Glean instance that is controlled by Fenix.
Glean and the abstraction layer within Gecko would do the heavy work, but users of the Glean API would notice no difference,
except their data would now show up in pings sent from Fenix.

This integration was brittle.
It required finding the right dynamic library, looking up symbols at runtime as well as reimplementing all metric types to switch to the FFI API in a GeckoView build.
We abandoned this approach and started looking for a better one.

## Shipping it all together, take two

After the first failed approach the issue was acknowledged by other teams, including the GeckoView and Android teams.

Glean is not the only Rust project shipped for mobile,
the [application-services team][as] is also shipping components written in Rust.
They bundle all components into a single library, dubbed the [megazord].
This reduces its size (dependencies & the Rust standard library are only linked once) and simplifies shipping, because there's only one library to ship.
We always talked about pulling in Glean as well into such a megazord, but ultimately didn't do it (except for [iOS builds][megazord-ios]).

With that in mind we decided it's now the time to design a solution, so that eventually we can bundle multiple Rust components in a single build.
We came up with the following plan:

* The Glean Kotlin SDK will be split into 2 packages: a `glean-native` package, that only exists to ship the compiled Rust library, and a `glean` package,
  that contains the Kotlin code and has a dependency on `glean-native`.
* The GeckoView-provided `libxul` library (that's "Gecko") will bundle the Glean Rust library and export the C-compatible FFI symbols,
  that are used by the Glean Kotlin SDK to call into Glean core.
* The GeckoView Kotlin package will then use Gradle capabilities to replace the `glean-native` package with itself (this is actually handle by the Glean Gradle plugin).

Consumers such as Fenix will depend on both GeckoView and Glean.
At build time the Glean Gradle plugin will detect this and will ensure the `glean-native` package, and thus the Glean library, is not part of the build.
Instead it assumes `libxul` from GeckoView will take that role.

This has some advantages.
First off everything is compiled together into one big library.
Rust code gets linked together and even Rust consumers within Gecko can directly use the Glean Rust API.
Next up we can ensure that the version of the Glean core library matches the Glean Kotlin package used by the final application.
It is important that the code matches, otherwise calling native functions could lead to memory or safety issues.

Glean is running ahead here, paving the way for more components to be shipped the same way.
Eventually the experimentation SDK called Nimbus and other application-services components will start using the Rust API of Glean.
This will require compiling Glean alongside them and that's the exact case that is handled in mozilla-central for GeckoView then.

Now the unfortunate truth is: these changes have not landed yet.
It's been implemented for both the Glean SDK and mozilla-central,
but also requires changes for the build system of mozilla-central.
Initially that looked like simple changes to adopt the new bundling,
but it turned into bigger changes across the board.
Some of the infrastructure used to build and test Android code from mozilla-central was untouched for years and thus is very outdated
and not easy to change.
With everything else going on for Firefox it's been a slow process to update the infrastructure, prepare the remaining changes and finally getting this landed.

But we're close now!

Big thanks to [Agi] for connecting the right people, driving the initial design and helping me with the GeckoView changes.
He also took on the challenge of changing the build system.
And also thanks to [chutten] for his reviews and input. He's driving the FOG work forward and thus really really needs us to ship GeckoView support.

[datablog]: https://blog.mozilla.org/data/2021/07/26/this-week-in-glean-shipping-glean-with-geckoview
[twig-crossplatform]: /2020/09/01/leveraging-rust-to-build-cross-platform-mobile-libraries/
[geckoview]: https://mozilla.github.io/geckoview/
[fenix]: https://github.com/mozilla-mobile/fenix/
[maven-repo]: https://maven.mozilla.org/maven2/
[ac]: https://github.com/mozilla-mobile/android-components/
[as]: https://github.com/mozilla/application-services
[crate]: https://crates.io/crates/glean
[fog-report]: https://blog.mozilla.org/data/2020/10/06/this-week-in-glean-fog-progress-report/
[megazord]: https://github.com/mozilla/application-services/blob/main/docs/design/megazords.md
[megazord-ios]: https://github.com/mozilla/application-services/tree/main/megazords/ios
[agi]: https://github.com/agi/
[chutten]: https://github.com/chutten
