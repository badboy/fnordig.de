---
permalink: "/{{ year }}/{{ month }}/{{ day }}/state-of-maintenance-rdb-rs"
title: "State of Maintenance: rdb-rs"
published_date: "2025-03-29 16:39:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  Maintenance of rdb-rs, the Redis database format utility, is moving to @bimtauer.
  Tim recently worked on improvements and updates and approached me to take over the crate.
  I merged his patches, released 0.3.0 and will now hand over crate ownership.
---

Back in 2015 when I was learning Rust I started [rdb-rs][rdb-rs-announce], a library and tool to parse the Redis database file format (known as RDB).
I only ever published 4 versions of it, the last one in August 2016.
I eventually marked [the repository][repository] as read-only and forgot about it.

Up until recently when [Tim Bauer][bimtauer] sent me an email in February of this year.
Over the past months he took up rdb-rs, fixed up some things, added new functionality and support for newer versions of the RDB file format.
He asked me to take over ownership of the crate.

Over the past weeks I did a cursory review of [his changes][pr19] and decided to merge them.
Today I released that as [rdb v0.3.0](https://crates.io/crates/rdb).

I will now add Tim as an owner of the crate.
Development will proceed in his repository at <https://github.com/bimtauer/rdb-rs/>.

Thank you, Tim!

[rdb-rs-announce]: /2015/01/15/rdb-rs-fast-and-efficient-rdb-parsing-utility/
[repository]: https://github.com/badboy/rdb-rs
[pr19]: https://github.com/badboy/rdb-rs/pull/19
[bimtauer]: https://github.com/bimtauer
