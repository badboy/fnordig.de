---
permalink: "/{{ year }}/{{ month }}/{{ day }}/build-your-project"
title: "Build your project"
published_date: "2020-06-19 13:46:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - rust
---

What if you could build a Rust project without Cargo?
It's not an actual problem I encountered.
It's still a problem I looked into.

> Cargo is the Rust package manager.
> Cargo downloads your Rust package’s dependencies, compiles your packages, makes distributable packages,
> and uploads them to crates.io, the Rust community’s package registry.
>
> _(from the [Cargo Book][cargo])_

That's a lot of work this tool does and it's very good at doing it.

I wanted to understand just the bit where it takes your Rust code and builds that into a binary that you can execute and run on your machine.
I didn't really want to read all of Cargo, so instead I turned to what Cargo itself tells me.
So I took the output of `cargo build --verbose` and turned that into simple build instructions.

What does it look like?

```
$ cargo build --verbose
[...]
   Compiling smallvec v1.4.0
   Compiling matches v0.1.8
   Compiling libc v0.2.71
     Running `rustc --crate-name smallvec --edition=2018 /Users/jer/.cargo/registry/src/github.com-1ecc6299db9ec823/smallvec-1.4.0/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts --crate-type lib --emit=dep-info,metadata,link -C debuginfo=2 -C metadata=d85954c5ff803feb -C extra-filename=-d85954c5ff803feb --out-dir /Users/jer/projects/rust/bygge/target/debug/deps -L dependency=/Users/jer/projects/rust/bygge/target/debug/deps --cap-lints allow`
     Running `rustc --crate-name libc /Users/jer/.cargo/registry/src/github.com-1ecc6299db9ec823/libc-0.2.71/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts --crate-type lib --emit=dep-info,metadata,link -C debuginfo=2 --cfg 'feature="default"' --cfg 'feature="std"' -C metadata=bbaef975a82234c8 -C extra-filename=-bbaef975a82234c8 --out-dir /Users/jer/projects/rust/bygge/target/debug/deps -L dependency=/Users/jer/projects/rust/bygge/target/debug/deps --cap-lints allow --cfg freebsd11 --cfg libc_priv_mod_use --cfg libc_union --cfg libc_const_size_of --cfg libc_align --cfg libc_core_cvoid --cfg libc_packedN`
[...]
     Running `rustc --crate-name bygge --edition=2018 src/main.rs --error-format=json --json=diagnostic-rendered-ansi --crate-type bin --emit=dep-info,link -C debuginfo=2 -C metadata=c1c12e33a54c5b24 -C extra-filename=-c1c12e33a54c5b24 --out-dir /Users/jer/projects/rust/bygge/target/debug/deps -C incremental=/Users/jer/projects/rust/bygge/target/debug/incremental -L dependency=/Users/jer/projects/rust/bygge/target/debug/deps --extern cargo_lock=/Users/jer/projects/rust/bygge/target/debug/deps/libcargo_lock-43ce509885ad1aff.rlib --extern cargo_toml=/Users/jer/projects/rust/bygge/target/debug/deps/libcargo_toml-5b6fff58e6c9a546.rlib --extern dirs=/Users/jer/projects/rust/bygge/target/debug/deps/libdirs-4eb870f2ccf6ed43.rlib --extern petgraph=/Users/jer/projects/rust/bygge/target/debug/deps/libpetgraph-7cb995dcfae4c1f7.rlib --extern pico_args=/Users/jer/projects/rust/bygge/target/debug/deps/libpico_args-03badf8072a773d9.rlib`
    Finished dev [unoptimized + debuginfo] target(s) in 30.82s
```

I removed a bunch of the output, but it all boils down to the same.
You can re-run these commands and you should end up with the same binary as the one Cargo puts into `target/debug/`.

You could put them all in a Makefile and use that to re-run them, but you would have gained nothing.
Changing your own code or adding, removing or updating dependencies won't be picked up unless you carefully specify all these dependencies in the Makefile
and update them when something changes.

We can automate that part.

Lately (again) I've been also reading about other build systems, such as [Ninja][ninja-essay] and was intrigued to rebuild that.
I haven't done that yet, but I decided to generate Ninja configuration to see how it behaves.

Let's combine these two things.

## The basic manual version

Let's work from a basic binary crate, with no dependencies and a single file.

```
$ cargo new --bin hello-world
     Created binary (application) `hello-world` package
$ cat
fn main() {
    println!("Hello, world!");
}
```

Building just that is easy:

```
$ rustc src/main.rs -o hello-world
$ ./hello-world
Hello, world!
```

If we rerun `rustc` it will re-build the code and generate a new file `hello-world` (that should be the same as the one from the first invocation).
That's a bit of extra work; if nothing changed we shouldn't need to rebuild.
Let's create a Ninja configuration file `build.ninja`:

```
# The build rule to invoke rustc.
# $in and $out are variables provided by ninja.
rule rustc
  command = rustc $in -o $out
  description = RUSTC $out

# Specifying dependencies:
# For `hello-world` to be build we invoke the above `rustc` rule with `src/main.rs` as $in
build hello-world: rustc src/main.rs
```

With [Ninja] installed we can build and run this:

```
$ ninja
[1/1] RUSTC hello-world
$ ./hello-world
Hello, world!
```

Re-running Ninja won't build it again:

```
$ ninja
ninja: no work to do.
```

Ninja knows that nothing changed and thus skips extra work.
If we modify the source it rebuilds:

```
$ echo >> src/main.rs
$ ninja
[1/1] RUSTC hello-world
$ ./hello-world
Hello, world!
```

We don't gain anything if we keep continuing writing a Ninja build configuration from hand.
Especially not once we add more files and some external crates.

## Bygge - build your project

Instead of writing out the whole Ninja file,
or coming up with some rules for Make that expand to the right files,
we can generate the build configuration once and then not touch it again until something changes.
That's exactly what Ninja was designed for:

> it is designed to have its input files generated by a higher-level build system, [...]
>
> _(from the [Ninja Website][ninja])_

After some more exploration with Cargo and the command lines it produces and the files it creates I managed to more-or-less auto-generate a Ninja configuration for a crate.

I've published this experiment as [bygge], the crate to build your crates (and itself).

### What it does

`bygge create` generates a Ninja build configuration (in `build.ninja` by default),
listing all the targets a binary crate depends on, including all crate dependencies.
`ninja` can then take this configuration and assemble the final binary.
The result should be about the same as an invocation of `cargo build`.

### What it doesn't

`bygge` is and never will be an alternative to Cargo.
Cargo is a full-fledged build system, aware of different build targets, allowing to enable features per dependency,
easily cross-compile to different targets and run the built programs as well as tests and generate documentation.

`bygge` ... builds.

### Features

* Builds cargo dependencies as listed in a project's Cargo.toml
* Can build only crates with a single binary target
* Runs on (at least) macOS and Linux
* No support for `build.rs` files
* No support for linking non-Rust libraries
* Hard-coded Cargo features for its dependencies
* Uses `cargo fetch` to download your project's dependencies

### Building bygge

Bygge is able to create a Ninja build configuration to build itself.
But first you need a compiled `bygge`.
It comes with a pre-generated configuration for that, that only works on my machine unless you change the paths to the local checkouts of the dependencies.

```
$ ninja -f manual.ninja
[29/29] RUSTC build/bygge
```

It builds a `build/bygge` file that is able to create the build configuration and run Ninja:

```
$ build/bygge create
==> Creating build file: build.ninja
==> Package: bygge
$ build/bygge build
[29/29] RUSTC build/bygge
$ build/bygge -V
bygge v0.1.0
```

You can also build it using `cargo build` and use `cargo run create` (or `target/debug/bygge create`) to create the `build.ninja` file.

And there you have it: a 300-line Ninja build configuration to build bygge.

[bygge]: https://github.com/badboy/bygge
[cargo]: https://doc.rust-lang.org/cargo/index.html
[ninja]: https://ninja-build.org/
[ninja-essay]: https://www.aosabook.org/en/posa/ninja.html
