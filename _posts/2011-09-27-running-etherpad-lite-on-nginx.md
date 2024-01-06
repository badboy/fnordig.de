---
permalink: "/{{ year }}/{{ month }}/{{ day }}/running-etherpad-lite-on-nginx"
title: "running etherpad-lite on nginx"
published_date: "2011-09-27 21:24:00 +0200"
layout: post.liquid
data:
  route: blog
---
As you should already know if you read this blog, I am using [nginx][] as my main http server as well as a reverse proxy for my apps running on node.js or simple ruby.

I'm also running an [etherpad-lite][etherpad] server on [pad.fnordig.de](https://pad.fnordig.de/).

Today [@dasjan][] asked me how I configured my server for this setup:

> @badboy_ Sehe gerade du hast dein etherpad-lite hinter nginx.
> Hast du etwas spezielles konfiguriert?
> ([tweet](https://twitter.com/dasjan/status/118688611980943360))
> _translated_: @badboy_ I saw that you run your etherpad-lite behind a nginx.
> Did you configure anything special?

and

> @badboy_ Bekomme hier nach ein paar Stunden immer Connection Probleme wenn etherpad-lite hinter nginx läuft/
> _translated_: @badboy_ I always get connection problems after some hours when running behind nginx
> ([tweet](https://twitter.com/dasjan/status/118689122452897793))

Even though I did nothing special I post my config here, so maybe this will help.

I currently use nginx [v1.0.6](http://nginx.org/download/nginx-1.0.6.tar.gz)
and
etherpad-lite at [7e4bba0e](https://github.com/ether/etherpad-lite/commit/7e4bba0e31d600a5d1d3833211252b1472f07f2c) with the default config (and node.js v0.4.8)
etherpad runs as an own user named `etherpad` and is monitored by monit.

The monitoring is as simple as that, `/etc/monit/apps/etherpad.monit`:

```
check process etherpad
  with pidfile /var/run/etherpad-lite.pid
  start program = "/home/etherpad/etherpad-lite/daemon.sh start"
  stop program = "/home/etherpad/etherpad-lite/daemon.sh stop"
  if totalmem is greater than 300 MB for 10 cycles then restart  # eating up memory?
```

And the nginx is nothing fancy at all, `/usr/local/nginx/conf/vhosts/pad.fnordig.de.conf`:

```
server {
    listen  80;
    listen  [::]:80;
    listen  443 ssl;
    ssl_certificate      /var/certs/star_fnordig_signed.pem;
    ssl_certificate_key  /var/certs/star_fnordig_signed.pem;

    server_name  pad.fnordig.de;

    access_log  /home/etherpad/etherpad-lite-log/eplite.access.log;
    error_log   /home/etherpad/etherpad-lite-log/eplite.error.log;

    location / {
        proxy_pass             http://localhost:9001/;
        proxy_set_header       Host $host;
        proxy_buffering off;
    }
}
```

My etherpad is currently running for about 22 days without any problems. I don't really use it myself and have no current statistics on outside usage of [pad.fnordig.de](https://pad.fnordig.de/).

Now that [@dasjan][] has mentioned problems on his side I will optimize my monitoring and see if it really runs as smooth as I think.

[nginx]: http://nginx.org/en/
[etherpad]: https://github.com/Pita/etherpad-lite
[@dasjan]: https://twitter.com/dasjan
