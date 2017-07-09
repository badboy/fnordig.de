extends: post.liquid
title: "Iterate the keyspace in redis: SCAN"
date: 01 Nov 2013 18:40:00 +0100
path: /:year/:month/:day/iterate-the-keyspace-in-redis-scan
---

A few days ago antirez finally [merged][pr] the SCAN algorithm written by
[Pieter Noordhuis](https://twitter.com/pnoordhuis). With it it's now possible
to iterate the whole keyspace (or specific values in a set/sorted set/hash)
without a huge performance impact on the rest of the server (as `KEYS` would do
blocking on huge datasets).
Read more about the usage in [antirez' blog][antirez-63] or read the implementation
and explanation on [github][implementation] (I need to do that as well).
For end users the usage is [documented][scan-docu].

After the code was finally merged into unstable and 2.8 I sat down bringing
that feature into the redis client library and with that also into
[try.redis.io][tryredis]
The client code is rather simple and was quickly merged ([461dd43][scan-in-rb])
and is now also used in [try.redis][tryredis-scan].

A small thing I discovered playing around and testing the new code was a
crashing bug ([#1354][redis-crash]) with numeric values, but this was fixed as
well. Another thing was that the 2.8 was not compiling after the fix was added,
due to some new code only in the unstable branch. In absence of an official CI
server for redis (we once had one, [but it's currently disabled][twitter-disabled]
and will be back soon™) I went ahead and started the CI server on my own server:

<http://tmp.fnordig.de/redis/ci/>

Currently there is one failing test for 2.8 and unstable but I think we will get that fixed as well
(just the memory efficiency test).

With 2.8 already in RC-state we will soon have all the awesome new features in a stable redis release.

[pr]: https://github.com/antirez/redis/pull/579
[implementation]: https://github.com/antirez/redis/blob/dfeaa84d462a93070ee63ec87278a30d3105fa8d/src/dict.c#L663-L819
[antirez-63]: http://antirez.com/news/63
[scan-docu]: http://redis.io/commands/scan
[scan-in-rb]: https://github.com/redis/redis-rb/commit/461dd435a7aa3f3b0077f481c5d4219913d6705c
[redis-crash]: https://github.com/antirez/redis/issues/1354
[tryredis-scan]: https://github.com/badboy/try.redis/commit/1601dd931607d2872b6387209290b43dc00ad7da
[tryredis]: http://try.redis.io
[twitter-disabled]: https://twitter.com/antirez/status/395964119859613697
