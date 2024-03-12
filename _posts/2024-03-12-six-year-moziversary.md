---
permalink: "/{{ year }}/{{ month }}/{{ day }}/six-year-moziversary"
title: "Six-year Moziversary"
published_date: "2024-03-12 11:30:00 +0100"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
excerpt: |
  Six years as a Telemetry Engineer at Mozilla.
---

Another year went by, so that it's now been 6 years since I [joined Mozilla as a Telemetry engineer][joinedmoz],
I blogged every year since then: [2019], [2020], [2021], [2022], [2023]

Looking back at the past year it sure was different than the years before, again.
Obviously we left most of the pandemic isolation behind us and I got to meet more of my coworkers in person:
At the Mozilla All-Hands in Montreal, Canada, though that was cut short for me due to ... of course: Covid.
At PyCon DE and PyData here in Berlin.
And at another workweek with my extended team also here in Berlin.

My work also changed.
As predicted a year ago I branched out beyond the Glean SDK, took a [look at our data pipeline](https://youtu.be/nZupfJy6I0A),
worked on features across the stack and wrote a ton of stuff that is not code.
Most of that work spanned months and months and some is still not 100% finished.

For this year I'm focusing a bit more on the SDK and client-side world again.
With Glean used just about everywhere it's time we look into some optimizations.
In the past we made it correct first and paid less attention to optimize resource usage (CPU & memory for example).
Now that we have more and more usage in Firefox Desktop (Use Counters!) we need to look into making data collection more efficient.
The first step is to get better insights where and how much memory we use.
Then we can optimize.
Firefox comes with some of its own tooling for that with which we need to integrate, see <about:memory> for example.

I'm also noticing some parts in our codebase where in hindsight I wish we had made different implementation decisions.
At the time though we did make the right choices, now we need to deal with that (memory usage might be one of these, storage sure is another one).

And Mozilla more broadly?
It's changing. All the time.
We just had layoffs and reprioritization of projects.
That certainly dampens the mood.
Focus shifts and work changes.
But underneath there's still the need to use data to drive our decisions and so I'm rather confident that there's work for me to do.

## Thank you

None of my work would happen if it weren't for my manager [Alessio] and team mates [Chris], [Travis], [Perry], [Bruno] and [Abhishek].
They make it fun to work here, always have some interesting things to share and they still endure my bad jokes all the time.
Thank you!  
Thanks also goes out to the bigger data engineering team within Mozilla, and all the other people at Mozilla I work or chat with.

---

_This post was planned to be published more than a week ago. It's still perfectly in time. I wasn't able to focus on it earlier._

[joinedmoz]: /2018/02/18/a-new-job/
[2019]: /2019/03/01/one-year-moziversary/
[2020]: /2020/03/02/two-year-moziversary/
[2021]: /2021/03/01/three-year-moziversary/
[2022]: /2022/03/04/four-year-moziversary/
[2023]: /2023/03/01/five-year-moziversary/
[Alessio]: https://www.a2p.it/
[Chris]: https://chuttenblog.wordpress.com/
[Travis]: https://blogoftravis.wordpress.com/
[Perry]: https://github.com/perrymcmanis144/
[Bruno]: https://rosahbruno.github.io/
[Abhishek]: https://github.com/abhi-agg
