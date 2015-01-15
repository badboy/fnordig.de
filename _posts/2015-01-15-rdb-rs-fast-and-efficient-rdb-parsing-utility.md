---
layout: post
title: rdb-rs - fast and efficient RDB parsing utility
date: 15.01.2015 23:50
---

Ever since I started looking into [Rust][] I knew I needed a bigger project for which I could use it.
I released a [few][lzf] [small][crc] [libraries][redlock], all based on Redis code/tools, so I figured:
Why not a bigger project focused on Redis as well?
We already have a nice [client library][redis-rs], so I did not need to write one myself.
I then thought about writing a Cluster-aware library on top of that, but before I got any real code written I faced some difficulties in how I want the API to look like, so I abandonded the idea for now as well.
The next idea was to have another implementation of the Cluster configuration utility `redis-trib`. Problem though: I did not even finish my attempt [in Go][redis-trib].
I looked around for more ideas and then I came across the [redis-rdb-tools][tools] again.
This small Python utility can parse, format and analyze Redis' dump files.
Its author Sripathi Krishnan also documented the [file format][old-wiki] and version history of RDB.

Sripathi didn't pay much attention to his project anymore, and so some bugs and feature requests remained unsolved.
With the current changes for Redis 3.0 like the Quicklist and a new RDB version, the redis-rdb-tools can't be used anymore for new dump files without patches.

So on last year's 31c3 I took some time and started reading and implementing a RDB parser in Rust based on the documentation.
While reading the documentation, the Python code as well as Redis' own [rdb.c][] I took notes and later rewrote and reformatted Sripathi's documentation to be up to date and to also include the latest changes.

Today I release this updated documentation. It's available online at [rdb.fnordig.de][site]:

* [RDB File Format][file-format]
* [RDB Version History][version-history]

I will keep it updated, should there be need and of course I will improve it if necessary.

At the same time I also open source my port of the redis-rdb-tools to Rust:

## [rdb-rs][code]

---

`rdb-rs` is a library and tool to parse RDB and dump it into another format like JSON or the [Redis protocol](http://redis.io/topics/protocol).

`rdb-rs` is offered both as a library and as a stand-alone command line tool.

The command line tool can be used to dump an existing RDB file in one of the provided formats:

~~~bash
$ rdb --format json dump.rdb
[{"key":"value"}]
$ rdb --format protocol dump.rdb
*2
$6
SELECT
$1
0
*3
$3
SET
$3
key
$5
value
~~~

For now it is nothing too fancy, but it gets the job done.
Over the next days and weeks I will improve it, add missing features such as filter options and hopefully also a memory reporter.


### Library

Using the library is as easy as calling the `rdb::parse` function and pass it a stream to read from and a formatter to use.

~~~rust
use std::io::{BufferedReader, File};

let file = File::open(&Path::new("dump.rdb"));
let reader = BufferedReader::new(file);
rdb::parse(reader, rdb::JSONFormatter::new());
~~~

`rdb-rs` brings 4 pre-defined formatters, which can be used:

* `PlainFormatter`: Just plain output for testing
* `JSONFormatter`: JSON-encoded output
* `NilFormatter`: Surpresses all output
* `ProtocolFormatter`: Formats the data in [RESP](http://redis.io/topics/protocol), the Redis Serialization Protocol

Adding your own formatter is as easy as implementing the [RdbParseFormatter][RdbParseFormatter] trait.

Over the next weeks I will rework parts of the library. Currently I'm not too happy with the API offered, especially proper return values and error handling.
The code also needs to be refactored to allow for filtering and memory reporting.
For the `redis-rdb-tools` Sripathi also reverse-engineered and documented the memory usage of key-value pairs, which needs updates as well.
This will take me some time to bring into the same format.

---

Finally, I want to say thanks to Sripathi Krishnan for building the rdb-tools and for the proper and very well written documentation. It helped a lot getting this done.

Also thanks to [Matt][], [Andy][] and [Itamar][] for some input and comments on the small parts of the project I showed them.

[redis-trib]: https://github.com/badboy/redis-trib.go
[rust]: http://rust-lang.org/
[lzf]: https://github.com/badboy/lzf-rs
[crc]: https://github.com/badboy/crc64-rs
[redlock]: https://github.com/badboy/redlock-rs
[redis-rs]: https://github.com/mitsuhiko/redis-rs
[old-wiki]: https://github.com/sripathikrishnan/redis-rdb-tools/wiki/Redis-RDB-Dump-File-Format
[rdb.c]: https://github.com/antirez/redis/blob/unstable/src/rdb.c
[site]: http://rdb.fnordig.de/
[code]: https://github.com/badboy/rdb-rs
[tools]: https://github.com/sripathikrishnan/redis-rdb-tools
[file-format]: http://rdb.fnordig.de/file_format.html
[version-history]: http://rdb.fnordig.de/version_history.html
[RdbParseFormatter]: http://rdb.fnordig.de/doc/rdb/formatter/trait.RdbParseFormatter.html
[Matt]: https://twitter.com/mattsta
[Andy]: https://twitter.com/andygrunwald
[Itamar]: https://twitter.com/itamarhaber
