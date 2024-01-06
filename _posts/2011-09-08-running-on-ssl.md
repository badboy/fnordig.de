---
permalink: "/{{ year }}/{{ month }}/{{ day }}/running-on-ssl"
title: running on ssl
published_date: "2011-09-08 00:31:00 +0200"
layout: post.liquid
data:
  route: blog
---
Even though the [SSL][] and [CA][] system is totally broken right now, I finally got my blog as well as my [etherpad][] served over SSL:

* [https://fnordig.de][https]
* [https://pad.fnordig.de][pad]

My SSL certificate is signed by [cacert][] (they approved me at last year's FrOSCon).

If you're using nginx, all you need to do is adding the following lines to your config:

```
listen  443 ssl;
ssl_certificate      /path/to/your/cert.pem;
ssl_certificate_key  /path/to/your/key.pem;
```


If you followed some of the latest news around the scene, you probably heard of the [diginotar debacle][diginotar]. This should make clear how broken the system is and how unsecure these SSL certificates can be with all those CAs around.

For more information on the CA system and how it could be replaced by a more robust and secure infrastructure watch [SSL And The Future Of Authenticity][blackhat] by [Moxie Marlinspike][moxie] from this year's Blackhat Conference.

[cacert]: http://www.cacert.org/
[ssl]: http://en.wikipedia.org/wiki/Secure_Sockets_Layer
[blackhat]: http://www.youtube.com/watch?v=Z7Wl2FW2TcA
[diginotar]: https://blog.torproject.org/blog/diginotar-debacle-and-what-you-should-do-about-it
[ca]: http://en.wikipedia.org/wiki/Certificate_authority
[etherpad]: https://github.com/Pita/etherpad-lite
[pad]: https://pad.fnordig.de/
[https]: https://fnordig.de/
[moxie]: http://www.thoughtcrime.org/
