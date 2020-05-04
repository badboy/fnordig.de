---
permalink: "/{{ year }}/{{ month }}/{{ day }}/this-week-in-glean"
title: "This Week in Glean: Bytes in Memory (on Android)"
published_date: "2020-05-04 15:30:00 +0200"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)

Last week's blog post: [This Week in Glean: Glean for Python on Windows](https://blog.mozilla.org/data/2020/04/27/this-week-in-glean-glean-for-python-on-windows/)
by Mike Droettboom.
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).

---

With the Glean SDK we follow in the footsteps of [other teams](https://github.com/mozilla/application-services) to build a cross-platform library to be used in both mobile and desktop applications alike.
In this blog post we're taking a look at how we transport some rich data across the FFI boundary to be reused on the Kotlin side of things.
We're using a recent example of a new API in Glean that will [drive the HTTP upload of pings](https://github.com/mozilla/glean/blob/8e0599b4df6c1a08f985e4ad5328fcf81a56a084/docs/dev/core/internal/upload.md),
but the concepts I'm explaining here apply more generally.

> *Note:* This blog post is not a good introduction on doing Rust on Android, but I do plan to write about that in the future as well.

Most of this implementation was done by [Bea](https://brizental.github.io/) and I have been merely a reviewer,
around for questions and currently responsible for running final tests on this feature.

## The problem

The Glean SDK provides an [FFI API](https://github.com/mozilla/glean/tree/master/glean-core/ffi) that can be consumed by what we call language bindings.
For the most part we pass <abbr title="Plain Old Data">POD</abbr> over that API boundary:
integers of various sizes (a problem in and of itself if the sides disagree about certain integer sizes and signedness),
bools (but actually encoded as an 8-bit integer[^1]),
but also strings as pointers to null-terminated UTF-8 strings in memory (for test APIs we encode data into JSON and pass that over as strings).

However for some internal mechanisms we needed to communicate a bit more data back and forth.
We wanted to have different _tasks_, where each task variant could have additional data.
Luckily this additional data is either some integers or a bunch of strings only and not further nested data.

So this is the data we have on the Rust side:

```rust
enum Task {
    Upload(Request),
    Wait,
    Done,
}

struct Request {
    id: String,
    url: String,
}
```

(This code is simplified for the sake of this blog post.
You can find the full code online [in the Glean repository](https://github.com/mozilla/glean/blob/8e0599b4df6c1a08f985e4ad5328fcf81a56a084/glean-core/src/upload/mod.rs#L38-L48).)

And this is the API a user would call:

```rust
fn get_next_task() -> Task
```

## The solution

Before we can expose a task through FFI we need to transform it into something C-compatible:

```rust
use std::os::raw::c_char;

#[repr(u8)]
pub enum FfiTask {
    Upload {
        id: *mut c_char,
        url: *mut c_char,
    },
    Wait,
    Done,
}
```

We define a new enum that's going to be represent its variant as an 8-bit integer plus the additional data for `Upload`.
The other variants stay data-less.

We also provide conversion from the proper Rust type to the FFI-compatible type:

```rust
impl From<Task> for FfiTask {
    fn from(task: Task) -> Self {
        match task {
            Task::Upload(request) => {
                let id = CString::new(request.id).unwrap();
                let url = CString::new(request.url).unwrap();
                FfiTask::Upload {
                    id: document_id.into_raw(),
                    url: path.into_raw(),
                }
            }
            Task::Wait => FfiTask::Wait,
            Task::Done => FfiTask::Done,
        }
    }
}
```

The FFI API becomes:

```rust
#[no_mangle]
extern "C" fn glean_get_next_task() -> FfiTask
```

With this all set we can throw [cbindgen] at our code to generate the C header, which will produce this snippet of code:

[cbindgen]: https://github.com/eqrion/cbindgen

```c
enum FfiTask_Tag {
  FfiTask_Upload,
  FfiTask_Wait,
  FfiTask_Done,
};
typedef uint8_t FfiTask_Tag;

typedef struct {
  FfiTask_Tag tag;
  char *id;
  char *url;
} FfiTask_Upload_Body;

typedef union {
  FfiTask_Tag tag;
  FfiTask_Upload_Body upload;
} FfiTask;
```

This is the C representation of a [tagged union](https://en.wikipedia.org/wiki/Tagged_union).
The layout of these tagged unions has been formally defined in [Rust RFC 2195](https://github.com/rust-lang/rfcs/blob/master/text/2195-really-tagged-unions.md).

Each variant's first element is the `tag`, allowing us to identify which variant we have.
cbindgen automatically inlined the `Wait` and `Done` variants: they are nothing more than a `tag`.
The `Upload` variant however gets its own struct.

On the Kotlin side of things we use [JNA (Java Native Access)][jna] to call C-like functions and interact with C types.
After some research by Bea we found that it already provides abstractions over C unions and structs
and we could implement the equivalent parts for our `Task` in Kotlin.

[jna]: https://github.com/java-native-access/jna

First some imports and replicating the variants our tag takes.

```java
import com.sun.jna.Structure
import com.sun.jna.Pointer
import com.sun.jna.Union

enum class TaskTag {
    Upload,
    Wait,
    Done
}
```

Next is the body of our `Upload` variant. It's a structure with two pointers to strings.
Kotlin requires some annotations to specify the order of fields in memory.
We also  inherit from `Structure`, a class provided by JNA, that will take care of reading from memory and making the data accessible in Kotlin.

```java
@Structure.FieldOrder("tag", "id", "url")
class UploadBody(
    @JvmField val tag: Byte = TaskTag.Done.ordinal.toByte(),
    @JvmField val id: Pointer? = null,
    @JvmField val url: Pointer? = null,
) : Structure() { }
```

And at last we define our union.
We don't need a field order, it's a union afterall, only one of the fields is valid at a time.

```java
open class FfiTask(
    @JvmField var tag: Byte = TaskTag.Done.ordinal.toByte(),
    @JvmField var upload: UploadBody = UploadBody()
) : Union() {
    class ByValue : FfiTask(), Structure.ByValue

    fun toTask(): Task {
        this.readField("tag")
        return when (this.tag.toInt()) {
            TaskTag.Upload.ordinal -> {
                this.readField("upload")
                val request = Request(
                    this.upload.id.getRustString(),
                    this.upload.url.getRustString()
                )
                Task.Upload(request)
            }
            TaskTag.Wait.ordinal -> Task.Wait
            else -> Task.Done
        }
    }
}
```

This also defines the conversion to a new Kotlin type that eases usage on the Kotlin side.
`getRustString` is a [small helper](https://github.com/mozilla/glean/blob/da1e014e378660f243b92ce6012b7b29188d72d8/glean-core/android/src/main/java/mozilla/telemetry/glean/rust/LibGleanFFI.kt#L40-L42)
to copy the null-terminated C-like string to a Kotlin string.

The FFI function on the Kotlin side is defined as:

```java
fun glean_get_next_task(): FfiTask.ByValue
```

The types we convert to and then work with in Kotlin are small classes around the data.
If there's no attached data it's an object.

```java
class Request(
    val id: String,
    val url: String,
) { }

sealed class Task {
    class Upload(val request: Request) : Task()

    object Wait : Task()

    object Done : Task()
}
```

As the final piece of this code on the Kotlin side we can now fetch new tasks, convert it to more convenient Kotlin objects and work with them:

```java
val incomingTask = LibGleanFFI.INSTANCE.glean_get_next_task()
when (val action = incomingTask.toTask()) {
    is Task.Upload -> upload(action.request.id, action.request.url)
    Task.Wait -> return Result.retry()
    Task.Done -> return Result.success()
}
```

## What's next?

Currently our new upload mechanism is under testing.
We're reasonably sure that our approach of passing rich data across the FFI boundary is sound and not causing memory safety issues for now.

The advantage of going the way of encoding Rust enums into tagged unions for us is that we can use this API in all our current API consumers.
C structs and unions are supported in Kotlin (for Android), Swift (for our iOS users) and Python (e.g. Desktop apps such as [mozregression](https://wlach.github.io/blog/2020/04/mozregression-for-macos/)).
It didn't require new tooling or dependencies to get it working and it's reasonably cheap in terms of processing cost (it's copying around a few bytes of data in memory).

The disadvantage however is that it requires quite a bit of coordination of the different pieces of code.
As you've seen above for Kotlin we need to be careful to replicate the exact layout of data and all of this is (currently) hand-written.
Any change on the Rust side might break this easily.
Swift is a bit easier on this front as it has direct C translation.

The application-services team faced the same problem of how to transport rich data across the FFI boundary.
They decided to go with protocol buffers and generate code for both sides of the FFI. They wrote about it in [Crossing the Rust FFI frontier with Protocol Buffers][hacks-protobuf].
We decided against this way (for now), as it requires a bit more of a heavy-handed setup initially.
We might reconsider this if we need to expand this API further.

My dream solution is still a `*-bindgen` crate akin to [wasm-bindgen] that creates all this code.

[hacks-protobuf]: https://hacks.mozilla.org/2019/04/crossing-the-rust-ffi-frontier-with-protocol-buffers/
[wasm-bindgen]: https://crates.io/crates/wasm-bindgen

<br>

---

[^1]: Don't use a bool with JNA. JNA doesn't handle it well and has its own conception of the size of a bool that differs from what C and Rust think. See [When to use what method of passing data between Rust and Java/Swift](https://mozilla.github.io/glean/book/dev/ffi/when-to-use-what-in-the-ffi.html#primitives) in the Glean SDK book.
