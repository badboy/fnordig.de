---
permalink: "/{{ year }}/{{ month }}/{{ day }}/what-rust-is-it"
title: "What Rust is it?"
published_date: "2018-11-28 20:09:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
---

A while ago (sometime in August) I built a small service called [What Rust is it?](http://www.whatrustisit.com/).

![What Rust is it? - Screenshot of the website](https://tmp.fnordig.de/blog/2018-11-28-what-rust-is-it.png)

Based on what [What Train is it now?](http://whattrainisitnow.com/) is for Firefox, this small service lists the three trains of Rust: release, beta & nightly as well as their respective versions.
It's updated every day and actually checks what `rustup` installed.
Additionally it shows the (planned) date of the next release.

Similar information is available on the [Rust Lang Forge](https://forge.rust-lang.org/).

See it live:

<center>
## [www.whatrustisit.com](http://www.whatrustisit.com)
</center>
