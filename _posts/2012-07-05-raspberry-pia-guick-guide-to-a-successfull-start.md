extends: post.liquid
title: Raspberry Pi - A guick guide to a successful start
date: 05 Jul 2012 00:27:00 +0200
path: /:year/:month/:day/raspberry-pia-guick-guide-to-a-successfull-start
route: blog
---

Today my [Raspberry Pi][pi] arrived and I quickly got it up and running.

Want to see some pictures?

[![Unboxing picture](http://tmp.fnordig.de/rasp-pi-1.jpg)](http://yfrog.com/oekjfbhj)
[![after basic setup](http://tmp.fnordig.de/rasp-pi-2.jpg)](http://yfrog.com/ocb24hfej)

Now that you've seen one in action, here is some info how I successfully setup
the Raspberry Pi.

> This won't be a full howto. This won't be a complete tutorial. It's more a
> collection of the things I done.  If you follow any of the commands here I'm
> not responsible.  It might kill your kitten, destroy your house and start the
> mayan apocalypse. Use it at your own risk. Have Fun! :) _(Shamelessly taken
> from the description of
> [VLC Beta](https://play.google.com/store/apps/details?id=org.videolan.vlc.betav7neon))_

## Prepare for boot

Before I could use my Raspberry I had to prepare my tools:

* Get a mini-usb cable (the one from my smartphone works perfect)
* Get a HDMI cable (got one for ~6€ at Amazon)
* Get a SD Card (again: Amazon, a Transcend 16 GB thing)
* A USB keyboard (and mouse). Got that.
* A LAN cable, I have several.

Next I needed an image to boot. I use the [archlinux image][alarm]. Get it from
the [download section][downloads].

Copying the image to the SD Card was easy:

    dd bs=1M if=archlinuxarm-29-04-2012.img of=/dev/mmcblk0

The image is prepared for a 2 GB card, so I had to expand the partitions. I
failed with `parted`, re-did the `dd`-commando and used gParted instead (see
[the wiki][resize] for instructions)

Putting the SD Card in the slot, adding the cables and it booted up! Yey!
I even got video output, atleast on my TV.

Not so on the other display. It always switched to standby without any chance
to get an output.

So again back to the laptop and edit `/boot/config.txt` (Thanks,
[@bl2nk](http://twitter.com/bl2nk), [more info about the file][config.txt]):

    # Force HDMI (including audio output)
    hdmi_drive=2

    # Use "safe mode" settings to try to boot with maximum hdmi compatibility.
    # This does:
    #   hdmi_force_hotplug=1
    #   config_hdmi_boost=4
    #   hdmi_group=1
    #   hdmi_mode=1
    #   disable_overscan=0
    hdmi_safe=1

Self-explaining, right?

Ok, so it boots up again, now with video output on the display here.
To bad there's no LAN port in my room.

## Network forwarding

This has nothing to do with the Raspberry Pi itself but with simple network forwarding.
I connected the Pi via LAN to my laptop which got it's internet connection via WLAN.

On my laptop I did these things to forward:

    ip addr add 192.168.10.1/24 dev eth0

    sysctl net.ipv4.ip_forward=1

    iptables -A FORWARD -o wlan0 -i eth0 -s 192.168.1.0/24 -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

On the Pi:

    ip link set eth0 up
    ip addr add 192.168.10.24/24 dev eth0
    ip route add default via 192.168.10.1
    echo "nameserver 8.8.8.8" > /etc/resolv.conf'

Now it works like a charm (I added this config to `rc.conf` so it works after boot).

## More installing on the Pi

All the previous steps were done as the root user. But for daily use we want an own user:

    adduser

(See the [arch wiki](https://wiki.archlinux.org/index.php/Beginners%27_Guide#Adding_a_User) for more info on that)

Now switch the user (or just re-login):

    su username

### Audio

To enable sound via alsa I installed the required libs and load the module:

    pacman -S alsa-lib alsa-utils
    modprobe snd-bcm2835

Then added `snd-bcm2835` to the MODULES section in `rc.conf` so it gets loaded after boot.

### GUI / X-Server

I know, I know: Hardcore Linux users don't need it, but it gets quite handy, so
I installed a GUI environment:

    # X server and i3 window manager
    pacman -S xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev i3-wm i3lock i3status
    echo 'exec i3' > ~/.xinitrc
    # Terminal emulator
    pacman -S rxvt-unicode urxvt-url-select
    # Oh yeah, some fonts would be great
    pacman -S ttf-bitstream-vera ttf-dejavu ttf-freefont ttf-liberation terminus-font

Everything in place, let's start X:

    startx

I won't show my basic i3 and i3status configuration here. [Feel free to ask][twitter]
if you've got any questions.

What's needed now? Right, everything for daily usage:

    pacman -S git mplayer tree scrot feh

Ok, what's left? A [browser][luakit].

    pacman -S luakit

That's it for now. The basic setup of my Pi is done.

    shutdown -h now

## What's next?

Oh, that's easy.

* I need to check out [rpi-update][], for updating the firmware.
* Get video playing done right. I did not fully test it, but the video in the
  second image above was quiet slow.
* I want [xbmc][] to run on my Raspberry Pi, because that's what I bought it for:
   it should become my media computer in the living room.

[pi]: http://www.raspberrypi.org/
[downloads]: http://www.raspberrypi.org/download
[luakit]: http://mason-larobina.github.com/luakit/
[rpi-update]: https://github.com/Hexxeh/rpi-update
[alarm]: http://archlinuxarm.org/
[resize]: http://elinux.org/RPi_Resize_Flash_Partitions
[config.txt]: http://elinux.org/RPi_config.txt
[twitter]: http://twitter.com/badboy_
[xbmc]: http://xbmc.org/
