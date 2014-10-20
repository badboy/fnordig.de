---
layout: post
title: A Rust library for LibLZF
date: 15.10.2014 11:10
---

In the last four months I did not produce much open-source code. I was busy writing my Bachelor Thesis.
But I was active in the community, I attended several conferences, I read a lot of stuff and I wrote down a lot more things to do.

One of these things was "learn Rust", as you might figure (and writing more).
Well, I submitted my thesis on Monday and went on to write some actual Rust code.

So I created [lzf-rs][], a wrapper around [LibLZF][], a super small and fast compression library, originally written by Marc Lehmann.
LibLZF consists of just 4 files and is super-easy to compile as a small library.
LibLZF itself is used by [Redis](https://github.com/antirez/redis/blob/3c6f9ac37c849c82aebf5b45e895faa6cc80e7be/src/rdb.c#L222) for compressing strings in the RDB,
that's how I got to know it. I still don't know how it works, but I want to learn it now (and maybe port the whole code to Rust instead of using a wrapper around the C library?)

I used Rust's [Foreign Function Interface][ffi] to write the wrapper. Accessing C code from within Rust is quite simple.
The hard part is choosing the right data types and writing the API in a safe and usable way.
I'm not 100% happy with the current API of lzf-rs, so expect it to change.
I'm still in the process of figuring out what to expose and what not.

And now, enough of the talking. This is how to use the library:

~~~rust
use lzf;

fn main() {
  let data = "foobar";

  let compressed = lzf::compress(data.as_bytes()).unwrap();

  let decompressed = lzf::decompress(compressed.as_slice(), data.len()).unwrap();
}
~~~

I'm happy to get some feedback. It's my first serious Rust code, so prone to bugs and maybe not to Rusty afterall.
Ping me on [Twitter][], drop me an [email](mailto:badboy@archlinux.us) or [open an issue](https://github.com/badboy/lzf-rs/issues).

[lzf-rs]: https://github.com/badboy/lzf-rs
[liblzf]: http://software.schmorp.de/pkg/liblzf.html
[ffi]: http://doc.rust-lang.org/guide-ffi.html
[twitter]: https://twitter.com/badboy_
