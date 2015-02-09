---
layout: post
title: hiredis is up to date
date: 09.02.2015 20:20
---

Back in December 2014 antirez reached out to the community, to [find a new maintainer of hiredis](https://github.com/redis/hiredis/issues/283).
In a joined effort [Michael][], [Matt][] and me took on the effort and
just 2 weeks ago Matt released [Version 0.12.1](https://github.com/redis/hiredis/releases/tag/v0.12.1),
after just two years without a proper release.

This weekend I got in contact with [Pieter][] who handed over access to all major packages based on hiredis to me.
Sunday I pushed out new versions for all of them:

* Ruby: [hiredis-rb](https://github.com/redis/hiredis-rb/) v0.6.0 ([gem](https://rubygems.org/gems/hiredis))
* JavaScript: [hiredis-node](https://github.com/redis/hiredis-node) v0.2.0 ([npm](https://www.npmjs.com/package/hiredis))
* Python: [hiredis-py](https://github.com/redis/hiredis-py) v0.1.6 ([pypi](https://pypi.python.org/pypi/hiredis/)) *(this is my first ever maintained Python package, yey)*

All of them include only non-breaking changed and an upgrade of the underlying hiredis code, so all additional libraries and applications depending on them should just work after an upgrade.
If not, please open a ticket.

I again want to say thank you to [Pieter][] who maintained all of these packages in the past.
Also thank you to Matt and Michael, who helped push hiredis forward.

[Michael]: https://github.com/michael-grunder
[Matt]: https://github.com/mattsta
[Pieter]: https://github.com/pietern]
