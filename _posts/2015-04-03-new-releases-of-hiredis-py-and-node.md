extends: post.liquid
title: "New releases of hiredis-py and hiredis-node"
date: 03 Apr 2015 23:05:00 +0200
path: /:year/:month/:day/new-releases-of-hiredis-py-and-node
---

I just published [hiredis-py][] v0.2.0 to [PyPi][] and [hiredis-node][] v0.3.0 to [npm][].

Both of these do not include many new features compared to the last release, but it still took me hours and hours to get this out, and that's for one simple reason:
We now have basic Windows support in hiredis and thus in hiredis-py and hiredis-node as well.

These two modules only use the parser functionality of hiredis and leave the socket stuff to the language itself.
Since v0.12, this parser functionality in hiredis was extracted into seperate files, which made it easily possible to include the necessary compatibility code (if any) to use it on Windows as well.

What made these releases take so long to get finished was the <abbr title="Continuous Integration">CI</abbr> process.
I didn't want to include support unless I can make sure it keeps working and for this I need to run the tests on the desired systems.
But because I don't personally own a Windows machine on which I could develop (nor would I want one) I had to use some external service for this.
I was pointed to [appveyor][], basically the [TRavis CI][travis] for Windows.
Setting everything up and making sure tests run correctly took me quite some time.
The last time I touched any compiler on a Windows machine is several years back, so I had to gather all needed information from the documentation and demo scripts from the Internet.
And builds that take as long as 40 minutes for 6 different environments don't really help to get started fast.
The actual build per environment takes only 3 minutes, but even that is high compared to the Linux builds on Travis, that run in about a minute (that is for 3 environments).

I finally reached green builds now and I hope I can keep it that way.
I will rely on these builds for releases from now on to support Windows as best as I can, but as said before, I have no machine to test these in more detail and I rely soly on user input if anything breaks beyond the simple *compile and test* appveyor now does.

At next I will release a new version of hiredis itself with several fixes and new features, but this may take a bit more time (I wanted to finish it this week, but I can't promise that anymore).

---

You're interest in Open Tech? Come to the [otsconf](https://otsconf.com/) in August! First batch of tickets goes on sale this Sunday, 5. April, 5:00 pm CEST.

[hiredis-node]: https://github.com/redis/hiredis-node
[npm]: https://www.npmjs.com/package/hiredis
[hiredis-py]: https://github.com/redis/hiredis-py
[pypi]: https://pypi.python.org/pypi/hiredis/
[appveyor-py]: https://ci.appveyor.com/project/badboy/hiredis-py
[appveyor-node]: https://ci.appveyor.com/project/badboy/hiredis-node
[appveyor]: http://appveyor.com
[travis]: http://travis-ci.org
