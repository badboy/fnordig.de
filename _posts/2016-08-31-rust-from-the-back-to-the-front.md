---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rust-from-the-back-to-the-front"
title: Rust from the Back to the Front (Rust Sthlm)
published_date: "2016-08-31 16:30:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - rust
---

<center>

[![Rust on the Web](//tmp.fnordig.de/rust-sthlm/th-2016-08-29_18.23.59.jpg)](//tmp.fnordig.de/rust-sthlm/2016-08-29_18.23.59.jpg)

</center>

Last monday I attended the [Rust Sthlm][meetup] Meetup and gave a talk about using Rust for web development.
About 60 people attended, had pizza and listened to the two talks of the evening.

<center>

[![Meetup](//tmp.fnordig.de/rust-sthlm/th-2016-08-29_18.59.00.jpg)](//tmp.fnordig.de/rust-sthlm/th-2016-08-29_18.59.00.jpg)

</center>

I started off with my talk *Rust from the Back to the Front*, giving an overview of the ecosystem around all things related to web programming in Rust.
This was an updated talk of the one I gave in Budapest last year ([video online](https://www.youtube.com/watch?v=L9sTIi7wFPo)).
I had some technical difficulties this time in the beginning (yeah, computers…), but otherwise the talk went well.
People showed interest in the presented topics.
Sadly I only briefly touched the new way of doing asynchronous I/O using [futures](https://github.com/alexcrichton/futures-rs) and [tokio](https://github.com/tokio-rs).
I definitely need to look deeper into this topic, as I think it can bring huge improvements to existing web frameworks and libraries as well.
This has to wait a bit though, as I will first dive deeper into Emscripten (and present that [next week in Cologne](http://rustaceans.cologne/2016/09/05/compile-to-js.html) and in [Pittsburgh in October](http://www.rust-belt-rust.com/)).
My slides are [online][slides] and I will try to collect more [resources in a Gist][resources].

<center>

[![Rust and openSUSE](//tmp.fnordig.de/rust-sthlm/th-2016-08-29_20.03.47.jpg)](//tmp.fnordig.de/rust-sthlm/2016-08-29_20.03.47.jpg)

</center>

The second talk that evening was by [Kristoffer Grönlund][krig], giving us a quick introduction to some of Rust's features,
followed by an overview of his work trying to get Rust into the openSUSE package repositories.
Turns out it is not that easy, especially if everything has to be built from source and offline, but at least there are some improvements
that might help make this easier.
His slides are [online as well][suseslides].

Even after the talks some of the people stuck around and we discussed several more things around Rust, how it is still evolving,
fast moving and a bit unstable from time to time.

All in all I had a great time, talked to a number of people about differen topics and I hope I could convince some to actually try Rust.
With such a large and interested tech community in Stockholm, I'm sure the Meetup will live on.

[meetup]: https://www.meetup.com/ruststhlm/events/232054490/
[slides]: https://badboy.github.io/rust-sthlm/
[resources]: https://gist.github.com/badboy/ba039333b8716c29d6038ef211ccd8e3
[suseslides]: http://www.kri.gs/presentation-rust-obs-sthlm-meetup/#/4/5
[krig]: https://github.com/krig
