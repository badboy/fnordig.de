---
permalink: "/{{ year }}/{{ month }}/{{ day }}/things-i-read-week-6"
title: "Things I read, Week 6"
published_date: "2018-02-06 18:40:00 +0100"
layout: post.liquid
data:
  route: blog
---

This post is part of a [new experiment this year](/2018/01/08/things-i-read-week-2/index.html):
Trying to briefly collect articles/posts/code/documentation I read in the past week and add some comments for things I consider important.

(A day late due to last week's travel and sickness)

### Blog post: [Tokio Internals](https://cafbit.com/post/tokio_internals/)

David Simmons dives deep into [tokio-core](https://crates.io/crates/tokio-core), [futures](https://crates.io/crates/futures) and asynchronous programming in Rust in general.
This article helped me quite a bit to understand how all the different things work together.
It's the missing documentation for the named crates and combines a look into the code, a look at the executed syscalls, pretty diagrams and a lot of text to explain everything in detail.

(I had this saved for a while, but never managed to read it)

### Video: [Containers aka crazy user space fun](https://www.youtube.com/watch?v=7mzbIOtcIaQ)

[Jessie Frazelle](https://twitter.com/jessfraz) keynoted linux.conf.au 2018 with a tour through the container ecosystem.
She explains what a container even is, how it sandboxes things and which knobs you can turn to lessen its security.
Worth a watch if you're working with containers.

(A summary will eventually be available [on LWN](https://lwn.net/Articles/745820/))
