---
layout: post
title: "Redis FAQ or: what you learn when idling in #redis"
---

First: this here is the unofficial FAQ, only containing things that come up by users in the IRC channel `#redis` on Freenode. There's also a more [official FAQ](http://redis.io/topics/faq). This document is also available in a [gist](https://gist.github.com/badboy/5958039).

## X is weird in my instance. Can you help?

Maybe. To better help please give the following info:

* Output of `redis-cli INFO`
* Output of `redis-cli CONFIG GET '*'`

Don't spam the channel, upload it to [pastebin](http://pastebin.com/), as a [gist](https://gist.github.com/) or similar.

## I want to use [SELECT](http://redis.io/commands/select) to seperate my data. Is this a good idea?

Antirez decided select was an anti-pattern a loooong time ago. He won't fully deprecate it, but it doesn't get support in new features such as cluster. (via brycebaril)

Just use seperate instances or use namespacing (often used: `namespace:real-key-name`)

## I have some data and need to retrieve it by date. How to to that?

[Sorted Sets](http://redis.io/commands#sorted_set) can be useful here.
Store some value and use the timestamp as the score. Then use [ZRANGEBYSCORE](http://redis.io/commands/zrangebyscore) to get it back.

## I installed a new version, but `redis-cli info server` still shows the old one

* Make sure the old instance is already stopped. `pidof redis-server` or `ps aux | grep [r]edis-server` should only list one PID.
* Make sure you're starting redis from the right path (if installed manually it might be different than when installed from your package manager)
* Make sure you're connecting to the right port. It is possible to run multiple instances on different ports (default port is 6379)

## I have a background in SQL. Now I'm looking into how I can use Redis. Anything I need to consider?

If you're used to SQL, storing data in Redis is more like creating the indexes for your SQL schema (from: brycebaril)

## `INFO keyspace` shows a different number of keys on the slave than on the master

First: check that master and slave are in sync. Do this by checking `INFO replication` of both master and slave and compare `master_repl_offset` and `slave_repl_offset`.
Next: Do you have a lot of expires? On initial sync the slave will drop all already expired keys, while they may still be in the master instance (but are gone as soon as you try to fetch them). (by: Moe, also [sync not copying all keys](http://grokbase.com/t/gg/redis-db/1254g6eebv/sync-not-copying-all-keys))

## I want a new version on my Ubuntu machine

You have multiple possibilities to do this.

1. Take what the Ubuntu repository provides: `apt-get install redis-server` (this may be a little bit old)
2. Compile it yourself, see [Download](http://redis.io/download), Section "Installation"
3. Use a PPA (Personal Package Archive), such as the one by [chris-lea](https://launchpad.net/~chris-lea/+archive/redis-server) or [rwky](https://launchpad.net/~rwky/+archive/redis)

## Where do I find the config?

Redis does not have a default path to put the config in. Instead you always have to specify it as a argument on the command line (or in your init script). Most distributions put the config into `/etc/redis.conf`, `/etc/redis/redis.conf`, `/var/lib/redis/redis.conf` or something similar. So look there first if you uncertain.

## I can't compile Redis. It fails with something like "error: no such file or directory: '../deps/hiredis/libhiredis.a'"

Try a `make distclean` first, then again a `make`. The compile step tries to be smart by only building dependencies once and use the old compile configuration. But it one of the dependencies fails it does not try to compile them again and thus fails. `make distclean` removes all previous saved state.

## Redis' PUBSUB is awesome. Can I use it for X?

Yes, Redis' pubsub mechanism is quite good. People get excited about it. But it might not be the best option for your use case. Pub/Sub is fire-and-forget. If you publish to a channel and no one is subscribed, that message is lost. It's not persisted, saved for later or held back. Just lost. This might or might not be what you want. For more read [section 1.1 of matt's Pub/Sub intro](https://matt.sh/advanced-redis-pubsub-scripts).

## Ok, I understand Pub/Sub, I really want to use it. Does it work with hundred or thousands of subscriptions/clients?

The mechanism to subscribe to a channel is quite cheap, consider it an constant-time operation. Publish is more expensive, it needs to send to all subscribed clients. For a much more details info read [the mailing list thread](https://groups.google.com/forum/#!topic/redis-db/R09u__3Jzfk).
