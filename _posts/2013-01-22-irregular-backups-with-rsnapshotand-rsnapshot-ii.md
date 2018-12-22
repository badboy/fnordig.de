---
permalink: "/{{ year }}/{{ month }}/{{ day }}/irregular-backups-with-rsnapshotand-rsnapshot-ii"
title: irregular backups with rsnapshot (and rsnapshot_ii)
published_date: "2013-01-22 19:08:00 +0100"
layout: post.liquid
data:
  route: blog
---
As stated in the last post I bought a big 2TB HDD for backups. My only
computer right now is a Laptop so regular backups are not possible (due to not
having the hdd with me all the time)

I needed another way for easy full and incremental backups without relying to much on specific intervals.

I came across [rsnapshot][], which - well - does depend on regular intervals.
But here comes [rsnapshot_ii][], a small wrapper script for rsnapshot.

It "fixes" these two problems the author (and I) had:

* Backups with irregular intervals.
* Missed backups.

I uploaded my config here ([gist][]):

* [rsnapshot.conf][]
* [exclude][]

And as promised in the last post the script I use to mount the HDD: [mount-backup][]

[rsnapshot]: http://www.rsnapshot.org/
[rsnapshot_ii]: https://non7top.googlecode.com/svn/trunk/scripts/rsnapshot/rsnapshot_ii
[gist]: https://gist.github.com/4596749#file-rsnapshot-conf
[exclude]: https://gist.github.com/4596749#file-exclude
[mount-backup]: https://gist.github.com/4596749#file-mount-backup-sh
[rsnapshot.conf]: https://gist.github.com/4596749#file-rsnapshot-conf
