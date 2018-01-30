permalink: "/{{ year }}/{{ month }}/{{ day }}/things-i-read-week-5"
title: "Things I read, Week 5"
published_date: "2018-01-29 12:00:00 +0100"
layout: post.liquid
data:
  route: blog
---

This post is part of a [new experiment this year](/2018/01/08/things-i-read-week-2/index.html):
Trying to briefly collect articles/posts/code/documentation I read in the past week and add some comments for things I consider important.

### Article: [The oral history of _Breaking Bad_](http://www.esquire.com/entertainment/tv/a15063971/breaking-bad-cast-interview/)

A longer interview with the actors and creators of [_Breaking Bad_](http://www.imdb.com/title/tt0903747/), the famous TV show about a chemistry teacher turned drug lord.
Interesting to know that Breaking Bad wasn't a hit from the start off, was still not canceled and grew a large fanbase overtime.
I really liked the show back then, maybe it's time to occasionally rewatch it.

### Article: [How a Dorm Room Minecraft Scam Brought Down the Internet](https://www.wired.com/story/mirai-botnet-minecraft-scam-brought-down-the-internet/)

This article details how three college-age friends initially wrote the largest botnet since ever, just to take down competing Minecraft servers.
Of course they got greedy and targetted bigger and bigger networks and later turned to click-fraud advertisers using the hijacked IoT devices.

### Blog post: [In defence of swap: common misconceptions](https://chrisdown.name/2018/01/02/in-defence-of-swap.html)

Chris Down thoroughly explains how memory reclamation and swap usage works on Linux and why it might be benefitial to have some swap space.
Turns out swap is not just *emergency memory*.
Additional settings introduced in the new cgroup v2 API allow for more fine-grained control of swap behaviour.
Until then tune your `vm.swappiness`.
