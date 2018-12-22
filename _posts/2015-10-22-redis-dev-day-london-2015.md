---
permalink: "/{{ year }}/{{ month }}/{{ day }}/redis-dev-day-london-2015"
title: Redis Dev Day London 2015
published_date: "2015-10-22 15:05:00 +0200"
layout: post.liquid
data:
  route: blog
---
Last Monday the Redis Dev Day took place in London, followed by a small Unconference on Tuesday.
The Redis Dev Day is a gathering of all people involved in the Redis development,
that means Redis creator [Salvatore][antirez] as well developers and engineers from several companies
are there to discuss the future development of Redis.

Thanks to [Rackspace][] and especially [Nikki][] I was able to attend as well.

The Dev Day itself was packed with proposals and interesting ideas about improvements and new features for Redis.
In the following I'm trying to sum up some of them, listed by their relevance as I see them (most relevant first).

## NoNoSQL for Redis

[Salvatore][antirez] itself proposed this one: Native indexing in Redis.
He recently published [an article on indexing][indexing] based on Sorted Sets.
While this method is manual, it could very well be hidden behind a nice client interface (and indeed there are some out there, I just can't find a good example).
But having it right inside Redis might be more memory-efficient, faster, avoids transactions and might be easier to use.
Salvatore proposed new commands for that, for example to select based on a previously defined index:

```
IDXSELECT myindex IFI FIELDS $3 WHERE $1 == 56 and $2 >= 10.00 AND $2 <= 30.00
```

None of this is final yet, there are a lot of things to get right before this can be implemented.
For example it's not done with providing the commands for selection based on indexes, but needing to add, update and remove the index is necessary as well.
More in-depth discussions happened the next day, prior to the Unconf.

<center>
<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">Pre-Unconf Dev Meetup in progress! <a href="https://twitter.com/hashtag/RedisLondon?src=hash">#RedisLondon</a> <a href="https://t.co/7HhFocK9J0">pic.twitter.com/7HhFocK9J0</a></p>&mdash; c-&amp;gt;flags (@badboy_) <a href="https://twitter.com/badboy_/status/656499542750269441">October 20, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

Even though this kinda goes against the current idea of Redis
-- provide the basic tools with a simple API and not much more --
there is the possibility to implement it right and make it as usuable as Redis is right now.

This proposal needs more design effort to get right (both on the exposed API and internal design).

## Redis as a Cloud Native

[Bill][] -- yes, the real one -- always was a heavy user of Sentinel and thus had the most insight on what works and what doesn't.
And in fact one big thing where Redis still does not work in a way that anyone can be satisfied with is inside a Docker container.
Because of how Sentinel (or Cluster) announce themselves (or monitored instances) and the way Docker remaps ports,
it is currently hardly possible to run it inside a container without unusual configuration (like `--net=host`).

This needs improvements like making it possible to specify the announce address and port for all running modes.
Another thing that should be doable is configuration replication across nodes in a pod or Cluster.
This could easily be handled by a new command.
Instead of replicating all configuration automatically, this needs to be triggered by an admin, making it easy to only selectively replicate configuration options.

Both things seem necessary and not too hard.

Other proposals include:

* Save metadata inside Redis: Additional keyspace, but only exposed through special commands.
    * I get why this might be wanted by big providers, personally I don't have a use case for it currently.
* Config/Persistence stored in the cloud (Persistence on AWS, Config in etcd/consul/...)
    * Seems like a lot to add. I'm not convinced this belongs into the Redis core
* Redis for Memory as a Service: `malloc`, but in the cloud
    * Not sure what would be necessary. `SET`/`GET` and `GETRANGE` already provide a lot. Why not implement this client-side?

## Scripting

Since the introduction of Lua scripting inside Redis more and more people use it as a way to abstract logic away behind a single (atomic) call.
Just look at [what is possible implementing Quadtrees inside Lua in Redis][lua-quadtree].

Because of a [security issue](http://benmmurphy.github.io/blog/2015/06/04/redis-eval-lua-sandbox-escape/) access to the debug feature in Redis was disabled.
This also breaks some of the available options to properly debug Lua scripts.
Debug functionality is needed once you go this route, so bringing it back eventually is a good idea and maybe [finally closing very old issues](https://github.com/antirez/redis/pull/732).

## Command composition

For some commands we have `STORE` options ([`SORT`](http://redis.io/commands/sort) has it as an option, [`SINTERSTORE`](http://redis.io/commands/sinterstore) and others are their own command).

A more general form like `STORE dest SINTER keyA keyB` could make some users happy.
The current code base doesn't support that in a generic way, but it's not impossible to change that.
This might need a bit more design effort to be applied to all data types though.

## Modularity

Every time Redis gets discussed the issue about modularity comes up.
Most of the time I am a fan of making components reusable, modularize them where possible and abstract away the hard stuff.

Redis is different here.
A lot of the stuff in Redis interacts with each other and there is hardly a clear cut to make.

Should all underlying data type implementations be extracted?
They are useful for sure elsewhere, but then they won't benefit from shortcuts made.

Should the IO be completely separated from parsing and dispatching the commands?
Sounds useful for sure, especially now that the base is used in Disque as well.
But again, the coupling allows for some shortcuts.

Should hiredis be integrated and be part of the project? No way, hiredis is also a stand-alone client used by many others.
Keeping it in-tree would make it harder to develop on its on.

One thing we will do for sure is to unify the code base again.
The in-tree hiredis is currently not the same as the stand-alone one, partly due to the updated sds (the string implementation)
and partly because some bugs where fixed in the stand-alone project that don't affect Redis (I hope so)

[redislabs]: https://redislabs.com/
[rackspace]: http://www.rackspace.com/
[nikki]: https://twitter.com/nikkitirado
[antirez]: http://twitter.com/antirez
[indexing]: http://redis.io/topics/indexes
[bill]: http://twitter.com/ucntcme
[lua-quadtree]: https://gist.github.com/itamarhaber/c1ffda42d86b314ea701
