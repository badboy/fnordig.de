---
permalink: "/{{ year }}/{{ month }}/{{ day }}/async-dns-in-smol"
title: "async DNS in smol"
published_date: "2025-11-07 18:30:00 +0100"
layout: post.liquid
data:
  route: blog
---

In the [previous][always-dns] blog post I showed how to use `getaddrinfo_async_start` from C.
However I didn't stop there and decided to see if I can fit that into the [smol] async stack in Rust.

smol is a small and fast async runtime.
It's an alternative to the probably more known [tokio] project
and is based on several smaller crates like [async-io] and [async-net] as its building blocks.

To make use of `getaddrinfo_async_start` I had to start at the lowest layer: [rustix],
the safe Rust bindings to syscalls.
It didn't know about `EVFILT_MACHPORT` for [kqueue] and now it does.
One layer above we have [polling], an interface for all things ... to poll, specifically kqueue on macOS.
In there we forward the mach port knowledge down the stack.
One further up [async-io] implements IO on top of the polling mechanism in use.
We register a mach port there to get informed when it's ready.
Then in the second to last layer of this smol stack we implement DNS resolving on top of `getaddrinfo_async_start` in [async-net].
A third of that code is reimplementations of the C structs in use,
another third is [code copied from Rust's libstd][socket-mod.rs].
Just the last third is code to integrate it with smol.
smol itself doesn't require any changes—it's what plugs all the other crates together.
The complete changes across those crates are available [in this patch set][smol-changes].

With all of that applied this works:

```Rust
smol::block_on(async {
    let addrs = smol::net::resolve("fnordig.de:443").await.unwrap();

    println!("{arg}:");
    for a in addrs {
        println!("\t{a}");
    }
})
```

Yes, that worked before, but it put DNS resolving onto another thread.
Now it doesn't do that anymore.
And it resolves:

```
fnordig.de:443:
        [2a01:4f8:221:2114::7]:443
        46.4.212.174:443
```

This is nowhere near production ready—remember it's a secret API and you probably shouldn't use it.

[always-dns]: /2025/11/01/it-s-always-async-dns/
[smol]: https://crates.io/crates/smol
[tokio]: https://tokio.rs/
[async-io]: https://crates.io/crates/async-io
[async-net]: https://crates.io/crates/async-net
[rustix]: https://crates.io/crates/rustix
[polling]: https://crates.io/crates/polling
[kqueue]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/kqueue.2.html
[smol-changes]: https://git.fnordig.de/jer/getaddrinfo_async/compare/0306c2aaa88c79639e8bf5d00236c1f811a0b28d..main
[socket-mod.rs]: https://github.com/rust-lang/rust/blob/96064126a086a8428d66e07fb3b91421bb86a512/library/std/src/sys/net/connection/socket/mod.rs
