---
permalink: "/{{ year }}/{{ month }}/{{ day }}/fog-progress-report"
title: "This Week in Glean: FOG progress report"
published_date: "2020-10-06 16:00:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
  - rust
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean.)

All "This Week in Glean" blog posts are listed in the [TWiG index](https://mozilla.github.io/glean/book/appendix/twig.html)
(and on the [Mozilla Data blog](https://blog.mozilla.org/data/category/glean/)).
This article is [cross-posted on the Mozilla Data blog](https://blog.mozilla.org/data/2020/10/06/this-week-in-glean-fog-progress-report/).

---

About a year ago chutten started the "This Week in Glean" series with an initial
[blog post about Glean on Desktop](https://chuttenblog.wordpress.com/2019/10/17/this-week-in-glean-glean-on-desktop-project-fog/).
Back then we were just getting started to bring Glean to Firefox Desktop.
No code had been written for Firefox Desktop, no proposals had been written to discuss how we even do it.

Now, 12 months later, after four completed milestones, a dozen or so proposal and quite a bit of code,
the Project Firefox on Glean (FOG) is finally getting into a stage where we can actually use and test it.
It's not ready for prime time yet, but FOG is enabled in Firefox Nightly already.

Over the past 4 weeks I've been on and off working on building out our support for a C++ and a JavaScript API.
Soon Firefox engineers will be able to instrument their code using Glean.
In C++ this will look like:

```cpp
mozilla::glean::test_only::count_something.Add(42);
```

JavaScript developers will use it like this:

```javascript
Glean.test_only.count_something.add(32);
```

My work is done in [bug 1646165][mla].
It's still under review and needs some fine-tuning before that, but I hope to land it by next week.
We will then gather some data from Nightly and validate that it works as expected ([bug 1651110][nightlyvalidation]),
before we let it ride the trains to land in stable ([bug 1651111][trainride]).

Our work won't end there.
With my initial API work landing we can start supporting all metric types,
we still need to figure out some details of how FOG will handle IPC,
and then there's the whole process of convincing other people to use the new system.

[mla]: https://bugzilla.mozilla.org/show_bug.cgi?id=1646165
[trainride]: https://bugzilla.mozilla.org/show_bug.cgi?id=1651111
[nightlyvalidation]: https://bugzilla.mozilla.org/show_bug.cgi?id=1651110

2020 will be the year of Glean on the Desktop.
