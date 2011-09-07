---
layout: post
title: running on ssl
date: 08.09.2011 00:31
---

Even though the [SSL][] and [CA][] system is totally broken right now, I finally got my blog as well as my [etherpad][] served over SSL:

* [https://fnordig.de][https]
* [https://pad.fnordig.de][pad]

My SSL certificate is signed by [cacert][] (they approved me at last year's FrOSCon).

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
