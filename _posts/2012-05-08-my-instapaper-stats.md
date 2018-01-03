permalink: "/{{ year }}/{{ month }}/{{ day }}/my-instapaper-stats"
title: my instapaper stats
published_date: "2012-05-08 11:33:00 +0200"
layout: post.liquid
data:
  route: blog
---
I am an actively user of the great [Instapaper](http://www.instapaper.com/)
service. Instapaper is a great tool to save web articles for reading later.
Even since I got my [Kindle 4](http://www.amazon.de/dp/B0051QVF7A/ref=tb_surl_kindle)
back in December I let Instapaper sent each and every article I saved directly
to it right in the morning.  The first thing I do when I wakeup is starting the
kindle to get the new issue so I can read it at breakfast.

Before I had the Kindle I had to read all saved articles on the PC (or my
Smartphone) where the reading experience really sucks for long articles.  My
workflow was much different and I deleted most read articles instead of marking
them as "read". But since I use the Kindle for reading I always archive old
articles.

Back in February I started to get some statistics on how much I really read
(and yes, every article saved to my Instapaper accout I actually read), so here
is my nice graph:

![Instapaper stats](http://tmp.fnordig.de/2012-05-08-instapaper-stats.png)

I started with 54 saved articles and I am now up to 234 articles. That makes
180 new articles read in just 77 days (my graph starts on 21.02.).

Most of the articles are coming from [Hacker News](http://news.ycombinator.com/)
and my twitter stream (maybe I should start some more statistics on the topics
and which language I read most)

I use a simple script executed via cronjob to fetch the list of articles from
Instapaper, but more on that later (I have to cleanup the script and then I can
release it).

-------

P.S.:

If you're wondering what the 3 lines on the bottom of the graph are: the green
one is the "Starred"-line (currently at 11 articles), the blue one is the
unread count (mostly between 0-5 articles per day) and the purple line is the
"saved"-folder (8 articles, which contains non-article links and is now more or less
superflous as I have a [Pinboard-Account](http://pinboard.in/u:badboy))
