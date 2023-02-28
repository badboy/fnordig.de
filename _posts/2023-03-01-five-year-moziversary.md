---
permalink: "/{{ year }}/{{ month }}/{{ day }}/five-year-moziversary"
title: "Five-year Moziversary"
published_date: "2023-03-01 08:00:00 +0200"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
excerpt: |
  Celebrating five years in my job as a Telemetry Engineer at Mozilla.
---

I can't believe it's already my fifth Moziversary.
It's been 5 years now since I [joined Mozilla as a Telemetry engineer][joinedmoz],
I blogged every year since then: [2019], [2020], [2021], [2022].
As I'm writing this I'm actually off on vacation (and will be for another week or so) and also it's super early here.
Nonetheless it's time to look back and forward.

So what have I been up to in the past year?
My team changed again. We onboarded Perry and Bruno and when Mike left we got Alessio as the manager of us all.
In September we finally met again at the Mozilla All Hands in Hawaii.
Not everyone was there, but it was great to meet those that were.
I also went to the Berlin office more often. It's still good to have that other place to work from.

I didn't add any new posts to the ["This Week in Glean"][twig] series and it was effectively retired.
I still believe that openly communicating about our work is very useful and would like to see more of that again.
Maybe I'll find some topics to write about this year
(and I have some drafts lying around I should finish).
One major piece of work in the past year was migrating Glean to use [UniFFI].
That [shipped][gleanuniffi] and I'm proud we rolled it out.
Beyond that I spent large parts of my time supporting our users (other Mozilla applications, mostly mobile),
fixing bugs and slowly tackling some feature improvements.

And what is for the next year?
I'm in the process of handing over my Glean SDK tech lead role to Travis.
After over 2 years I feel it's the right time to give up some responsibility and decision power over the project.
I believe that sharing responsibilities and empowering others to fill tech lead positions is an overwhelmingly good and important thing.

This shift will free me up to expand my work into other places.
I'm staying with the same team and of course a major part of my work will be on the SDK regardless,
but I also hope to expand my knowledge about our data systems end-to-end and have a high-level view and opinion about it.
For the most part Glean feels "complete", but of course there's always feature requests, use cases we want to support better and improvements to make.
My list of little things I would like to improve keeps growing, but now also gets new items beyond just the SDK.

To the next year and beyond!

## Thank you

Thanks to my team mates [Alessio], [Chris], [Travis], [Perry] and [Bruno]
and also thanks to the bigger data engineering team within Mozilla.
And thanks to all the other people at Mozilla I work with.

[joinedmoz]: /2018/02/18/a-new-job/
[2019]: /2019/03/01/one-year-moziversary/
[2020]: /2020/03/02/two-year-moziversary/
[2021]: /2021/03/01/three-year-moziversary/
[2022]: /2022/03/04/four-year-moziversary/
[Chris]: https://chuttenblog.wordpress.com/
[Travis]: https://blogoftravis.wordpress.com/
[Alessio]: https://www.a2p.it/wordpress/
[Perry]: https://github.com/perrymcmanis144/
[Bruno]: https://rosahbruno.github.io/
[uniffi]: https://github.com/mozilla/uniffi-rs/
[gleanuniffi]: https://github.com/mozilla/glean/releases/tag/v50.0.0
[twig]: https://mozilla.github.io/glean/book/appendix/twig.html
