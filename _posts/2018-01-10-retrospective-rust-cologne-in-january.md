permalink: "/{{ year }}/{{ month }}/{{ day }}/retrospective-rust-cologne-in-january"
title: "Retrospective: Rust Cologne in January"
published_date: "2018-01-10 12:25:00 +0100"
layout: post.liquid
data:
  route: blog
---

Last monday, 8th of January, we had the first [Rust Cologne](http://rust.cologne) meetup this year.
We opted for a Open Space-style meetup, allowing for broad discussion rounds in small groups, which worked reasonably well this time (it's the second time we did it). More on that later.

## News

We usually start off the meeting with a short round of news since the last meetup (usually 4-6 weeks).
This time we did it a bit adhoc:

1. [Rust 1.23 was released](https://blog.rust-lang.org/2018/01/04/Rust-1.23.html)
2. [Diesel 1.0 was released](https://github.com/diesel-rs/diesel/releases/tag/v1.0.0)
3. [NLL (non-lexical lifetimes) are in nightly](https://github.com/rust-lang/rust/pull/46862)
4. [Call for #Rust2018 community input](https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html)

## Open Space

Open Space follows [4 simple principles](https://github.com/Rustaceans/rust-cologne/blob/gh-pages/meetup-orga/Rust%20Cologne%20Open%20Space.pdf):

1. Whoever comes are the right people.
2. Whatever happens is the only thing that could have.
3. When it starts is the right time.
4. When it's over, it's over.

This time around we had a couple of new attendees, which is very encouraging for everyone involved.
With a dozen people around, we managed to have between two and four concurrently running small discussion rounds.

We collected some topics upfront:

* Learning Rust
* Favourite not-yet-stable feature
* Embedded Rust
* Realtime programming
* Tokio / async programming
* Rust for the Web
* Miri

Obviously, I was not able to take part in all discussions, but I collected some rough notes from the things I was in.
In the following are some rough notes regarding each topic. There are not necessarily clear outcomes of the discussions or steps to take.

### Learning Rust

With a couple beginners and some more seasoned Rustaceans around, we discussed what it takes to learn Rust, (missing) material and projects.


* High-level docs on Cargo were requested: what does it do, why are dependencies not that bad, what to look out for in dependencies, drawbacks of too many dependencies
* A book on patterns in Rust: not everything in Rust is as easy to write as in other languages, sometimes a whole other pattern is necessary. These should be collected (also a "X in C++ will become Y in Rust")
* Confusion about split between 1st and 2nd version of [The Rust Programming Language (the book)](https://doc.rust-lang.org/book/). Old links are obviously sometimes broken, not all content is in both books. Some links in official documentation are broken due to the split (we didn't find a example that night, but it's worth triaging this)
* Better crate caching: A global per-system/per-user cache of compiled crates could go a long way to improve compile times (in theory). Why is it not done? Drawbacks? We should look up the current status and discussions.
* A [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/) might be a good idea, but can easily become overwhelming. In the end it needs to be easily findable through a quick Google search.

In the end this discussion spun off into the embedded discussion and I left.

### Tokio / async programming

* Tokio is undocumented, which definitely hinders adoption
* We discussed/explained what an event reactor (like Tokio) even is and how it ties in with futures
* We discussed why futures in Tokio are tied to the Tokio event reactor and can't easily be re-used for another event reactor
* Briefly discussed the coming async/await/Generator features
* Someone requested a larger guide on how to structure a large server with asynchronous network I/O. How to handle state? How to deal with disconnects/reconnects?
* We discussed trade-offs between async I/O and just relying on threads for server applications and when the latter makes more sense

### Rust for the Web

* I talked a bit about the story of Rust for web servers and also about the frontend part.
* Lots of interest in doing Rust in the frontend and not need to deal with JavaScript for most of the time
* The state of current web frameworks: there's a lot of work to do; Rocket might be promising, but it's bound to nightly and a lot of code rewriting, which I don't necessarily like; Iron and Nickel, the earliest frameworks, are on their way out

---

After 3 hours of lively discussions we brought the evening to an end.
This was (most likely) my last meetup as an official part of the organizer team.
[Plans for the February meetup](https://github.com/Rustaceans/rust-cologne/issues/46) are started and I might join that one again if I'm around. Please jump into the conversation and propose ideas, talks or projects!

Thanks to Colin (who also left the organizer team, but took care of invitations for the January meetup one last time), Pascal & Florian.
