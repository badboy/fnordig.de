---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rust-4-years-later"
title: "Rust - 4+ years later"
published_date: "2019-05-15 14:00:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - rust
---

Exactly 4 years ago, on May 15th 2015, the Rust Core Team [announced the first stable version, Version 1.0](https://blog.rust-lang.org/2015/05/15/Rust-1.0.html), of the Rust Programming language.

I started my Rust journey even earlier than that, somewhere around [August 2014](/2014/08/12/first-experience-with-rust/), in parallel to my Bachelor thesis.
Shortly after my first blog post, I gave a last minute talk titled ["Rust for Rubyists"](/talks/2014/froscon/rust-for-rubyists/#/) [^1] at RedFrogConf, a (Ruby-focused) subconf of [FrOSCon](https://www.froscon.de/en/).
Back then Rust had "lightweight green tasks"!

Two months before the 1.0 release I spoke at CCCAC about [Rust](/talks/2015/cccac/rust-intro/#0) (those slides were built on minimal JavaScript so it could run in Servo).
I remember that I spent a lot of time on explaining the (safe) thread API.
Not only did I make a mistake in the explanation (and the code), but also shortly after the [scoped thread API was found to be unsound](https://github.com/rust-lang/rust/issues/24292) and subsequently removed
(use [crossbeam's `thread::scope` API](https://docs.rs/crossbeam/0.7.1/crossbeam/thread/fn.scope.html) if you need something similar but safe and sound now).

Then 1.0 came, more stuff was ripped out just before that and we got the first edition of [The Rust Programming Language](https://doc.rust-lang.org/book/first-edition/index.html) book.
Work obviously didn't stop there.

In 2016 we created the first ever [RustFest](https://2016.rustfest.eu/), a community conference dedicated to Rust.
Due to luck and enthusiasm of many more people we managed to pull of another RustFest just half a year later and [then four more editions after that](https://blog.rustfest.eu/past_events/) (I missed only the Zurich one).
The sixth edition, [RustFest Barcelona](https://barcelona.rustfest.eu/), is already announced.

In 2014 Florian and Johann founded the [Rust Berlin Hack and Learn](https://berline.rs/2014/11/04/hacking.html).
Last year, when I joined Mozilla and moved to Berlin, I became a co-organizer of that[^2].  
Today [we're celebrating](https://berline.rs/2019/05/15/rust-hack-and-learn.html), but not just Rust's birthday, but also over 100 events under the Rust Berlin label (that includes our bi-weekly Hack and Learn, infrequent Rust Berlin talk meetups and the Rust & Tell).

A month after I joined Mozilla, the first ever [Rust All-Hands](https://internals.rust-lang.org/t/rust-2018-all-hands/7141) happened in the Berlin office and,
as so much about my involvement with Rust,
I stumbled into being the responsible on-site person during that week. It [went pretty well](https://blog.rust-lang.org/2018/04/06/all-hands.html).
We repeated the [Rust All-Hands this year](https://blog.mozilla.org/berlin/rust-all-hands-2019/) (German article), now with me being _officially_ the on-site organizer, but also attendee.

In 2017 I shipped my first piece of Rust code used in production (an actual [opera production](https://www.theaterdo.de/detail/event/einstein-on-the-beach/)): [midioscar](https://github.com/rrbone/midioscar).
A couple of weeks ago I started my first Mozilla project using Rust (more about that in a future blog post).

Not only did Rust become a community I invest my time and resources in, it is now also officially part of my job.

We're at [Rust 1.34.2](https://www.whatrustisit.com/) now (that's over <strike>34</strike> 36 releases in 4 years!), with even more improvements, bug fixes, community conferences, hack fests and All Hands ahead of us.
Rust is here to stay.

<center>

## 🎉 To the next 4+ years! 🎉

</center>

---
[^1]: Based on [@steveklabnik](https://twitter.com/steveklabnik)'s "[Rust for Rubyists](http://www.rustforrubyists.com/)" tutorial.

[^2]: Fun fact: by accident I kinda was the one responsible for a Hack'n'Learn one night when I was in Berlin for other work, but none of the dedicated organizers was able to make it to the meetup.
