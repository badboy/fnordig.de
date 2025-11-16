---
permalink: "/{{ year }}/{{ month }}/{{ day }}/bytebeats"
title: "Overengineering a one-line music formula player"
published_date: "2025-11-16 23:00:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  Intrigued by algorithmic symphonies from one line of code
  I completely overengineered a compiler that takes in
  a (binary) arithmetic expression and turns that into a program that generates sound.
---

The other week I read a [blog post about a bytebeat player in Zig][zig-bytebeat].
"Bytebeats" is music generated from short programs.
That might be just:


```
t
```

<audio controls src="https://tmp.fnordig.de/bytebeat/t.ogg"></audio>

or something a bit more complex:

```
t*(42&t>>10)
```

<audio controls src="https://tmp.fnordig.de/bytebeat/formula42.ogg"></audio>

Apparently the blog post [Algorithmic symphonies from one line of code -- how and why?][initial-blogpost] started it all in 2011.
The same author later did a [deeper analysis][deep-analysis] of the patterns involved.

I was intrigued enough to implement my own tool to play these melodies.
Obviously I had to absolutely overengineer this.

So my solution is a full parsing & compilation pipeline to transform short arithmetic formulas to sounds.
`bytebeats` compiles a formula to native code and calls it at runtime to feed into the sound output,
or an audio file.

```
   Formula expression
           │
           ▼
   ┌────────────────┐
   │     Parser     │
   └───────┬────────┘
           │  (transform to QBE IR)
           │
           ▼
   ┌────────────────┐
   │      QBE       │
   └───────┬────────┘
           │  (transform to asm)
           │
           ▼
   ┌────────────────┐
   │   assembler    │
   └───────┬────────┘
           │
           ▼
      object file
           ┬
           │  (extract synth fn)
           │
           ▼
   ┌────────────────┐
   │ load synth fn  │
   └───────┬────────┘
           │
           ▼
 ┌────────────────────┐
 │ t in 0..n:         │
 │     play(synth(t)) │
 └────────────────────┘
```

And it works. All sounds here are generated based of the formulas posted along with it.
I did not come up with any formula, but copied them from the blog posts or [the full list][long-list].

```
((t>>4)*(13&(0x8898a989>>(t>>11&30)))&255)+((((t>>9|(t>>2)|t>>8)*10+4*((t>>2)&t>>15|t>>8))&255)>>1)
```

At 8 kHz:

<audio controls src="https://tmp.fnordig.de/bytebeat/long.ogg"></audio>

At 44.1 kHz:

<audio controls src="https://tmp.fnordig.de/bytebeat/long_44.1k.ogg"></audio>


```
t*(0xCA98>>(t>>9&14)&15)|t>>8
```

At 8 kHz:

<audio controls src="https://tmp.fnordig.de/bytebeat/0xca98.ogg"></audio>

At 44.1 kHz:

<audio controls src="https://tmp.fnordig.de/bytebeat/0xca98_44.1k.ogg"></audio>

---

The parser is based on the [pest calculator parser example][pest].
[QBE] is used as a compiler backend.
The parsed formula is transformed directly to QBE IR, wrapped in a function block,
then QBE takes care of compiling that to assembly for the target platform (whatever your machine is running).
I have tested it on arm64 (my macOS machine) and amd64 (my `x86_64` Linux machine).
The compiler output is passed to [as] to assemble it to machine code.
From the resulting object file the few bytes making up the single function we put in there are extracted, all in memory
(I implemented it for the Elf and mach-o formats using [goblin]).
Reusing pieces of [dynasmrt] the function bytes are transmuted to a function pointer that Rust can call.

With all of that together I then used [rodio] to play some tunes by iterating and calling the generated function with increasing values of `t`.
Immediate playback is not the only option, instead sounds can be stored directly into WAVE files, using [hound] under the hood.
And for easier distribution re-encoding to Ogg is possible using [FFmpeg].

The full code is available in [my bytebeat repository][repo].
It comes fully equipped with a REPL to try out many formulas as you go.

You can install it using Cargo:

```
cargo install --git https://git.fnordig.de/jer/bytebeats
```

[repo]: https://git.fnordig.de/jer/bytebeat
[zig-bytebeat]: https://blog.karanjanthe.me/posts/zig-beat/
[initial-blogpost]: http://countercomplex.blogspot.com/2011/10/algorithmic-symphonies-from-one-line-of.html
[deep-analysis]: http://viznut.fi/texts-en/bytebeat_deep_analysis.html
[long-list]: https://web.archive.org/web/20120301055914/http://pelulamu.net/countercomplex/music_formula_collection.txt
[pest]: https://pest.rs/book/examples/calculator.html
[qbe]: https://c9x.me/compile/
[as]: https://www.man7.org/linux/man-pages/man1/as.1.html
[goblin]: https://crates.io/crates/goblin
[rodio]: https://crates.io/crates/rodio
[hound]: https://crates.io/crates/hound
[dynasmrt]: https://crates.io/crates/dynasmrt
[ffmpeg]: https://ffmpeg.org/
