extends: post.liquid
title: "Redis Sentinel & Redis Cluster - what?"
date: 01 Jun 2015 23:20:00 +0200
path: /:year/:month/:day/redis-sentinel-and-redis-cluster
---

In the last week there were several questions regarding Redis Sentinel and Redis Cluster, if one or the other will go away or if they need to be used in combination.
This post tries to give a _short_ and _precise_ info about both and what they are used for.

## Redis Sentinel

Redis Sentinel was [born in 2012](https://github.com/antirez/redis/commit/6b5daa2df2a0711a25746cb025927dc3deb7717e) and first released when Redis 2.4 was stable.
It is a system designed to help managing Redis instances.

It will **monitor** your master & slave instances, **notify** you about changed
behaviour, handle **automatic failover** in case a master is down and act as a
**configuration provider**, so your clients can find the current master
instance.

Redis Sentinel runs as a seperate program.
You should have atleast 3 Sentinel instances monitoring a master instance and its slaves.
Sentinel instances try to find consensus when doing a failover and only an odd number of instances will prevent most problems, 3 being the minimum.
In this case one of the Sentinel instances can go down and a failover will still work as (hopefully) the other two instances reach consensus which slave to promote.

One thing about the configurable quorum: this is only the number of Sentinel who have to agree a master is down.
You still need `N/2 + 1` Sentinels to vote for a slave to be promoted (that `N` is the total number of all Sentinels ever seen for this pod).

A pod of Sentinels can monitor multiple Redis master & slave nodes. Just make sure you don't mix up names, add slaves to the right master and so on.

[Full documentation for Sentinel](http://redis.io/topics/sentinel).

## Redis Cluster

If we go by [first commit](https://github.com/antirez/redis/commit/ecc9109434002d4667cd01a3b7c067a508c876eb),
then Cluster is even older than Sentinel, dating back to 2011.
There's a bit more info in [antirez' blog](http://antirez.com/news/79).
It's released as stable with version 3.0 as of April 1st, 2015.

Redis Cluster is a **data sharding** solution with **automatic management**, **handling failover** and **replication**.

With Redis Cluster your data is split across multiple nodes, each one holding a subset of the full data.
Slave instances replicate a single master and act as fallback instances.
In case a master instance will become unavailable due to network splits or software/hardware crashes,
the remaining Master nodes in the Cluster will register this and will reach a state triggering a failover.
A suitable Slave of the unavailable Master node will then step up and will be promoted to takeover as a new Master.

You don't need additional failover handling when using Redis Cluster and you should definitely not point Sentinel instances at any of the Cluster nodes.
You also want to use a *smart* client library that knows about Redis Cluster, so it can automatically redirect you to the right nodes when accessing data.

[Redis Cluster specification][spec] and [Redis Cluster Tutorial][tutorial].  
I gave a talk about Redis Cluster at the [PHPUGDUS meeting][phpugdus] last month, my slides are [on slidr.io][slides].

---

Want to hear more about Redis, Redis Sentinel or Redis Cluster? [Just invite me!](mailto:janerik@fnordig.de)


[spec]: http://redis.io/topics/cluster-spec
[tutorial]: http://redis.io/topics/cluster-tutorial
[slides]: http://slidr.io/badboy/redis-cluster
[phpugdus]: http://www.meetup.com/PHP-Usergroup-Duesseldorf/
