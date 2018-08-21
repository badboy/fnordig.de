permalink: "/{{ year }}/{{ month }}/{{ day }}/state-of-maintenance-hiredis"
title: "State of Maintenance: hiredis"
published_date: "2018-08-21 12:00:00 +0200"
layout: post.liquid
data:
  route: blog
---

Back in February I [resigned as the maintainer of several Redis-related libraries](/2018/02/20/end-of-maintenance-hiredis-co/).

Since then I found some new maintainers taking over the work.
However, I was not very public about that and thus some people depending on
these libraries got suspicious when previously unknown people suddenly wrote
commits and pushed new packages.

It is entirely my fault for not properly announcing who took over. So here is a late but overdue followup.
The repositories of each of the libraries remain in the [Redis organization](https://github.com/redis) on GitHub.
Salvatore, the main developer of Redis, is the owner of this organization and has therefore full access to all repositories.

## [redis-rb][] (and [hiredis-rb][])

I was approached by [Florian Weingarten](https://github.com/fw42) and asked if a team of Shopify devs can take over.
I handed over access to the GitHub repository to a list of people provided by Florian, all of which are employed by Shopify.
Additionally I granted them access to the Gem.
Currently most development and new versions (and a beta release!) are driven by [Jean Boussier](https://github.com/byroot).

I trust Florian and his colleagues at Shopify to handle redis-rb.  
I retain ownership rights to the GitHub repository and the Gem.

## [hiredis-py][]

I was approached by [Yue Du](https://github.com/ifduyue).
I handed over access to the GitHub repository as well as the PyPi package.

I trust Yue to handle hiredis-py.  
I retain ownership rights to the GitHub repository and the PyPi package.

## [hiredis-node][]

No new maintainers were added.
However, with [node-redis](http://redis.js.org/) there's rarely a need to have the C library in use.
I'm okay with deprecating it.

## [hiredis][]

The underlying C library, hiredis, remains in the hands of [Michael Grunder](https://github.com/michael-grunder).

I trust Michael to handle hiredis.  
I retain ownership rights to the GitHub repository.

[redis-rb]: https://github.com/redis/redis-rb/
[hiredis-rb]: https://github.com/redis/hiredis-rb
[hiredis-py]: https://github.com/redis/hiredis-py
[hiredis-node]: https://github.com/redis/hiredis-node
[hiredis]: https://github.com/redis/hiredis
