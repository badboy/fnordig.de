---
permalink: "/{{ year }}/{{ month }}/{{ day }}/redis-the-biggest-release-yet"
title: "redis-rs 0.11.0 - the biggest release yet"
published_date: "2019-07-01 20:55:00 +0200"
layout: post.liquid
data:
  route: blog
---

It's been more than 4 months since the last stable release of [redis-rs], the Redis client library for Rust.
It's also been a month since I published version 0.11.0-beta.1 of it.

It's now time for a stable release:

<center>

## [redis-rs v0.11](https://crates.io/crates/redis)

</center>

[**Documentation**](https://docs.rs/redis/*/redis/).  
[**Repository**](https://github.com/mitsuhiko).

## What is redis-rs?

Redis-rs is a high level [Redis] library for Rust.  
It provides convenient access to all Redis functionality through a very flexible but low-level API.  
It uses a customizable type conversion trait so that any operation can return results in just the type you are expecting.
This makes for a very pleasant development experience.

[redis-rs]: https://github.com/mitsuhiko/redis-rs/
[redis]: https://crates.io/crates/redis

## How to use it

Add the dependency to your `Cargo.toml`:

```ini
[dependencies]
redis = "0.11.0"
```

Then use it:

```rust
use redis::Commands;

fn fetch_an_integer() -> redis::RedisResult<isize> {
    let client = redis::Client::open("redis://127.0.0.1/")?;
    let con = client.get_connection()?;

    let _ : () = con.set("my_key", 42)?;
    con.get("my_key")
}
```

## What's new?

Read the [full changelog][changelog].

The v0.11 release is the biggest release in a while and contains a few bug fixes, improvemens and better async[^1] support.
It also comes with some breaking changes, which might require code changes in your code to make it work.

These changes were necessary to optimize performance, better support the asynchronous mode across all Rust editions.
It also gets rid of some cargo features, that are now either unnecessary or can be better implemented externally.

The [changelog] includes detail documentation about every breaking change as well as how to rewrite existing code to work with the new version.

[changelog]: https://github.com/mitsuhiko/redis-rs/blob/abe57741b69863b9843bc63ec5782bafcd727610/CHANGELOG.md

---

[^1]: async support remains an experimental feature.

## What's next?

I'd like to get the library to a stable 1.0 release eventually.
At least the synchronous usage of the library has been conceptually untouched since its beginning and seems to work reasonably well for users.
There also seems increasing demand to provide support for new commands such as streams or those provided by Redis modules.
I'm of the opinion that most of these can be better implemented as their own-standing libraries (if only because I neither want nor have the time and energy to maintain this functionality).
This gets easier if the core library is stable and the API guaranteed to not break again.

The asynchronous part however depends on unstable Rust features, the whole async ecosystem in Rust is only just evolving, and thus we shouldn't commit to the API that's currently in redis-rs just yet.

## Thanks

Most of the work on redis-rs was not done by me, but by contributors.

Thanks to all of them:

* [Markus Westerlind](https://github.com/Marwes), writing and improving async support as well as doing some reviews
* [Ayose Cazorla](https://github.com/ayosec), adding support for geospatial commands
    * this work started 2 years ago, but it took me until this year to take a proper look and merge it
* [Evan Schwartz](https://github.com/emschwartz), providing script support for the async mode

And of course thanks to [Armin Ronacher](https://github.com/mitsuhiko) for writing redis-rs in the first place.
