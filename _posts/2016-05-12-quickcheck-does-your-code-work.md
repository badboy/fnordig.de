---
permalink: "/{{ year }}/{{ month }}/{{ day }}/quickcheck-does-your-code-work"
title: "Quick check: does your code work?"
published_date: "2016-05-12 23:00:00 +0200"
layout: post.liquid
data:
  route: blog
  tags:
    - rust
---
… because mine didn't. At least not correctly in all cases.
I'm talking about my Rust library [lzf-rs](https://crates.io/crates/lzf),
a port of the small compression library [LibLZF](http://software.schmorp.de/pkg/liblzf.html).
It started as a wrapper around the C library, but I rewrote it in Rust for v0.3.
I now found three major bugs and I want to tell you how (tl;dr: Bug fixes and tests: [PR #1][pr]).

For a university paper I'm currently looking into different methods for automatic test generation,
such as *symbolic execution*, *fuzzing* and *random test generation*.
One of the popular methods is property-based testing, with QuickCheck being the best known application of this method.
QuickCheck started as a Haskell library (see the [original paper](http://www.eecs.northwestern.edu/~robby/courses/395-495-2009-fall/quick.pdf)),
but is ported to several other languages, including C (see [theft](https://github.com/silentbicycle/theft))
and of course Rust: [QuickCheck](https://github.com/BurntSushi/quickcheck).

I knew this library for some time now, but never used it.
So today I decided to use it for my [lzf](https://crates.io/crates/lzf) crate.
Let me walk you through the process on how to use it.

First, you need to add the dependency and load it in your code.
Add it to your `Cargo.toml`:

~~~toml
[dev-dependencies]
quickcheck = "0.2"
~~~

Add this to your `src/lib.rs`:

~~~rust
#[cfg(test)]
extern crate quickcheck;
~~~

Next, you need to decide what property to test.
As the compression library needs data to compress and _valid_ data to decompress,
I decided the easiest way to go through everything would be to test the round trip:
Compress some random input, then decompress the compressed data and check that it maches the initial input.
This should hold for all inputs, that can be compressed.
Everything that cannot be compressed can be ignored at this point (a first test allowing _all_ input turned up too many false-positives).

The property function looks like this:


~~~rust
use quickcheck::{quickcheck, TestResult};

fn compress_decompress_round(data: Vec<u8>) -> TestResult {
    let compr = match compress(&data) {
        Ok(compr) => compr,
        Err(LzfError::NoCompressionPossible) => return TestResult::discard(),
        Err(LzfError::DataCorrupted) => return TestResult::discard(),
        e @ _ => panic!(e),
    };

    let decompr = decompress(&compr, data.len()).unwrap();
    TestResult::from_bool(data == decompr)
}
~~~

Of course we need to test this.
QuickCheck handles the heavy part for us:

~~~rust
#[test]
fn qc_roundtrip() {
    quickcheck(compress_decompress_round as fn(_) -> _);
}
~~~

Running the tests immediately turned up a bug:

~~~
$ cargo test
running 13 tests
...
thread 'safe' panicked at 'index out of bounds: the len is 67 but the index is 67', ../src/libcollections/vec.rs:1187
test quickcheck_test::qc_roundtrip ... FAILED

failures:

---- quickcheck_test::qc_roundtrip stdout ----
    thread 'quickcheck_test::qc_roundtrip' panicked at '[quickcheck] TEST FAILED (runtime error). Arguments: ([0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 4, 0, 1, 1, 0, 1, 2, 0, 1, 3, 0, 1, 4, 0, 0, 5, 0, 0, 6, 0, 0, 7, 0, 0, 8, 0, 0, 9, 0, 0, 10, 0, 0, 11, 0, 1, 5, 0, 1, 6, 0, 1, 7, 0, 1, 8, 0, 1, 9, 0, 1, 10, 0, 0])
Error: "index out of bounds: the len is 67 but the index is 67"', /home/jer/.cargo/registry/src/github.com-88ac128001ac3a9a/quickcheck-0.2.27/src/tester.rs:116
~~~

It would be okay to return an error, but out-of-bounds indexing (and thus panicing) is a clear bug in the library.
Luckily, QuickCheck automatically collects the input the test failed on, tries to shrink it down to a minimal example and then displays it.
I figured this bug is happening in the compress step, so I added an explicit test case for that:

~~~rust
#[test]
fn quickcheck_found_bug() {
    let inp = vec![0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 4, 0, 1, 1, 0, 1, 2, 0, 1, 3, 0, 1, 4, 0, 0, 5, 0, 0, 6, 0, 0, 7, 0, 0, 8, 0, 0, 9, 0, 0, 10, 0, 0, 11, 0, 1, 5, 0, 1, 6, 0, 1, 7, 0, 1, 8, 0, 1, 9, 0, 1, 10, 0, 0];

    assert_eq!(LzfError::NoCompressionPossible, compress(&inp).unwrap_err());
}
~~~

Taking a look at the full stack trace (run `RUST_BACKTRACE=1 cargo test`) lead to the exact location of the bug.
Turns out I was checking the bounds on the wrong variable.
I fixed it in [88242ffe](https://github.com/badboy/lzf-rs/commit/88242ffef3b00423572db66318becd5206880d94).
After this fix, I re-run the QuickCheck tests and it discovered a second bug (`[0]` lead to another out-of-bounds access) and I fixed it in [5b2e8150](https://github.com/badboy/lzf-rs/pull/1/commits/5b2e81506e83a797519d5d85c776de296769fdd3).
I found a third bug, which I (hopefully) fixed, but I don't fully understand how it's happening yet.

Additionally to the above I added QuickCheck tests comparing the Rust functions to the output of the C library.
The full changeset is in [PR #1][pr] (currently failing tests, because of a broken Clippy on newest nightly).

Now quick, check your own code!

**Update 2016-05-13:** QuickCheck can be added as a dev dependency, instead of making it optional and activating it with a feature. Additionally it's necessary to `use` names from the crate (or specify the full path). Thanks to RustMeUp and burntsushi in the [reddit thread](https://www.reddit.com/r/rust/comments/4j2va3/quick_check_does_your_code_work/).

[pr]: https://github.com/badboy/lzf-rs/pull/1
