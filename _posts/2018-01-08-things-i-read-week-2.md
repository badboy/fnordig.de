extends: post.liquid
title: "Things I read, Week 2"
date: 08 Jan 2018 10:54:22 +0100
path: /:year/:month/:day/things-i-read-week-2
route: blog
---

I want to try something new on this blog this year.
I tend to read and watch a lot of things during a week, either for work, for education or for fun and entertainment.
Sometimes I have thoughts on the content, sometimes I don't. I often rumble around a few thoughts [on Twitter](https://twitter.com/badboy_/), but that often gets lost.
I will start collecting the things worthwhile to mention now evey week and publish them here.

Let's start!

### Article: [Some Were Meant for C](https://www.cl.cam.ac.uk/~srk31/research/papers/kell17some-preprint.pdf) (PDF)


An article by [Stephen Kell](https://www.cl.cam.ac.uk/~srk31/).
He argues that C is not popular because of performance concerns, but for reasons of communication and integration.
He thinks it could be possible to implement C, the language, in a safe manner, while still allowing for a lot of the low-level things C can do.

> C is far from sacred, and I look forward
> to its replacements—but they must not forget the importance
> of communicating with aliens.

I can follow his thoughts and arguments, but I don't agree with his conclusions
(I can't fully express my disagreement yet).
His clear cut between C (unsafe, but low-level) and everything else (high-level, safe, managed) is too weak.
There are things in between (I see Rust in this position).
E.g. Rust allows unsafe wrappers around C-like things (direct memory access, re-use of in-memory data structures) plus safe interfaces on top of that.

### Code: [Lock-free grow-only Skiplist](https://gitlab.com/boats/skiplist/)

[withoutboats][] wrote an implementation of a lock-free grow-only map and set on top of a skiplist.
After I <strike>wrote</strike> tried to write a lock-free skiplist back in the days [of my bachelor thesis](/2014/11/15/how-to-not-write-a-bachelor-thesis/), I was happy to see a reasonable, small, understandable implementation of this concept, even if it completely skips the hard part (removing of entries).
For that reason (the removal part) his solution would not have worked back then for me, but it's still interesting.
The code uses a lot of unsafe and might very well contain bugs, so don't use it right now.

[withoutboats]: https://twitter.com/withoutboats

### Code: [smoltcp](https://github.com/m-labs/smoltcp)

A standalone TCP/IP stack implementation in Rust.
Does all the things like ARP, ICMP, IPv4 and IPv6, TCP and UDP.
It can do `tcpdump`-like packet filtering on a raw socket or can be used as a user-land networking library through tap interfaces.
It you're into networks it's worth to take a look.

### Blog post: [Rust 2018](https://www.ncameron.org/blog/rust-2018/) by Nick Cameron

(This is a response to [the community call for roadmap blogpost](https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html))

Nick argues for a boring year for Rust, which I can agree with when it comes to the roadmap.
We should finish off the stuff that is already half way there and get rid of old debt.  
This does not mean that we can't experiment or try new things/ideas/areas, but they won't be the main focus of the core team's roadmap. Individuals or groups should definitely pull Rust into new fields.

And as tweeted before, Rust's roadmap is a community effort, weigh in with your opinion to shape [#Rust2018!](https://twitter.com/search?q=%23rust2018)


