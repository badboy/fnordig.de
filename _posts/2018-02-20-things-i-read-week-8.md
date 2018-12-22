---
permalink: "/{{ year }}/{{ month }}/{{ day }}/things-i-read-week-8"
title: "Things I read, Week 8"
published_date: "2018-02-20 18:10:00 +0100"
layout: post.liquid
data:
  route: blog
---

This post is part of a [new experiment this year](/2018/01/08/things-i-read-week-2/index.html):
Trying to briefly collect articles/posts/code/documentation I read in the past week and add some comments for things I consider important.


### Blog post: [Freedom From the Box](https://hackernoon.com/freedom-from-the-box-c229df788439)

A transcript of a talk by Sarah Groff Hennigh-Palermo, in which she describes why she really disliked types in programming languages.
The talk is obviously strongly worded.
She gives 6 reasons why she favors another approach to programming.
I disagree with most of her points though, and not only because I'm working in a [language with a lot of types](https://www.rust-lang.org/en-US/).
I have the feeling that some of her approaches around this are types-just-differently-encoded.
She's also advocating for `null`.
Nonetheless an interesting read and a different perspective.

### Blog post series: [A Minimal Rust Kernel](https://os.phil-opp.com/minimal-rust-kernel/)

Philipp Oppermann is back with his second edition of "Writing an OS in Rust"[^1].
It's far from finished and goes a slightly different way than the first edition.
Gone is writing the assembly to actually boot your OS, instead using an existing bootloader and focusing more on the operting system itself.

### Blog post: [Picking Apart the Crashing iOS String](https://manishearth.github.io/blog/2018/02/15/picking-apart-the-crashing-ios-string/)

[Manish](https://twitter.com/Manishearth) dives deep into the latest iOS crash bug involving a unsuspicious looking sequence of [Telugu](https://en.wikipedia.org/wiki/Telugu_language) characters.
Turns out there are quite a few combinations of characters causing the crash.
He didn't find why it's happening though.
And if you're on iOS: there's an iOS upgrade available now, install it.


---

[^1]: The first version can be found at [os.phil-opp.com](https://os.phil-opp.com/)
