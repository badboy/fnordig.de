---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rust-libraries-on-ios"
title: "This Week in Glean: Building and Deploying a Rust library on iOS"
published_date: "2022-01-31 12:40:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
excerpt: |
  We ship the Glean SDK for multiple platforms, one of them being iOS applications.
  Previously I talked about how we got it to build on the Apple ARM machines.
  Today we will take a closer look at how we bundle a Rust static library
  into an iOS application.
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work.
They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)
All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog][datablog].

[datablog]: https://blog.mozilla.org/data/TODO

---

We ship the Glean SDK for multiple platforms, one of them being iOS applications.
Previously I talked about [how we got it to build on the Apple ARM machines](/2021/04/16/rustc-ios-and-an-m1/).
Today we will take a closer look at how to bundle a Rust static library into an iOS application.

The Glean SDK project was set up in 2019 and we have evolved its project configuration over time.
A lot has changed in Xcode since then, so for this article we're starting with a fresh Xcode project, a fresh Rust library and put it all together step by step.  
This is essentially an update to the [Building and Deploying a Rust library on iOS][old-article] article from 2017.

For future readers: This was done using Xcode 13.2.1 and rustc 1.58.1.  
_One note: I learned iOS development to the extent required to ship Glean iOS.
I've never written a full iOS application and lack a lot of experience with Xcode._

[old-article]: https://mozilla.github.io/firefox-browser-architecture/experiments/2017-09-06-rust-on-ios.html

## The application

The premise of our application is easy:

> Show a non-interactive message to the user with data from a Rust library.

Let's get started on that.

## The project

We start with a fresh iOS project.
Go to File -> New -> Project, then choose the iOS App template,
give it a name such as `ShippingRust`,
select where to store it and finally create it.
You're greeted with `ContentView.swift` and the following code:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}
```

You can build and run it now. This will open the Simulator and display "Hello, world!".
We'll get back to the Swift application later.

## The Rust parts

First we set up the Rust library.

In a terminal navigate to your `ShippingRust` project directory.
In there create a new Rust crate:

```
cargo new --lib shipping-rust-ffi
```

We will need a static library, so we change the crate type in the generated `shipping-rust-ffi/Cargo.toml`.
Add the following below the package configuration:

```
[lib]
crate-type = ["staticlib"]
```

Let's also turn the project into a Cargo workspace.
Create a new top-level `Cargo.toml` with the content:

```
[workspace]
members = [
  "shipping-rust-ffi"
]
```

`cargo build` in the project directory should work now and create a new static library.

```
; ls -l target/debug/libshipping_rust_ffi.a
-rw-r--r-- 2 jer staff 16061952 Jan 28 13:09 target/debug/libshipping_rust_ffi.a
```

Let's add some code to `shipping-rust-ffi/src/lib.rs` next.
Nothing fancy, a simple function taking some arguments and returning the sum:

```rust
use std::os::raw::c_int;

#[no_mangle]
pub extern "C" fn shipping_rust_addition(a: c_int, b: c_int) -> c_int {
    a + b
}
```

The `no_mangle` ensures the name lands in the compiled library as-is
and the `extern "C"` makes sure it uses the right ABI.

We now have a Rust library exporting a C-ABI compatible interface.
We can now consume this in our iOS application.

## The Xcode parts

Before we can use the code we need a bit more setup.
Strap in, there's a lot of fiddly manual steps now[^1].

We start by linking against the `libshipping_rust_ffi.a` library.
In your Xcode project open your target configuration[^2],
go to "Build Phases", then look for "Link Binary with Libraries".
Add a new one, in the popup select "Add files" on the bottom left
and look for the `target/debug/libshipping_rust_ffi.a` file.
Yes, that's actually for the wrong target. This is just for the name, we'll fix up the path next.
Go to "Build Settings" and search for "Library Search Paths".
It probably has the path to file in there right now for both `Debug` and `Release` builds.
Remove that one for `Debug`, then add a new row by clicking the small `+` symbol.
Select the `Any Driverkit` matcher.
It doesn't matter which matcher you choose or what value you give it,
but when we overwrite this manually in the next step I'll assume you chose `Any Driverkit`.
Do the same for the `Release` configuration.

Once that's done, save your project and go back to your project directory.
We will modify the project configuration to have Xcode look for the library based on the target it is building for[^3].
Open up `ShippingRust.xcodeproj/project.pbxproj` in a text editor,
then search for the first line with `"LIBRARY_SEARCH_PATHS[sdk=driverkit*]"`.
It should be in a section saying `/* Debug */`.
Remove the `LIBRARY_SEARCH_PATHS` line and add 3 new ones:

```
"LIBRARY_SEARCH_PATHS[sdk=iphoneos*][arch=arm64]" = "$(PROJECT_DIR)/target/aarch64-apple-ios/debug";
"LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*][arch=arm64]" = "$(PROJECT_DIR)/target/aarch64-apple-ios-sim/debug";
"LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*][arch=x86_64]" = "$(PROJECT_DIR)/target/x86_64-apple-ios/debug";
```

Look for the next line with `"LIBRARY_SEARCH_PATHS[sdk=driverkit*]"`, now in a `/* Release */` section and replace it with:

```
"LIBRARY_SEARCH_PATHS[sdk=iphoneos*][arch=arm64]" = "$(PROJECT_DIR)/target/aarch64-apple-ios/release";
"LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*][arch=arm64]" = "$(PROJECT_DIR)/target/aarch64-apple-ios-sim/release";
"LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*][arch=x86_64]" = "$(PROJECT_DIR)/target/x86_64-apple-ios/release";
```

Save the file and return focus back to Xcode.
If you didn't make any typos Xcode should still have your project open.
In the settings you will find the library search paths as we've just defined them.
If you messed something up Xcode will complain that it cannot read the project file if you try to go to the settings.

Next we need to teach Xcode how to compile Rust code.
Once again go to your target settings, selecting the "Build Phases" tab again.

There add a new "Run Script" phase, give it the name "Build Rust library"
(double-click the "Run Script" section header),
and set the command to:

```
bash ${PROJECT_DIR}/bin/compile-library.sh shipping-rust-ffi $buildvariant
```

The `compile-library.sh` script is going to do the heavy lifting.
The first argument is the crate name we want to compile, the second is the build variant to select.
This is not yet defined, so let's do it first.

Go to the "Build Settings" tab and click the `+` button to add a new "User-Defined Setting".
Give it the name `buildvariant` and choose a value based on the build variant: `debug` for `Debug` and `release` for `Release`.

Now we need the actual script to build the Rust library for the right targets.
It's a bit long to write out, but the logic is not too complex:
First we select the Cargo profile to use based on our `buildvariant` (that is whether to pass `--release` or not),
then we set up `LIBRARY_PATH` if necessary and finally compile the Rust library for the selected target.
Xcode passes the architectures to build in `ARCHS`.
It's either `x86_64` for simulator builds on Intel Mac hardware or `arm64`.
If it's `arm64` it can be either the simulator or an actual hardware target.
Those differ, but we can know which is which from what's in `LLVM_TARGET_TRIPLE_SUFFIX` and select the right Rust target.

Let's put all of that into a `compile-library.sh` script.
Create a new directory `bin` in your project directory.
In there create the file with the following content:

```bash
#!/usr/bin/env bash

if [ "$#" -ne 2 ]
then
    echo "Usage (note: only call inside xcode!):"
    echo "compile-library.sh <FFI_TARGET> <buildvariant>"
    exit 1
fi

# what to pass to cargo build -p, e.g. your_lib_ffi
FFI_TARGET=$1
# buildvariant from our xcconfigs
BUILDVARIANT=$2

RELFLAG=
if [[ "$BUILDVARIANT" != "debug" ]]; then
  RELFLAG=--release
fi

set -euvx

if [[ -n "${DEVELOPER_SDK_DIR:-}" ]]; then
  # Assume we're in Xcode, which means we're probably cross-compiling.
  # In this case, we need to add an extra library search path for build scripts and proc-macros,
  # which run on the host instead of the target.
  # (macOS Big Sur does not have linkable libraries in /usr/lib/.)
  export LIBRARY_PATH="${DEVELOPER_SDK_DIR}/MacOSX.sdk/usr/lib:${LIBRARY_PATH:-}"
fi

IS_SIMULATOR=0
if [ "${LLVM_TARGET_TRIPLE_SUFFIX-}" = "-simulator" ]; then
  IS_SIMULATOR=1
fi

for arch in $ARCHS; do
  case "$arch" in
    x86_64)
      if [ $IS_SIMULATOR -eq 0 ]; then
        echo "Building for x86_64, but not a simulator build. What's going on?" >&2
        exit 2
      fi

      # Intel iOS simulator
      export CFLAGS_x86_64_apple_ios="-target x86_64-apple-ios"
      $HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib $RELFLAG --target x86_64-apple-ios
      ;;

    arm64)
      if [ $IS_SIMULATOR -eq 0 ]; then
        # Hardware iOS targets
        $HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib $RELFLAG --target aarch64-apple-ios
      else
        $HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib $RELFLAG --target aarch64-apple-ios-sim
      fi
  esac
done
```

And now we're done with the setup for compiling the Rust library automatically as part of the Xcode project build.

## The code parts

We now have an Xcode project that builds our Rust library and links against it.
We now need to use this library!

Swift speaks Objective-C, which is an extension to C,
but we need to tell it about the things available.
In C land that's done with a header.
Let's create a new file, select the "Header File" template and name it `FfiBridge.h`.
This will create a new file with this content:

```c
#ifndef FfiBridge_h
#define FfiBridge_h


#endif /* FfiBridge_h */
```

Here we need to add the definition of our function.
As a reminder this is its definition in Rust:

```rust
extern "C" fn shipping_rust_addition(a: c_int, b: c_int) -> c_int;
```

This translates to the following in C:

```c
int shipping_rust_addition(int a, int b);
```

Add that line between the `#define` and `#endif` lines.
Xcode doesn't know about that file yet, so once more into the `Build Settings` of the target.
Search for `Objective-C Bridging Header` and set it to `$(PROJECT_DIR)/ShippingRust/FfiBridge.h`.
In `Build Phases` add a new `Header Phase`.
There you add the `FfiBridge.h` as well.

If it now all compiles we're finally ready to use our Rust library.

Open up `ContentView.swift` and change the code to call your Rust library:

```
struct ContentView: View {
    var body: some View {
        Text("Hello, world! \(shipping_rust_addition(30, 1))")
            .padding()
    }
}
```

We simply interpolate the result of `shipping_rust_addition(30, 1)` into the string displayed.

Once we compile and run it in the simulator we see we've succeeded at satisfying our premise:

> Show a non-interactive message to the user with data from a Rust library.

![iOS simulator running our application showing "Hello, world! 31"](https://tmp.fnordig.de/blog/2022/ios-simulator-helloworld31.png)

Compiling for any iOS device should work just as well.

## The next steps

This was a lot of setup for calling one simple function.
Luckily this is a one-time setup. From here on you can extend your Rust library, define them in the header file and call them from Swift.
If you go that route you should really start using [cbindgen] to generate that header file automatically for you.

This time we looked at building an iOS application directly calling a Rust library.
That's not actually how Glean works. The Glean Swift SDK itself wraps the Rust library and exposes a Swift library.
In a next blog post I'll showcase how we ship that as a Swift package.

For Glean we're stepping away from manually writing our FFI functions.
We're instead migrating our code base to use [UniFFI].
UniFFI will generate the C API from an API definitions file and also comes with a bit of runtime code to handle conversion between Rust, C and Swift data types for us.
We're not there yet for Glean, but you can try it on your own. [Read the UniFFI documentation][uniffi-docs] and integrate it into your project.
It should be possible to extent the setup we done her to also run the necessary steps for UniFFI.
Eventually I'll document how we did it as well.

[cbindgen]: https://github.com/eqrion/cbindgen
[uniffi]: https://github.com/mozilla/uniffi-rs/
[uniffi-docs]: https://mozilla.github.io/uniffi-rs/

---

_Footnotes:_

[^1]: And most of these steps are user-interface-dependent and might be different in future Xcode version. :(  
[^2]: Click your project name in the tree view on the left. This gets you to the project configuration (backed by the `ShippingRust.xcodeproj/project.pbxproj` file). You should then see the Targets, including your `ShippingRust` target and probably `ShippingRustTests` as well. We need the former.  
[^3]: Previously we would have built a universal library containing the library of multiple targets. That doesn't work anymore now that `arm64` can stand for both the simulator and hardware targets. Thus linking to the individual libraries is the way to go, as the now-deprecated [`cargo-lipo`][cargo-lipo] also points out.

[cargo-lipo]: https://github.com/TimNN/cargo-lipo
