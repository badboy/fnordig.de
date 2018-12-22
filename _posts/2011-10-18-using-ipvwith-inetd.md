---
permalink: "/{{ year }}/{{ month }}/{{ day }}/using-ipvwith-inetd"
title: using ipv6 with inetd
published_date: "2011-10-18 10:58:00 +0200"
layout: post.liquid
data:
  route: blog
---
I am the administrator of the [ctdo][] own jabber server over at `jabber.ctdo.de`.
It is currently running on the old but working [jabberd][] and also hosts a [bitlbee] server on several ports including ssl-protected ones.

Now that the world is migrating to IPv6 I wanted to make every single service on this machine available on IPv6, too.

Not that easy for old, never-really-updated software.
Complete taking down the machine and reinstalling everything was not an option, so I just updated jabberd to the latest version (back in spring).

By default the jabber server listens on all IPv6 addresses of the host machine, so all I needed to do here was enabling ssl-serving over IPv6 for it:

    <tls port="5223">2001:0db8:85a3:08d3:1319:8a2e:0370:7344</tls>
{:lang="text"}
(this is a completeley random ipv6 addresses ;)

Now to the "hard" part: the bitlbee thing.
As bitlbee does not speak ssl itself, it makes use of [stunnel][], a small SSL tunneling proxy.
Now stunnel and bitlbee are not just started on boot, but handled by [inetd][], a super-server daemon listening on ports and starting associated programs on need.

But, as I told before, the server is a rather old installation and uses `netkit-inetd`, which, as to my testings, does not work over IPv6.

So I had to replace this one:

    apt-get install netbsd-inetd
{:lang="text"}

One line in `/etc/inetd.conf` reads as the following:

    9999 stream tcp nowait bitlbee /usr/bin/stunnel stunnel -v 0 -l /usr/sbin/bitlbee
{:lang="text"}

This needs to be duplicated and changed to listen on v6, too.

    9999 stream tcp6 nowait bitlbee /usr/bin/stunnel stunnel -v 0 -l /usr/sbin/bitlbee
{:lang="text"}

And that's it.

    /etc/init.d/netbsd-inetd start
    /etc/init.d/jabberd14 restart
{:lang="text"}

and you should be ready to go.

This is live right now on `jabber.ctdo.de`.



[ctdo]: http://ctdo.de/
[jabberd]: http://jabberd.org/
[bitlbee]: http://www.bitlbee.org/main.php/news.r.html
[stunnel]: http://www.stunnel.org/
[inetd]: http://en.wikipedia.org/wiki/Inetd
