---
permalink: "/{{ year }}/{{ month }}/{{ day }}/rsyncing-my-rss-feed-database"
title: "rsyncing my RSS feed database"
published_date: "2024-10-28 20:45:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  At the moment I'm using a web-based RSS feed reader.
  That works, is reliable and accessible from anywhere.

  However I will soon spend some time with less connectivity
  and thus were considering my options to have a local feed reader app that works offline.
  A long while ago I used Newsbeuter and then I recently found its successor Newsboat.
  That solves the local & offline.
  But it still requires connectivity to fetch feeds,
  and for fetching some 100 feeds that's quite a bit of traffic.
---

At the moment I'm using a web-based RSS feed reader[^1].
That works, is reliable and accessible from anywhere.

However I will soon spend some time with less connectivity
and thus were considering my options to have a local feed reader app that works offline.
A long while ago I used [Newsbeuter] and then I recently found its successor [Newsboat].

It can import feeds from an OPML file, so that's what I did.

![Newsboat showing an article on fnordig.de](https://tmp.fnordig.de/blog/2024/newsboat-fnordig.png)

That solves the local & offline.
But it still requires connectivity to fetch feeds,
and for fetching some 100 feeds that's quite a bit of traffic.

So it would be better to fetch that on a server.
That's doable for example by sticking `newsboat -x reload` into a cronjob on the server.
But then I still need to fetch down the database when I want to read new stuff.

Doable, but the database quickly grows large enough that this is prohibitive on slow and spotty connections.
Oh, and also Newsboat stores whether an article was read and I don't want to lose that.
So I need to occasionally sync back the local database to the server,
so the unread status is not overwritten.

[rsync] could handle this.
Just push up the local database, reload feeds, sync back the updated database[^2].

That's when I stumbled upon the new [sqlite-rsync].
It's labeled as a "Database Remote-Copy Tool For SQLite"
and essentially compares the SQLite pages remotely and locally
and only transfers those that are different on the replica.

To get the tool[^3]:

```
cd /tmp
git clone https://github.com/sqlite/sqlite.git
cd sqlite
./configure
make sqlite3_rsync
```

Put the `slite3_rsync` binary both locally and on the server in a folder in the `$PATH`.
Then saves this script as `newsboat-sync`:

```bash
#!/bin/bash

# CHANGE THIS:
HOST=user@host
LOCAL=~/.newsboat/cache.db
REMOTE=.newsboat/cache.db

echo "Sync up READ status"
sqlite3_rsync -v $LOCAL $HOST:$REMOTE

if [[ "$1" = "-u" ]]; then
  echo "READ status sync only. Exiting."
  exit 0
fi

echo "Updating feeds"
ssh $HOST ' \
  [[ $(($(date +%s) - $(cat ~/.newsboat/lastfetch.time 2>/dev/null || echo 0))) -ge 900 ]] && \
  { echo "Updating feeds (remote)"; newsboat -x reload; date +%s > ~/.newsboat/lastfetch.time; } || echo "No update" \
'

echo "Sync back new items"
sqlite3_rsync -v $HOST:$REMOTE $LOCAL
```

Now when invoked, it

1. syncs up the current state,
2. if at least 15 minutes (900 seconds) passed since the last fetch, fetches all feeds,
3. syncs down the database to the local machine.

```
$ newsboat-sync
Sync up READ status
sent 4,114 bytes, received 174,994 bytes, 320,407.87 bytes/sec
total size 34,131,968  speedup is 190.57
Updating feeds
Updating feeds (remote)
Sync back new items
sent 174,994 bytes, received 53,326 bytes, 253,971.08 bytes/sec
total size 34,131,968  speedup is 149.49
```

That's quite a speedup for a database that is 34 MB in size.

```
$ du -h ~/.newsboat/cache.db
34M     /Users/jer/.newsboat/cache.db
```

Now I can hopefully read new blog posts offline with minimal data transfer overhead.

[newsbeuter]: https://en.wikipedia.org/wiki/Newsbeuter
[newsboat]: https://newsboat.org/
[rsync]: https://rsync.samba.org/
[sqlite-rsync]: https://sqlite.org/rsync.html

---

_Footnotes:_

[^1]: A self-hosted [Stringer](https://github.com/stringer-rss/stringer) instance.  
[^2]: `rsync` would totally work just fine for this use case, but then i wouldn't get to try new tools.  
[^3]: via [simonw on lobsters](https://lobste.rs/s/2ngsl1/database_remote_copy_tool_for_sqlite#c_3hlhlz)
