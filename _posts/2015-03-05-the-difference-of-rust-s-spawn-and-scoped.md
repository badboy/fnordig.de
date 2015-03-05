---
layout: post
title: "The difference of Rust's thread::spawn and thread::scoped"
date: 05.03.2015 14:41
---

So yesterday I gave a Rust introduction talk at the local hackerspace, [CCCAC](http://ccc.ac).
The slides are already [online](https://fnordig.de/talks/2015/cccac/rust-intro/).
The talk went pretty well and I think I could convince a few people why the ideas in Rust are actually useful.
Though I made one mistake in explaining a concurrency feature (see [slide 30](https://fnordig.de/talks/2015/cccac/rust-intro/#29)).
As it turns out, the example as I explained it was different from the presented code and one of the attendees actually asked me about it.

~~~rust
// Careful, this example is not quite right.
use std::thread;
use std::sync::{Arc, Mutex};

fn main() {
    let numbers = Arc::new(Mutex::new(vec![1, 2, 3]));

    for i in 0..3 {
        let number = numbers.clone();

        let _ = thread::scoped(|| {
            let mut array = number.lock().unwrap();

            array[i] += 1;

            println!("numbers[{}] is {}", i, array[i]);
        });
    }
}
~~~

I used this example to explain why it is necessary to wrap the vector in a mutex and the mutex in an Arc to make it possible to write to it from several threads.
The problem lies within the used thread abstraction: [thread::scoped](http://doc.rust-lang.org/nightly/std/thread/fn.scoped.html).

> Spawn a new scoped thread, returning a JoinGuard for it.
> The join guard can be used to explicitly join the child thread (via join), returning Result<T>, or it will implicitly join the child upon being dropped.

So in the case of the above code each thread is joined right after it was created and thus the threads don't even run concurrently, making the Arc and Mutex unnecessary. The following shortened example will still work, though not show casing what I intended to:

~~~rust
use std::thread;

fn main() {
    let mut numbers = vec![1, 2, 3];

    for i in 0..3 {
        let number = &mut numbers;

        let _ = thread::scoped(|| {
            number[i] += 1;

            println!("numbers[{}] is {}", i, number[i]);
        });
    }
}
~~~

There is another in-built threading method: [thread::spawn](http://doc.rust-lang.org/nightly/std/thread/fn.spawn.html). Its documentation reads:

> Spawn a new thread, returning a JoinHandle for it.
> The join handle will implicitly detach the child thread upon being dropped.

And this is actually what I need to correctly demonstrate what I wanted to: the use of Arc and Mutex to safely share writable access to shared memory through mutual exclusion. The following example works and has all necessary parts:

~~~rust
use std::thread;
use std::sync::{Arc, Mutex};

fn main() {
    let numbers = Arc::new(Mutex::new(vec![1, 2, 3]));

    let mut threads = vec![];
    for i in 0..3 {
        let number = numbers.clone();

        let cur = thread::spawn(move|| {
            let mut array = number.lock().unwrap();

            array[i] += 1;

            println!("numbers[{}] is {}", i, array[i]);
        });
        threads.push(cur);
    }

    for i in threads {
        let _ = i.join();
    }
}
~~~

Running it gives the expected output (your output might differ, the order is non-deterministic):

~~~shell
$ rustc concurrency.rs
$ ./concurrency
numbers[1] is 3
numbers[2] is 4
numbers[0] is 2
~~~

The Rust book contains a complete chapter on this topic: [Concurrency](http://doc.rust-lang.org/book/concurrency.html), covering a bit more of the background and also the Channel concept.

Again, thanks to the [CCCAC](http://ccc.ac) and for all people listening to me and quite some questions afterwards.
For all who could not attend: the video should be up soon.
