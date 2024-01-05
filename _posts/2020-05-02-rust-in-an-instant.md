---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rust-in-an-instant"
title: "Rust in an instant"
published_date: "2020-05-02 14:43:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - rust
---

So I [tweeted](https://twitter.com/badboy_/status/1255802731241050112):

> This happened in an instant.
> I am not even sorry.

It included this snippet of Rust code:

```rust
use std::os::raw::{c_int, c_void};
use std::sync::atomic::{AtomicU64, Ordering::SeqCst};
use std::time::Instant;

#[repr(C)]
struct timespec {
    tv_sec: u64,
    tv_nsec: u64,
}

static TIME_COUNTER: AtomicU64 = AtomicU64::new(0);

#[no_mangle]
extern "C" fn clock_gettime(clk_id: *mut c_void, tp: *mut timespec) -> c_int {
    unsafe {
        let next_tick = TIME_COUNTER.fetch_add(1, SeqCst);
        (*tp).tv_sec = next_tick;
        (*tp).tv_nsec = 0;
        0
    }
}

fn main() {
    let a = Instant::now();
    let b = Instant::now();

    let diff = b.duration_since(a);
    println!("{:?}", diff);
}
```

([Playground link](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=37b788bbf396aed5ffdaf765ba76a780))

And I was then asked what that piece of code does:

> @varjmes: what am i seeing here? started reading the rust book yesterday :)

([Tweet](https://twitter.com/varjmes/status/1255803145013342208))

So let me explain.

First let's take this from a tweet-worthy piece of code to be more production ready with cross-platform support.
I'm on macOS most of the day. Let's add support for it:

```rust
#[cfg(all(unix, not(target_os = "macos")))]
use std::os::raw::{c_int, c_void};
use std::sync::atomic::{AtomicU64, Ordering::SeqCst};
use std::time::Instant;

#[cfg(all(unix, not(target_os = "macos")))]
#[repr(C)]
struct timespec {
    tv_sec: u64,
    tv_nsec: u64,
}

static TIME_COUNTER: AtomicU64 = AtomicU64::new(0);

#[cfg(all(unix, not(target_os = "macos")))]
#[no_mangle]
extern "C" fn clock_gettime(_clk_id: *mut c_void, tp: *mut timespec) -> c_int {
    unsafe {
        let next_tick = TIME_COUNTER.fetch_add(1, SeqCst);
        (*tp).tv_sec = next_tick;
        (*tp).tv_nsec = 0;
        0
    }
}

#[cfg(target_os = "macos")]
#[no_mangle]
extern "C" fn mach_absolute_time() -> u64 {
    const NANOSECONDS_IN_A_SECOND: u64 = 1_000_000_000;
    TIME_COUNTER.fetch_add(1, SeqCst) * NANOSECONDS_IN_A_SECOND
}

fn main() {
    let a = Instant::now();
    let b = Instant::now();

    let diff = b.duration_since(a);
    println!("{:?}", diff);
}
```

We can compile that:

```
rustc instant.rs
```

And then run it:

```
> ./instant
1s
```

What is happening here?

## Time is an illusion

Computers provide clock sources that allow a program to make assumptions about time passed.
If all you need is measure the time passed between some instant `a` and instant `b` the Rust libstd provides you with [Instant], a measurement of a monotonically nondecreasing clock
(I'm sorry to inform you that guarantees about [monotonically increasing clocks are lacking][monotonic]).
`Instant`s are an opaque thing and only good for getting you the difference between two of them, resulting in a [Duration].
Good enough if you can rely on the operating system to not lie to you.

[Instant]: https://doc.rust-lang.org/std/time/struct.Instant.html
[Duration]: https://doc.rust-lang.org/std/time/struct.Duration.html
[monotonic]: https://github.com/rust-lang/rust/blob/08dfbfb61871a83f720c6e97a3b737076e89fe3e/src/libstd/time.rs#L205-L232

How is `Instant` implemented?
That depends on the operating system your running your code on.
Luckily the documentation lists the (currently) used system calls to get time information.

| Platform[^1] | System Call |
| -------- | ----------- |
| UNIX     | [`clock_gettime`](https://linux.die.net/man/3/clock_gettime) (Monotonic Clock) |
| Darwin   | [`mach_absolute_time`]() |

([^1]: Trimmed down to the platforms I work on.)

So that's where Rust gets its time from.

## The operating system is an illusion

But how do we replace operating system functionality?
Turns out functions are merely a name and the linker tries to figure out where the code behind them is and then points to that.

If we look at a simpler version of our code without any `#[no_mangle] extern "C"` functions we can see where these come from:

```
(macOS) ❯ nm -a ./instant | rg mach_absolute_time
                 U _mach_absolute_time

(linux) ❯ nm -a instant | rg clock_gettime
                 U clock_gettime@@GLIBC_2.17
```

`nm` lists symbols from object files.
That `U` right there stands for _undefined_: The binary doesn't have knowledge where it comes from
(though in the case of Linux it gave it a slightly different name letting us guess what to expect).
Details about this symbol are later filled in, once your program is loaded and symbols to dynamic libaries are resolved
(and I'm sure the ["Making our own executable packer" series][linux-exe] by [@fasterthanlime](https://twitter.com/fasterthanlime) will have lots more details on it, I should go read it).

[linux-exe]: https://fasterthanli.me/blog/2020/whats-in-a-linux-executable/

What if we do that work before even running the program?

## Strings are strings, no matter what order

So now let's try to expose a function under the same name from our code.  
_Note: I'm only doing the macOS part here, it works the same for Linux._

If we start with the plain function like this:

```rust
fn mach_absolute_time() -> u64 {
    1
}
```

it will not turn up in the final binary at all and `rustc` right fully complains:

```
warning: function is never used: `mach_absolute_time`
```

Even making it `pub` won't work.
By default symbols such as function names get _mangled_; some additional information is encoded into the name as well and at the same time this ensures uniqueness of names
(see also [Name Mangling](https://en.wikipedia.org/wiki/Name_mangling)).
One can disable that in Rust using the `#[no_mangle]` attribute. So we apply that.

We're trying to override a function that is defined in terms of C.
C has slightly different calling conventions than Rust.
It's part of their respective ABIs: how data is passed in and out of functions.
In Rust one can define the used ABI with the `extern "name"` tag.
So we add that.

And thus we end up with

```rust
#[no_mangle]
extern "C" fn mach_absolute_time() -> u64 {
    1
}
```

If we compile our code again and look at the symbols we get this:


```
(macOS) ❯ nm -a ./instant | rg mach_absolute_time
0000000100000c20 T _mach_absolute_time
(linux) ❯ nm -a instant | rg clock_gettime
0000000000005250 T clock_gettime
```

Now we know that the symbol is defined somewhere in the binary ("T - The symbol is in the text (code) section.")
and also the location (_0000000100000c20_ / _0000000000005250_).

If this program is run it will still need to resolve undefined symbols ... but this time our functions are not undefined anymore.
As the stdlib just calls whatever is behind that respective name it now calls our code instead!

And yes, this works for pretty much all the functions defined by other libraries or libc:

```rust
use std::fs::File;
use std::os::raw::{c_char, c_int};

#[no_mangle]
extern "C" fn open(_path: *mut c_char, _flag: c_int) -> c_int {
    -1
}

fn main() {
    File::open("/etc/passwd").unwrap();
}
```

```
❯ rustc file.rs
❯ ./file
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Os { code: 0, kind: Other, message: "Undefined error: 0" }', file.rs:10:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Please don't do this.


---

If you liked this you might also like [STDSHOUT!!!1!](https://github.com/badboy/stdshout), I even [gave a talk about it](https://www.youtube.com/watch?v=YF6-g4YkyNY).
