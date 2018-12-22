---
permalink: "/{{ year }}/{{ month }}/{{ day }}/swap-in-double-linked-lists"
title: "swap in double-linked lists"
published_date: "2012-05-07 22:22:00 +0200"
layout: post.liquid
data:
  route: blog
---
Yesterday I had to implement [Selection Sort](http://en.wikipedia.org/wiki/Selection_sort)
for double-linked lists and I had some trouble finding the correct solution
when it comes to swapping two elements.

But I finally figured out how to correctly swap the pointers and I'll drop the
code here so others can use it (or even tell me about hidden bugs)

I implemented it in Java, so see here:

<script src="https://gist.github.com/2630183.js"> </script>
