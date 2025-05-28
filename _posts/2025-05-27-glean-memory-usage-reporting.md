---
permalink: "/{{ year }}/{{ month }}/{{ day }}/glean-memory-usage-reporting"
title: "Glean Memory Usage Reporting"
published_date: "2025-05-28 14:00:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - mozilla
excerpt: |
  Since Bug 1896609 landed we now have Glean & Firefox on Glean (FOG) memory reporting built into the Firefox Memory Reporter.
  This allows us to measure the allocated memory in use by Glean and FOG.
  It currently covers memory allocated by the C++ module of FOG and all instantiated Glean metrics.
  It does not yet measure the memory used by Glean and its database.
---

(This article is cross-posted on the [Data@Mozilla blog](https://blog.mozilla.org/data/2025/05/28/glean-memory-usage-reporting/).)

---

Since [Bug 1896609](https://bugzilla.mozilla.org/show_bug.cgi?id=1896609) landed we now have [Glean](https://github.com/mozilla/glean) & [Firefox on Glean (FOG)](https://firefox-source-docs.mozilla.org/toolkit/components/glean/index.html) memory reporting built into the Firefox Memory Reporter.
This allows us to measure the allocated memory in use by Glean and FOG.
It currently covers memory allocated by the C++ module of FOG and all instantiated Glean metrics. It does not yet measure the memory used by Glean and its database.

# **How it works**

Firefox has a built-in memory usage reporter, available as [`about:memory`](https://firefox-source-docs.mozilla.org/performance/memory/about_colon_memory.html).
Components of Firefox can expose their own memory usage by implementing the [`nsIMemoryReporter`](https://searchfox.org/mozilla-central/source/xpcom/base/nsIMemoryReporter.idl) interface.
FOG implements this interface and delegates the measurement to the `firefox-on-glean` Rust component.

`firefox-on-glean` then collects the memory usage of objects under its own control: all user-defined and runtime-instantiated metrics, additional hashmaps used to track metrics & all user-defined and runtime-instantiated pings. It will soon also collect the memory size of the global Glean object, and thus the memory used for built-in metrics as well as the in-memory database.

Memory measurement works by following all heap-allocated pointers, asking the allocator for the memory size of each and summing everything up. Because we do most of this measurement in Rust we use the existing [wr\_malloc\_size\_of](https://crates.io/crates/wr_malloc_size_of) crate, which already implements the correct measurement for most Rust libstd types as well as some additional library-provided types. Our own types implement the required trait using [malloc\_size\_of\_derive](https://crates.io/crates/malloc_size_of_derive) for automatically deriving the trait, or manual implementations.

# **How it looks**

The memory measurement is built into Firefox and works in every shipped build. Open up `about:memory` in a running Firefox,
click the “Measure” button and wait for the measurement.
Once all data is collected it will show a long tree of measured allocations across all processes.
Type `fog` into the filter box on the right to trim it down to only allocations from the fog component.
The exact numbers differ between runs and operating systems.

You will see a view similar to this:

<figure>
  <img
    src="https://tmp.fnordig.de/blog/2025/2025-05-28-glean-memory-reporting.png"
    alt="about:memory on a freshly launched developer build of Firefox. fog reports 0.35 MB of allocated memory in the main process." />
  <figcaption>about:memory on a freshly launched developer build of Firefox. fog reports 0.35 MB of allocated memory in the main process.</figcaption>
</figure>

After opening a few tabs and browsing the web a new measurement on `about:memory` will show a different number,
as Glean is instantiating more metrics and therefore allocating more memory. This number will grow as more metrics are instantiated and kept in memory.

This currently does not show the allocations from the global Glean object and its in-memory database.
In the future we will be able to measure those allocations as well.
In a prototype locally this already works as expected: As more data is recorded and stored the allocated memory grows.
Once a ping is assembled, submitted and sent the allocations will be freed and `about:memory` will report less memory allocated again.
