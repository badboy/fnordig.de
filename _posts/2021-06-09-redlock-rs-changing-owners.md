---
permalink: "/{{ year }}/{{ month }}/{{ day }}/redlock-rs-changing-owners"
title: "redlock-rs changing owners"
published_date: "2021-06-09 10:40:00 +0200"
layout: post.liquid
data:
  route: blog
---

Redlock is a distributed locking mechanism built on top of Redis.
The full specification is online at [Distributed locks with Redis](https://redis.io/topics/distlock).

More than 6 years ago, on November 22, 2014, I published [redlock-rs],
shortly after renamed it to just [redlock].
In 2016 I tagged it as 1.0.
In 2019 I did some code cleanup, dependency upgrades and merged some external contributions,
resulting in a 1.1 release in April of this year.
Shortly after I archived the repository to signal that I'm no longer maintaining it.

[redlock-rs]: https://crates.io/crates/redlock-rs/
[redlock]: https://crates.io/crates/redlock/

This must have been one of my earliest Rust crates I published.
It let me play around with the [Redis crate][redis], while also learning Rust.
I've never even ran Redlock in any work or private project, so I don't even know if it holds up to its guarantees.

[redis]: https://crates.io/crates/redis

Nonetheless it seems other people are relying on Redlock and the Redlock crate specifically.
I was appraoched last month asking if I'd be willing to hand over maintainership.
I agreed.

**Ownership of the Redlock crate & repository will move to Aaron Griffin ([@aig787](https://github.com/aig787)) within the next days.**

* Crate: <https://crates.io/crates/redlock/>
* Repository: <https://github.com/badboy/redlock-rs>
* Latest commit: [c4140c3f8444fac3e643070b6c51a550a6f6df73: Version Bump (1.1.0)](https://github.com/badboy/redlock-rs/commit/c4140c3f8444fac3e643070b6c51a550a6f6df73)

As of today the full implementation is a mere 130 lines of code (and an equal amount of test code),
directly translated from the plaintext specification.
Everyone who relies on it should be able to review that code.
