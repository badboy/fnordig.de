---
permalink: "/{{ year }}/{{ month }}/{{ day }}/your-personal-glean-data-pipeline"
title: "This Week in Glean: Your personal Glean data pipeline"
published_date: "2022-02-25 15:00:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
excerpt: |
  On February 11th, 2022 I gave a lightning talk titled
  "Your personal Glean data pipeline", presenting a little side project for
  ingesting, transforming and analyzing data collected from Glean-powered applications myself.
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work.
They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog][datablog].

[datablog]: https://blog.mozilla.org/data/2022/02/25/this-week-in-glean-your-personal-glean-data-pipeline

---

On February 11th, 2022 we hosted a Data Club Lightning Talk session.
There I presented my small side project of setting up a minimal data pipeline & data storage for Glean.

The premise:

> Can I build and run a small pipeline & data server to collect telemetry data from my own usage of tools?

To which I can now answer: Yes, it's possible.
The complete ingestion server is a couple hundred lines of Rust code.
It's able to receive pings conforming to the Glean ping schema, transform them and store it into an SQLite database.
It's very robust, not crashing once on me (except when I created an infinite loop within it).

You can watch the lightning talk here:

<br>

<iframe width="800" height="450" src="https://www.youtube.com/embed/V5FgVbxm-cc" title="YouTube video player" frameborder="0" allow="picture-in-picture" allowfullscreen></iframe>


Instead of creating some slides for the talk I created an interactive report.
The full report [can be read online][report].

[report]: https://data.fnordig.de/glean/report.html

Besides actually writing a small pipeline server this was also an experiment
in trying out [Irydium][] and [Datasette][]
to produce an interactive & live-updated data report.

Irydium is a set of tooling designed to allow people to create interactive documents using web technologies, started by [wlach][] a while back.
Datasette is an open source multi-tool for exploring and publishing data, created and maintained by [simonw][].
Combining both makes for a nice experience, even though there's still some things that could be simplified.

My pipeline server is currently not open source.
I might publish it as an example at a later point.

[irydium]: https://irydium.dev/
[wlach]: https://twitter.com/wrlach
[datasette]: https://datasette.io/
[simonw]: https://twitter.com/simonw
