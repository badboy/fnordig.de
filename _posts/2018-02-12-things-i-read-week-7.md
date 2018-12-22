---
permalink: "/{{ year }}/{{ month }}/{{ day }}/things-i-read-week-7"
title: "Things I read, Week 7"
published_date: "2018-02-12 12:00:00 +0100"
layout: post.liquid
data:
  route: blog
---

This post is part of a [new experiment this year](/2018/01/08/things-i-read-week-2/index.html):
Trying to briefly collect articles/posts/code/documentation I read in the past week and add some comments for things I consider important.

### Blog post: [A Wee Allocator for WebAssembly](http://fitzgeraldnick.com/2018/02/09/wee-alloc.html)

Nick Fitzgerald wrote [wee_alloc](https://github.com/fitzgen/wee_alloc), a new minimal memory allocator for use with WebAssembly.
The current implementation in use for Rust, a [port of dlmalloc](https://github.com/alexcrichton/dlmalloc-rs) clocked in at several kilobytes in the final wasm module.
This is a bit too much if you want to have small modules.
Nick tackled this issue by writing a new allocator and thoroughly explaining its implementation.

### Blog post: [Why I don’t use the Go formatter](https://pote.io/blog/why-i-dont-use-go-fmt)

Pote argues for not using `gofmt` for projects with small teams.
He wants the developers to make the right decisions on formatting instead of being forced to a sometimes suboptimal formatting by a tool.
I'm not sure yet if I agree with his conclusion.
Then again I'm not an active user of [rustfmt](https://github.com/rust-lang-nursery/rustfmt) either, because of the - in my opinion - sometimes suboptimal formatting at the moment.
