---
permalink: "/{{ year }}/{{ month }}/{{ day }}/end-of-maintenance-hiredis-co"
title: "End of Maintenance: hiredis & Co."
published_date: "2018-02-20 17:55:00 +0100"
layout: post.liquid
data:
  route: blog
---

In December 2014 hiredis was without a maintainer
and by February 2015 [I took over co-maintainership](/2015/02/09/hiredis-is-up-to-date/) together with other people.
I had high hopes to get all related projects into a usable, maintained and future-proof state and develop new features over time. I mostly failed.

I couldn't spend enough time on these projects and every time I tackled a few issue I ran out of energy and motivation to finish the task.

**Today I'm resigning as the maintainer of all hiredis-related libraries:**

* [hiredis](https://github.com/redis/hiredis)
* [hiredis-rb](https://github.com/redis/hiredis-rb)
* [hiredis-node](https://github.com/redis/hiredis-node)
* [hiredis-py](https://github.com/redis/hiredis-py/)
* [redis-rb](https://github.com/redis/redis-rb/)

[try.redis.io](http://try.redis.io/) will keep running for now in its current form without updates.

I contacted my co-maintainers and Salvatore to let them know and opened issues for people to coordinate future maintenance.
Thanks go out to [Michael](https://github.com/michael-grunder) and [Damian](https://github.com/djanowski) for their ongoing effort, help with issues and contributions.
Of course also thanks to those people reporting issues and contributing code, documentation and support over the years.


If anyone wants to help and take over, I will hand over respective owner rights to the different package systems.
You can reach me by mail.

My earliest contact with Redis dates back to 2010, when I started writing [an Erlang client](https://github.com/badboy/redis.erl).
A couple dozen commits to Redis itself, hundreds of messages on the mailing list and thousands of messages in the IRC channel later, I will end my involvement in the project to tackle new things.

**So Long, and Thanks for All the Fish.**  
(*Hitchhiker's Guide to the Galaxy*, Douglas Adams)
