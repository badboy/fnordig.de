permalink: "/{{ year }}/{{ month }}/{{ day }}/a-story-of-hacking-or-rust-on-the-psp"
title: "The story of my childhood or: Rust on the PSP"
published_date: "2014-12-03 20:03:00 +0100"
layout: post.liquid
data:
  route: blog
---
------

Don't care for all the stuff of my childhood? [↓ Head down](#more-rust) to see the Rust part

------

Let's do a time travel.

10 years back, it's 2004.
Sony releases the first version of the [Playstation Portable][wiki].
First in Japan, 4 months later in the US and yet another half year later in the EU (including Germany).

I read about this new little device in the autumn of 2004 and I knew immediately: I want this.
I also knew: I can't wait a whole year for it to get to the German market.
So 13-year old me sat down in front of his parent's PC and started searching through the depths of the internets.
Well, mostly Ebay, because that seemed to be the best place to get brand new hardware.

It must have been around January or February that I finally found a more or less trustworthy looking offer that was not too expensive.
Just 4 days after clicking *Buy* on Ebay my PSP finally arrived (yes, just 4 days shipping straight from Japan) and I could unpack it.

But I couldn't do much more. D'oh! The first firmware version on the PSP was quite limited.
It only supported WEP, luckily we still had WEP set up at home.
The next problem: it didn't even include a web browser yet, so even though I had a Wifi connection, I couldn't use it.
On to the next problem: Music and videos. Well, Music worked sort of (this was becoming my most expensive MP3 player at that time).
Videos were another story. It only supported MP4 in some weird encoding formats and the only way to get it on the PSP was by using a Memory Stick Pro, one of these tiny little memory cards that only Sony used. They were really expensive, the PSP came with a 32 MB card and I scraped together all my left pocket money to get a 128 MB card. Even back then that was quite limited space. So videos were off the hook as well.

Afterall the PSP was a gaming device, so I should be able to play right?
Yeah, actually for me that was a small afterthought, I didn't buy a game together with the PSP.
Off to Ebay again, luckily I found the original [Ridge Racer][ridgeracer], of course the Japanese version. Even now I would say: This was the best game ever released for the PSP. The graphics were astonishing, the music, the gameplay was fantastic, the rising dificulty of tracks and opponents promised hours of fun (and frustration).

While I played this game for hours, other people used their valuable time for far more important things: Hacking the PSP. Successfully.

Firmware 1.0 and 1.5 were exploited just 6 months after the first release.
What followed was the big uprise of the Homebrew scene. And I was part of it.
Younger me already knew some HTML, some (frontend) Javascript and I just learned C and C++.
I wanted to use that knowledge for my first own and publicly released apps!
The first step was getting the development toolchain set up.
I had an old 600 MHz computer, running Windows XP (I guess, or was it still Windows 98?)
The toolchain was based on GCC and was optimized for POSIX environments, which Windows clearly isn't,
but someone invested enough time to get it working on [cygwin][], including a nice one-click installer that did most of the work.
This was the time before Google Code and long before GitHub, so you had to download pre-compiled EXE files from one-click hoster sites.
The links could be found in one of the dozen forums that existed back then.
The whole process to setup Cygwin and the PSP toolchain on my slow computer took nearly 24 hours, so I had to leave the computer on over night (a novelty back then for me). And it failed quite often. So repeat and repeat until it finishes without any failure once.

In the end I got it working and went on developing for the PSP.
I learned C, I battled with C, I switched over to C++ and back to C, I threw in some Lua (Lua was one of the first bigger things fully ported to the PSP and thus the best option to quickly develop for the PSP).

The PSP scene was also the first online community I was part of.
I became a moderator and blogger of one of the bigger German PSP news sites, portable-news.de.
I became friends with people that later offered me my first job as a developer (thanks [@g33konaut][]),
 that I still see once or twice a year (thanks [@atsutane][]), and others that I never heard anything of again (I'm bad with names, I can't even remember much more from back then).

The biggest released application from my time as a PSP dev is probably the PSP Customizer.
A release post on [some french forum is still online][customizer0.5] and of course [v1.0 on the good old qj.net][customizer1.0].
The PSP Customizer could be used to change the boot screen, the menu backgrounds, change menu texts or dump and restore your flash registry (this contained some internal config I guess).
Nothing fancy, it was not even originally written by me (though I ended up rewritting most of it).
As the text on QJ suggests it was quite known around the community and people actually used it.
Sadly I don't have any code of it anymore.
It wasn't open source (before GitHub publishing code was really a big hassle), it wasn't even version-controlled.
I remember a day where I deleted the _whole_ project by mistake.
It must have been just before another release. I spent the whole night trying to recover as much as possible.
In the end I had to rewrite large parts off my head (luckily it wasn't the most complicated code).

I also wrote some other small applications, most of which I can't even remember.
What I can remember is a PoC of a round-based tactics game, written as a web app (HTML and some crude Javascript magic to work in the limited web browser on the PSP) and inspired by [Field Commander][]. I never finished it or showed it to anyone.

The only application I still have the source code of is the first-ever Twitter client for the PSP: [p-twit!][].
I published the code 5 years ago, probably one of the more horrible pieces of code I've got online.
The original p-twit! announcement:

> @badboy\_: tada! twitter via PSP! release soon
> ([tweet](https://twitter.com/badboy_/status/826911057))

That was also the last thing I wrote for the PSP.
I think 2008/2009 was also the time the homebrew scene slowed down.
My community place, portable-news.de, was dead, more and more devs lost interest, there was nothing entirely new to be done.
Smartphones became the new go-to hardware for small applications and fun games developed by people at home.

(More about the [homebrew history][history])

---

Jumping back to 2014.
I learned quite a lot more since my PSP homebrew days. I'm now studying computer science and working part-time as a developer. I write C, C++, Ruby, Javascript.
And most recently [I started learning Rust][first-experience].

<a id="more-rust"></a>
Then, on the 12th of November I was chilling on the balcony of the hotel on Hawaii, browsing the Internet, when I came across the following post on Reddit:

[**"Hello World" on a PSP via Rust!**][reddit-helloworld]

Actually it was nothing more than a picture showing a PSP executing some "Hello World" app.
Then some comments came in, including a link to [the code and instructions][helloworld-instructions].

As soon as I was back home, I grabbed my PSP, booted up a new virtual machine and installed the [psptoolchain][] (mostly the same hassle as in the old days, it just finishes a lot quicker).

First step: Re-compile and run p-twit. Yip, it works (ok, it starts. Of course the Twitter API is so closed these days, it wouldn't be able to do anything).

<center>
[![p-twit runs again](//tmp.fnordig.de/rust-on-psp/th-2014-11-24_11.54.27.jpg)](//tmp.fnordig.de/rust-on-psp/2014-11-24_11.54.27.jpg)
</center>

Second step: Follow the instructions from the [Gist][helloworld-instructions].

~~~
jer@psp-dev:~/rust-for-psp$ rustc hello.rs --target psp -lpspdebug -lpspdisplay -lpspge -lm -lc -lpspuser -lgcc
jer@psp-dev:~/rust-for-psp$ psp-fixup-imports hello
Error, no sceModuleInfo section found
~~~

D'oh! That didn't work.
I played around, tried all kinds of things, then gave up a little frustrated.

A few days later I talked to [luqmana][] in the Rust IRC channel.
He turned his Gist into a real repository, [rust-psp-hello][], including scripts and a Cargofile. Still, no luck for me.
Even after re-installing the toolchain several times on different machines I still faced the awful `Error, no sceModuleInfo section found` after every compile.


After some more tweaking, re-installing, compiling and chatting with luqmana it turns out: He's not using the same toolchain build as I do.
He simply used the pre-compiled [minpspw][] package
(*Update 04.12.2014*: Luqman informed me he does in fact built it himself from the minpspw svn, which in turn uses the psptoolchain I tried with first, so absolutely no idea why directly using it failed).
Once I grabbed that, the "Hello World" application compiled and ran! Success!

<center>
[![From Rust with love](//tmp.fnordig.de/rust-on-psp/th-2014-11-27_01.13.59.jpg)](//tmp.fnordig.de/rust-on-psp/2014-11-27_01.13.59.jpg)
</center>

The journey doesn't end here.
Only partly satisfied with what I had, I took some free time on a train ride to write a wrapper for the input handling.

<center>
[![Press X, press O](//tmp.fnordig.de/rust-on-psp/th-2014-11-28_12.25.50.jpg)](//tmp.fnordig.de/rust-on-psp/2014-11-28_12.25.50.jpg)
</center>

Now it's possible to react to user input with this simple piece of code:

~~~rust
let mut pad_data = ctrl::Input::new();

if pad_data.read_changed() {
  match pad_data.pressed_key() {
    Button::Cross => utils::debug_print("X pressed\n"),
      Button::Circle => utils::debug_print("O pressed\n"),
      Button::Triangle => utils::debug_print("TRIANGLE pressed\n"),
      Button::Square => utils::debug_print("SQUARE pressed\n"),
      Button::None => (),
      _ => utils::debug_print("unhandled keypress\n"),
  }
}
~~~

The full implementation is up in [my fork of rust-psp-hello][helloworld-fork].

There's still a lot I want to do now that I'm started:

* Implement wrappers for the missing libraries (display, wifi)
* Figure out a good (*Rusty*) API for these wrappers
* Get my own PSP to connect to a WiFi again (I'm not sure why but it won't connect to my home network)
* Figure out why the freshly compiled psptoolchain fails to link in the `sceModuleInfo` section
* Build something cool to present

I'd be happy if anyone wants to help or wants to know more. Just work on the repo (Pull Requests welcome) or drop me a message on Twitter or via email.
I'd also be happy to hear storys from others that developed for the PSP 5 or 7 or 9 years ago.

[wiki]: http://en.wikipedia.org/wiki/PlayStation_Portable
[luqmana]: https://github.com/luqmana/
[helloworld-fork]: https://github.com/badboy/rust-psp-hello
[ridgeracer]: http://en.wikipedia.org/wiki/Ridge_Racer_(2004_video_game)
[history]: http://en.wikibooks.org/wiki/PSP/Homebrew_History
[cygwin]: https://www.cygwin.com/
[p-twit!]: https://github.com/badboy/p-twit
[@g33konaut]: https://twitter.com/g33konaut
[@atsutane]: https://twitter.com/atsutane_
[customizer0.5]: http://www.logic-sunrise.com/forums/files/file/728-271-se-a-customizer-v05b-psp/
[customizer1.0]: http://dl.qj.net/psp/homebrew-applications/fw302-oe-customizer-v10.html
[Field Commander]: http://en.wikipedia.org/wiki/Field_Commander
[reddit-helloworld]: http://www.reddit.com/r/rust/comments/2m10id/hello_world_on_a_psp_via_rust/
[first-experience]: http://fnordig.de/2014/08/12/first-experience-with-rust/
[psptoolchain]: https://github.com/pspdev/psptoolchain
[helloworld-instructions]: https://gist.github.com/luqmana/ca2899134311f1bf919d
[minpspw]: http://sourceforge.net/projects/minpspw/
[rust-psp-hello]: https://github.com/luqmana/rust-psp-hello
