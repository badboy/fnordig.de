---
layout: post
title: Getting try.redis-db.com back online!
date: 13.12.2012 22:43
---

    Hi there,
    You've been super busy with Try Redis today, and that's awesome.

That's from an email I got a few minutes ago. It was from [alexmchale][], the
maintainer of [try.redis][tryredis-git].

[try.redis][tryredis-git] is, as I know now, a really cool project. It offered
a simple REPL and Step-by-Step-Tutorial similar to
[tryhaskell](http://tryhaskell.org/), [tryruby](http://tryruby.org/) and other
tryX sites.

It was available on <http://try.redis-db.com/> and hopefully will be online again in a few days.

It went offline a few days ago (maybe longer) and since then several people
asked on IRC (`#redis` on freenode) and twitter when it will be back.

So today I wrote [a mail to the Redis-DB mailing list][redisml] with the
intention to help, improve and maybe maintain the project.

I quickly got answers from Alex and [antirez][]. Both are working on the hosting part right now.

Meanwhile I sat down and quickly fixed [three][bug1] [open][bug2] [bugs][bug3]
and looked through the others, which resulted in 2 more PRs closed (already
applied) and about 4 issues to be closed soon.

Next step, once open bugs are fixed, is to update the tutorial (some missing
things like [hashes][bug4]) and improve the stability and quality of this project.

It only took me a few minutes working on this, but it's nice how this little help can make the difference.

Now it's your turn to get involved in an open-source project. try.redis needs some more help, too.

[tryredis-git]: https://github.com/alexmchale/try.redis
[redisml]: https://groups.google.com/forum/?fromgroups=#!topic/redis-db/Qu30xvHBhWU
[alexmchale]: https://github.com/alexmchale
[antirez]: https://github.com/antirez

[bug1]: https://github.com/alexmchale/try.redis/pull/15
[bug2]: https://github.com/alexmchale/try.redis/pull/16
[bug3]: https://github.com/alexmchale/try.redis/pull/17
[bug4]: https://github.com/alexmchale/try.redis/issues/13
