---
permalink: "/{{ year }}/{{ month }}/{{ day }}/seven-year-moziversary"
title: "Seven-year Moziversary"
published_date: "2025-03-03 10:50:00 +0100"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
excerpt: |
  Seven years as a Telemetry Engineer at Mozilla.
---

In March 2018 I started [a job as a Telemetry engineer at Mozilla][joinedmoz].
Seven years later I'm still here on my Moziversary, as I was in [2019], [2020], [2021], [2022], [2023] and [2024].

Mozilla is not the same company it was when I joined.
No one on the C-level is here for as long as I am.
There have been 5 larger reorgs in the past year and two layoffs in different departments, plus the big round of layoffs at the Mozilla Foundation.
My part of the organization was moved around again and for the moment Data Engineering is nested under the Infrastructure Org.
Good colleagues left or were laid off.
Just recently my team shrunk again.
Notably I haven't posted anything under the [mozilla tag](/tagged/mozilla.html) since 2022, other than my Moziversary blog posts.

<strike>All-Hands</strike> MozWeek[^1] Dublin happened.
The next one will be in Washington, D.C.
Probably one of the worst choices given the state of the USA right now, and I might just skip it.
I do hope for a team work week, but that's not decided yet.

The one constant over the past years is my work on [Glean], which hasn't stopped.
We're finally putting dedicated effort to move legacy telemetry in Firefox Desktop over to Glean ([Are we Glean yet?][arewegleanyet]).
But still Glean isn't where I'd like it to be.
Some of the early decisions in its design are coming back to bite us,
the codebase grew significantly and could use a bit of cleanup,
we never got the time to work on performance and memory improvements and our chosen local data storage desperately needs an update.
Some of that was on my list last year already.
If only there were less distractions that pull me of this work again and again.
It's on my list of goals _again_ this year, so maybe it works out better this time.

But other than that I don't know where Mozilla will be a year from now.
It's going to be a challenging year.

## Thank you

I'm in this job for seven years not only because I like the tech I get to work on,
but also because my colleagues make it a delight to come back to work every day.
Thanks to [Alessio], [Chris], [Travis] and [Abhishek] for being the Data Collection Tools team.
Also thanks to [Bruno], who was part of the team until recently.
There's countless other people at Mozilla,
inside Data Engineering but also across other parts of the organization,
that I got to connect, chat and work with. Thank you!

[joinedmoz]: /2018/02/18/a-new-job/
[2019]: /2019/03/01/one-year-moziversary/
[2020]: /2020/03/02/two-year-moziversary/
[2021]: /2021/03/01/three-year-moziversary/
[2022]: /2022/03/04/four-year-moziversary/
[2023]: /2023/03/01/five-year-moziversary/
[2024]: /2024/03/12/six-year-moziversary/
[Alessio]: https://www.a2p.it/
[Chris]: https://chuttenblog.wordpress.com/
[Travis]: https://blogoftravis.wordpress.com/
[Bruno]: https://rosahbruno.github.io/
[Abhishek]: https://github.com/abhi-agg
[Glean]: https://github.com/mozilla/glean
[arewegleanyet]: https://arewegleanyet.com/

---

_Footnotes_:

[^1]: Change everywhere. Those Mozilla work weeks were renamed by Marketing.
