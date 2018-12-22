---
permalink: "/{{ year }}/{{ month }}/{{ day }}/samsung-chromebook-a-short-review"
title: "Samsung Chromebook - a short review"
published_date: "2014-03-03 15:18:00 +0100"
layout: post.liquid
data:
  route: blog
---
One week ago I purchased a Chromebook. To be exact I purchased the Samsung
Chromebook 303c12 (the one without UMTS). It arrived on Tuesday.

I wanted a small second device for some day-to-day stuff. I already own a
tablet, but even with an external keyboard it is not the best option if you
want to do a little bit more multi-tasking or writing. As Chromebooks are
cheap and used devices can be bought for just over 100€, I went for it.

## Hardware

The Samsung Chromebook looks a lot like Macbooks, which is not bad at all. But
in contrast to Macbooks the complete case is plastic. It feels rather cheap and
is easily scratched. The keyboard thus is good. With its slightly unusual
layout including a Search key and other special keys it works perfectly inside
Chrome OS. Just one small problem: I couldn't set a nodeadkeys-layout, so `^`
or `~` takes two keystrokes to type. The screen has a good size and a
resolution of 1366x768, which is the same as my slightly bigger Thinkpad. From
my Thinkpad I was used to great colors no matter what perspective I had. Not so
with the Chromebook. The slightest tilt messes with the colors. I feel like I
need to be a lot more careful with this device than with my Thinkpad, but it's
not intended to be my outdoor and day-to-day device, so I'm fine with it.

## Software

This thing is booted damn fast. In just about 10-15 seconds from cold start it
is fully loaded and usable, if only suspended it's even faster. But in real
usage it's noticeable that it is powered by a slow ARM processor.
Sites load fast and are mostly lag-free, except from Google's own
social network Google+, which lags horribly.

As it uses Chrome OS there's an App for almost everything. Right now I use
[TextDown][] or [Text.app][] for writing, but I also came across [Poe][],
another Markdown editor with instant preview. Let's see what I stick with, I
have not decided yet. All of them lack a few things, but again all of them are
Chrome apps programmed in Javascript, so it's possible to extend them to my
needs.
Keep in mind that all installed applications and most settings are synced with
the Chrome instance on your desktop if that is linked to the same Google
account. This was a bit annoying at first, but I can live with that.

Apart from that I'm not totally happy with a browser-only environment, but
Chrome OS got you covered here as well. It comes with an usable shell in
Developer Mode. Booting into Developer Mode is as easy as hitting Esc, Reload
and Power, then hitting Ctrl+D in the Recovery screen, pressing it again and
waiting 15 minutes, letting the Chromebook do it's thing. Yeah, you get [the
idea][chrome-wiki].
The next thing I did was installing [crouton][], the "Chromium OS Universal
Chroot Environment".

Once this is done (and please don't fully shutdown the device, you would have
to go through all of this again), download the script, open a shell and execute
it. A few moments later you have a fully working Ubuntu-like chroot at your
hands. With this I now have a device with nearly everything I need (proper SSH
client, a shell, vim, …). If you do this as well, install [Crosh Window][] to
get a window for the shell itself, where things like Ctrl+W work as expected
(and don't close the window). Downside at the moment: umlauts are not supported in crosh.

With this device came an upgrade for Google Drive including 100 Gb of extra
space. Linux clients seem a bit limited at the moment. I only found Insync,
which costs 15$ once (and you're only informed about this _after_ you installed
the application and registered your account) and grive, which only syncs on
invocation and exits afterwards (no long-running sync-all-the-time mode). Thus
Google Drive is not a real option right now.

Another problem is: all my data is already shared through Dropbox, switching
to yet another Cloud storage comes with it's own problems. As there is still no
Arm client for Dropbox, using it in a chroot is not an option either.
For now I settled with [btsync][], the Torrent-powered Dropbox replacement.
It's still proprietary but the easiest option right now (and ARM-compatible).

Apart from the usual \*nix stuff there are some web apps I will try to use more
on this device, especially things like [Nitrous.IO][nitrous] or [Cloud9][c9]
for a development environment in the cloud.
And I need to clean up my config scripts for various things to make it more
easy to share them between devices.

## Conclusion

The Samsung Chromebook is a great, cheap device, which is quite good for most
things I need it for. The default OS is limited, but under the hood it's just
Linux, so with the right tools it can be used to its full extend.

[TextDown]: https://github.com/badboy/TextDown
[Crosh Window]: https://chrome.google.com/webstore/detail/nhbmpbdladcchdhkemlojfjdknjadhmh
[Text.app]: https://chrome.google.com/webstore/detail/mmfbcljfglbokpmkimbfghdkjmjhdgbg
[crouton]: https://github.com/dnschneid/crouton
[Poe]: https://chrome.google.com/webstore/detail/poe-markdown-editor/mpghdlgejmakmgbigejnjnmgdjaddhje
[chrome-wiki]: http://www.chromium.org/chromium-os/developer-information-for-chrome-os-devices/samsung-arm-chromebook
[nitrous]: https://www.nitrous.io/
[c9]: http://c9.io/
[btsync]: http://www.bittorrent.com/sync
