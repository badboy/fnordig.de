permalink: "/{{ year }}/{{ month }}/{{ day }}/ipv6-with-nodejs"
title: IPv6 with NodeJS
published_date: "2011-01-26 00:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
As there are just a few new ipv4 address left in the pool and even those will be [exhausted in under a week](http://inetcore.com/project/ipv4ec/index_en.html) (6 days left, checked right now) the switch to [IPv6](http://en.wikipedia.org/wiki/Ipv6) will be necessary soon.

My current ISP does not offer any real IPv6 connection and not even my router can handle IPv6 (yet) there's currently no (good & easy) way for me to use IPv6 from here.

But aside from that fact, my vserver running this blog now has IPv6 addresses (and can even get more).

[v6.fnordig.de](http://v6.fnordig.de) is available via IPv6, but there's no service running yet.
I will make this blog accessible via IPv6 soon.

As I really like [node.js](http://nodejs.org/) I wanted to know how it handles v6 addresses and found [this article on code.danyork.com](http://code.danyork.com/2011/01/20/testing-node-js-with-ipv6-first-step-does-it-work/).

It's as easy as this:

    var http = require('http');
    var server = http.createServer(function (request, response) {
       response.writeHead(200, {"Content-Type":"text/plain"});
       response.end ("Hello World!\n");
       console.log("Got a connection");
    });
    server.listen(80, "2a01:xxxx:xxxx:xxxx::2");
    console.log("Server running on localhost at port 80");
{:lang="javascript"}

Just pass the IPv6 address as the host parameter to `server.listen`.
This listens on just one IP; it's possible to listen on all, similar to the `0.0.0.0` for IPv4:

    server.listen(80, "::0");
{:lang="javascript"}

Other things worth to mention:

* [World IPv6 Day](http://isoc.org/wp/worldipv6day/): major organisations (Google, Facebook, Yahoo, ...) will offer their content over IPv6 on 8 June, 2011

So get going and use IPv6!
