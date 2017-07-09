extends: post.liquid
title: "Redis FAQ or: what you learn when idling in #redis"
date: 10 Nov 2013 21:10:00 +0100
path: /:year/:month/:day/redis-faq-or-what-you-learn-when-idling-in-redis
---

Sometime ago I created the [redis-faq][], a small list of common or not so
common questions coming up in the `#redis` channel on freenode.

There's not much on it yet, but I would like to extend it whenever possible.
If you have something you want to add just ping me on [twitter][] or on freenode (`badboy_`).

For now these are the only things in there so far:

### Q: X is weird in my instance. Can you help?

Maybe. To better help please give the following info:

* Output of `redis-cli INFO`
* Output of `redis-cli CONFIG GET '*'`

Don't spam the channel, upload it to [pastebin][], as a [gist][] or similar.

### Q: I want to use [SELECT](http://redis.io/commands/select) to seperate my data. Is this a good idea?

Antirez decided `select` was an anti-pattern a loooong time ago. He won't fully
deprecate it, but it doesn't get support in new features such as cluster. (via
[brycebaril][]).
[Relevant mail][ml-select].

Just use seperate instances or use namespacing (often used: `namespace:real-key-name`)

### Q: I have some data and need to retrieve it by date. How to to that?

[Sorted Sets](http://redis.io/commands#sorted_set) can be useful here.
Store some value and use the timestamp as the score. Then use [ZRANGEBYSCORE](http://redis.io/commands/zrangebyscore) to get it back.

### Q: I installed a new version, but `redis-cli info server` still shows the old one

* Make sure the old instance is already stopped. `pidof redis-server` or `ps aux | grep [r]edis-server` should only list one PID.
* Make sure you're starting redis from the right path (if installed manually it might be different than when installed from your package manager)
* Make sure you're connecting to the right port. It is possible to run multiple instances on different ports (default port is 6379)

### Q: I have a background in SQL. Now I'm looking into how I can use Redis. Anything I need to consider?

If you're used to SQL, storing data in Redis is more like creating the indexes for your SQL schema (from: [brycebaril][])

[redis-faq]: https://gist.github.com/badboy/5958039
[twitter]: https://twitter.com/badboy_
[brycebaril]: https://github.com/brycebaril
[ml-select]: https://groups.google.com/forum/#!msg/redis-db/vS5wX8X4Cjg/8ounBXitG4sJ
[pastebin]: http://pastebin.com/
[gist]: https://gist.github.com/
