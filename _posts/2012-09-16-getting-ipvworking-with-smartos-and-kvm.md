extends: post.liquid
title: Getting IPv6 working with SmartOS and KVM
date: 16 Sep 2012 01:13:00 +0200
path: /:year/:month/:day/getting-ipvworking-with-smartos-and-kvm
route: blog
---

Just about 2 weeks ago I started to play around with [SmartOS][].

SmartOS is a fairly recent hypervisor for virtualization, open-sourced by
[Joyent][], the great guys behind [node.js][nodejs] in August 2011. It's based on [Illumos][], which
itself is a fork of [Solaris][].

The [wiki][] is a great place to get started as well as the [man page for vmadm][manpage].
Of course I found more articles and [saved them in my pinboard account][pinboard].

But one thing I did not really get to work was IPv6. After a while I found the
wiki page for [IPv6 in a zone][ipv6zone] which worked, atleast for SmartOS
zones.

But I had no luck with my KVM-based Ubuntu machine. I did it the same way,
using basic tools (`ifconfig/ip`, `/etc/network/interfaces`), but I could not
even ping the machine itself from within the page.

So I asked in the IRC channel (#smartos on freenode, great and friendly guys ;))

While IPv6-support is still not included in SmartOS tools itself [some patches for this exist][ip6patches].
This is only for zones and not for KVM instances, but I was told to check `dmesg` and other logs (d'oh! Why didn't I do this before?)

And this is what I found:

    eth0: IPv6 duplicate address detected!

A quick search turned up a [forum post][forumpost] which linked to [this blog post][duplicatefix].

The fix:

    sudo sysctl net.ipv6.conf.eth0.accept_dad=0

Put `net.ipv6.conf.eth0.accept_dad=0` into `/etc/sysctl.conf` to make it persistent.

This disables the Duplicate Address Detection.

After a reboot everything works and the machine works over IPv6.

When I talked to Eimann about this he directly knew another related problem and the explanation:

> If you're wondering why a Linux machine won't do v6 anymore when doing a
> (Cisco SPAN) monitor session over a VLAN which also hosts the default network:
> The machine sees some Neighbor-talking over the VLAN and switches to `dadfailed`
> effectively breaking the v6.



[smartos]: http://smartos.org/
[nodejs]: http://nodejs.org/
[illumos]: http://illumos.org
[solaris]: http://en.wikipedia.org/wiki/Solaris
[joyent]: http://joyent.com/
[wiki]: http://wiki.smartos.org/
[manpage]: https://github.com/joyent/smartos-live/blob/master/src/vm/man/vmadm.1m.md
[pinboard]: https://pinboard.in/u:badboy/t:smartos/
[ipv6zone]: http://wiki.smartos.org/display/DOC/Setting+up+IPv6+in+a+Zone
[ip6patches]: https://github.com/joshie/smartos-live/tree/ip6
[duplicatefix]: http://timesinker.blogspot.de/2009/11/karmic-ipv6-global-address-problems.html
[forumpost]: http://ubuntuforums.org/showthread.php?t=1410306
