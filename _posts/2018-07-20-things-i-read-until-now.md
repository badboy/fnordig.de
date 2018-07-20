permalink: "/{{ year }}/{{ month }}/{{ day }}/things-i-read-until-now"
title: "Things I read, until now"
published_date: "2018-07-20 11:05:00 +0200"
layout: post.liquid
data:
  route: blog
---

Earlier this year I started a [series of posts](/2018/01/08/things-i-read-week-2/index.html):
Trying to briefly collect articles/posts/code/documentation I read every week and add some comments for things I consider important.
After 9 weeks I failed to continue it. I didn't stop reading though.
So here's a try to restart that, starting with recent literature:

### Book: [Qualityland](https://qualityland.de/) (dark version)

[Marc-Uwe Kling](http://www.marcuwekling.de/), famously known for the Kangaroo Chronicles ("Die Känguru-Chroniken"), wrote another book which was released last year.
This one is a satirical dystopia, where everything in everyday life relies on opaque algorithms (not unlike today's world already).

### Short note: [State the Problem Before Describing the Solution](https://lamport.azurewebsites.net/pubs/state-the-problem.pdf)

By Leslie Lamport.  
Exactly what the title says. You can only work on a problem and its solution if you actually state what it is first.
Every scientific paper should have these four sections:

1. a brief informal statement of the problem
2. the precise correctness conditions required of a solution
3. the solution
4. a proof that the solution satisfies the requisite conditions

### Paper: [The Design and Implementation of Hyperupcalls](https://www.usenix.org/conference/atc18/presentation/amit)

By Nadav Amit and Michael Wei.  

tl;dr: eBPF code as a safe abstraction to move guest functionality into the hypervisor.
I did this for network filters in my [Master Thesis][ma].

[ma]: /2017/11/08/master-thesis-network-function-offloading-in-virtualized-environments/

### Paper: [Do Developers Read Compiler Error Messages?](http://static.barik.net/barik/publications/icse2017/PID4655707.pdf)

Turns out: they do. But acting on them is much more difficult.
