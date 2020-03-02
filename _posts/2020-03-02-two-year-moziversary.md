---
permalink: "/{{ year }}/{{ month }}/{{ day }}/two-year-moziversary"
title: "Two-year Moziversary"
published_date: "2020-03-02 15:00:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
---

Woops, looks like I missed my Two Year Moziversary!
2 years ago, in March 2018, I joined Mozilla as a Firefox Telemetry Engineer.
Last year I blogged about [what happened in my first year][one-year Moziversary].

One year later I am still in the same team, but other things changed.
Our team grew (hello Bea & Mike!), and shrank (bye Georg!), lots of other changes at Mozilla happened as well.

However one thing stayed during the whole year: Glean.  
Culminating in the [very first Glean-written-in-Rust release][glean-release], but not slowing down after,
the Glean project is changing how we do telemetry in Mozilla products.

Glean is now being used in multiple products across mobile and desktop operating systems
([Firefox Preview](https://github.com/mozilla-mobile/fenix/),
[Lockwise for Android](https://github.com/mozilla-lockwise/lockwise-android),
[Lockwise for iOS](https://github.com/mozilla-lockwise/lockwise-ios),
[Project FOG](https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/fog)).
We've seen over 2000 commits on that project,
published 16 [releases](https://github.com/mozilla/glean/releases)
and posted 14 [This Week in Glean blogposts](https://mozilla.github.io/glean/book/appendix/twig.html).

This year will be focused on maintaining Glean, building new capabailities and bringing more of Glean back into Firefox on Desktop.
I am also looking forward to speak more about Rust and how we use it to build and maintain cross-platform libraries.

To the next year and beyond!

## Thank you

Thanks to my team: [:bea], [:chutten], [:Dexter], [:mdboom] & [:travis]!  
Lots of my work involves collaborating with people outside my direct team, gathering feedback, taking in feature requests and triaging bug reports.
So thanks also to all the other people at Mozilla I work with.

[:mdboom]: http://droettboom.com/
[:chutten]: https://chuttenblog.wordpress.com/
[:travis]: https://blogoftravis.wordpress.com/
[:Dexter]: https://www.a2p.it/wordpress/tech-stuff/mozilla/geckoview-glean-fenix-performance-metrics/
[:bea]: https://brizental.github.io/2019/12/06/this-week-in-glean-migrations.html
[glean-release]: https://fnordig.de/2019/10/24/this-week-in-glean/
[one-year Moziversary]: https://fnordig.de/2019/03/01/one-year-moziversary/
