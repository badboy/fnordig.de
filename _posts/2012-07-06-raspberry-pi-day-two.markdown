---
layout: post
title: Raspberry Pi - Day 2
date: 06.07.2012 13:20
---

[Yesterday night](http://fnordig.de/2012/07/05/raspberry-pia-guick-guide-to-a-successfull-start/)
 I blogged about my first experience with the Raspberry Pi (forgive me the horrible typo in the title).


I made three notes on what's next:

* I need to check out [rpi-update](https://github.com/Hexxeh/rpi-update), for updating the firmware.
* Get video playing done right. I did not fully test it, but the video in the second image above was quiet slow.
* I want xbmc to run on my Raspberry Pi, because that’s what I bought it for: it should become my media computer in the living room.

## rpi-update

This is not needed on archlinuxarm, because there i a `raspberrypi-firmware` in the
[alarm repo](http://eu.mirror.archlinuxarm.org/arm/alarm/)

## video playing

I first installed the default `mplayer`-package, but video playing was horribly
slow, mp3 playing worked quite ok.

Again, [@bl2nk](http://twitter.com/bl2nk) to the rescue: Use [omxplayer][] instead.
Get the [binary package][omxplayer-aur] or just [build it yourself][omxplayer-git].

Works like a charm and does not even require a running X environment. Just execute the following over your always-open ssh connection:

    omxplayer -ohdmi -p video.mp4

and use Left, Right and Space for controlling. Playing the 720p version of [Fight Club](http://www.imdb.com/title/tt0137523/) works now.


## xbmc

There is no package for archlinuxarm (_yet?_), so I did not test it for now.
There are specific Raspberry Pi distributions linked in the
[xbmc wiki](http://wiki.xbmc.org/index.php?title=Raspberry_Pi).
I definitely need another SD card for this. :D

## other things.

Beside the 3 points mentioned above I got [redis][] compiled and running on the
Pi! Well, it does not make sense to use a in-memory database on a computer with
just 256 MB of RAM (and to be precise, right now I can only use half of that,
the other half is used for the GPU). But as I really like the project, I did this for the fun.

See the amazing [benchmark results in a gist](https://gist.github.com/3056659).


[omxplayer]: https://github.com/huceke/omxplayer
[omxplayer-aur]: https://aur.archlinux.org/packages.php?ID=59053
[omxplayer-git]: http://aur.archlinux.org/packages.php?ID=59770
[redis]: https://github.com/antirez/redis
