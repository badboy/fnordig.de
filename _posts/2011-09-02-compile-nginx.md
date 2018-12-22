---
permalink: "/{{ year }}/{{ month }}/{{ day }}/compile-nginx"
title: Compile nginx
published_date: "2011-09-02 00:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
I'm using [nginx][] as my main webserver and proxy for all my other projects (let it be node.js or ruby things).

Now that [ipv6][] is more and more used, I decided to let this blog get served over ipv6 as well.

Get nginx' latest version (1.0.6 at this time) from their [downloads section][download].
To compile nginx with ipv6 support all you need to do is let `configure` know about this (last line):

    ./configure \
      --prefix=/usr/local \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_gzip_static_module \
      --with-ipv6

Then compile and install it:

    make
    su -c 'make install'

Add this line to your nginx.conf:

    listen [::]:80;

Restart your server and it just works.


[nginx]: http://nginx.org/en/
[download]: http://nginx.org/en/download.html
[ipv6]: http://en.wikipedia.org/wiki/Ipv6
