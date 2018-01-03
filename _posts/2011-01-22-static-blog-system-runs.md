permalink: "/{{ year }}/{{ month }}/{{ day }}/static-blog-system-runs"
title: "static blog system runs!"
published_date: "2011-01-22 00:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
my small and simple blog system works!

It's just a short javascript file. I just cat the text through a ssh connection into this [script](http://tmp.fnordig.de/post.js). It parses the content using [markdown-js](https://github.com/evilstreak/markdown-js) and re-writes the index.html file.

This way I can write a post wherever I have ssh access to my server (and as I've got a smartphone, that's nearly everywhere).

So have fun!
