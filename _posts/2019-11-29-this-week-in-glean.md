---
permalink: "/{{ year }}/{{ month }}/{{ day }}/this-week-in-glean"
title: "This Week in Glean: Differences"
published_date: "2019-11-29 11:37:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
---

(“This Week in Glean” is a series of blog posts that the Glean Team at Mozilla is using to try to communicate better about our work. They could be release notes, documentation, hopes, dreams, or whatever: so long as it is inspired by Glean. You can find an [index of all TWiG posts online](https://mozilla.github.io/glean/book/appendix/twig.html).)

Last week's blog post: [This Week in Glean: Glean in Private](https://chuttenblog.wordpress.com/2019/11/22/this-week-in-glean-glean-in-private/) by chutten.

---

Currently my team is responsible for the Telemetry framework inside Firefox on Desktop and also [the Glean SDK](https://github.com/mozilla/glean), targeting our mobile products.
We're working on bringing the Glean experience to Firefox on Desktop, but in the meantime [Telemetry](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/index.html) is what we have,
need to support and sometimes implement new features on.

One of these features is a new ping (or, better, a change in a ping), that we now want to support across all our products.
I'm speaking of the [`deletion-request` ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/deletion-request-ping.html) here.
When a user opts out of Telemetry we take this as a signal to also delete associated data from our pipeline.

Implementation in Firefox Desktop was merely renaming [an existing ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/obsolete/optout-ping.html) that is triggered when the user disables "Data Collection and Use" (`about:preferences` -> Privacy & Security). It contains no additional data.
Implementation in Glean was not much harder either. Glean already supports [custom pings](https://mozilla.github.io/glean/book/user/pings/custom.html): Pings that can be defined and send by the application using Glean.
Glean's internal pings follow the same pattern, they are just pre-defined.
The biggest difference?

It's called `deletion_request` ping instead.

On ingestion data from a ping is decoded from its JSON form and put into tables on BigQuery
(in our documentation you can find [an overview of the data pipeline](https://docs.telemetry.mozilla.org/concepts/pipeline/gcp_data_pipeline.html#an-overview-of-mozillas-data-pipeline) if you are interested).
BigQuery table names can only contain alphanumeric characters and underscores (see ["Table naming"](https://cloud.google.com/bigquery/docs/tables#table_naming) in the BigQuery documentation).
We avoid any translation in the pipeline by just enforcing this directly on ping names.

Glean also enforces the payload schema of pings.
Glean itself controls portion of the data, including a sequence number, date field
and a bit of metadata about the application its running in (see [the ping sections](https://mozilla.github.io/glean/book/user/pings/index.html#ping-sections)).
The rest of the payload consists of [metrics](https://mozilla.github.io/glean/book/user/metrics/index.html) as defined by users of Glean.
While implementing the new ping I stumbled upon another small detail of Glean: Pings won't be sent out if they would not contain any metrics.
And our new ping, by design, should not contain any metrics!

We don't want to change this for other pings, so I had to introduce a new flag now:
`sendIfEmpty` ([PR #139](https://github.com/mozilla/glean_parser/pull/139)).

That way we can allow the `deletion_request` ping to be sent without any metrics in there, only containing the basic information.

The implementation of the new ping is now done and currently waiting for data review ([PR #526](https://github.com/mozilla/glean/pull/526)).
I hope to land this early next week.
