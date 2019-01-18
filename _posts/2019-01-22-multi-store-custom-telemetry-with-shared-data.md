---
permalink: "/{{ year }}/{{ month }}/{{ day }}/multi-store-custom-telemetry-with-shared-data"
title: "multi-store - Custom Telemetry with shared data"
published_date: "2019-01-22 10:00:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
---

Last year I implemented a new feature for Firefox Telemetry that changes how we can collect and analyze data with different requirements in regard to user privacy & frequency.
This post will shine some light on the (rather simple) implementation and usage.

### Intro: What is Firefox Telemetry?

In order to understand how Firefox performs in the wild, it can collect a bunch of performance metrics and other information.
How and why we do this and what data we collect is explained in more detail in a blog post by Rebecca Weiss, Director of Data Science here at Mozilla:
[It’s your data, we’re just living in it](https://blog.mozilla.org/futurereleases/2017/09/06/data-just-living/).

I work on the [Telemetry component](https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/) inside Firefox.
It provides APIs that are used by the various other parts of the browser to gather data
and is responsible for storing, collecting and sending this data in what we call "pings", a periodic collection of measurements.
Telemetry data is only ever sent out if the user agreed to it (see "Data Collection and Use" in the "Privacy & Security" preferences of your Firefox).

Most data is collected in one of 3 different formats: histograms, scalars & events (see [our collection overview](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/index.html)).
Firefox sends this data in the ["main" ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html) once in a while (usually roughly daily) and clears out the stored data locally.
A "main" ping always corresponds to a subsession, which itself is part of a session. This is further explained [in our Session concepts](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/sessions.html).

People working with the data can therefore make certain assumptions on how to interpret the data from multiple pings across sessions and subsessions.

### The problem

Some data should not be correlated with other data due to privacy concerns.
So far we had to push Telemetry users to create custom pings and keep track of their own data.
If they rely on scalars or histograms as recorded by Telemetry, but send a custom ping in different intervals, they can't make valid assumptions about the metrics, as they might have been reset in between.
This leads to weird hacks or unnecessary code duplication. Additionally we can't provide any help or support for custom data and our tools can't handle it automatically (e.g. to generate dashboards).

### A solution

**Multi-Store**.

Every metric was always tied to the schedule of the "main" ping (read: subsession/session).
Our **multi-store** solution now enables metrics to be associated with multiple stores at once, defaulting to be in the "main" ping only.
Any user with custom requirements can now select metrics to be included in their custom store (which is still subject to [Data Collection Review](https://wiki.mozilla.org/Firefox/Data_Collection)).
Telemetry is still responsible for actual data storage and the APIs, but now the custom ping is responsible for collecting, clearing and periodically sending this data.

### An example

To demonstrate how this is used, let's create a custom ping, which will include one metric of its own and one that's also available in the "main" store (and thus the "main" ping).

We start by adding a new metric to [Scalars.yaml](https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/Scalars.yaml):

```yaml
  tick_times_rand:
    bug_numbers:
      - 0
    description: "A random value at every tick"
    expires: '71'
    kind: uint
    notification_emails:
      - janerik@fnordig.de
    release_channel_collection: opt-out
    record_in_processes:
      - "main"
    record_into_store:
      - "custom-store"
```

This defines a scalar named `tick_times_rand` in the `browser.engagement` category. The exact details are not important as we will record random values anyway.
The important bit is setting the store using `record_into_store`.

We also include `browser.engagement.tab_open_event_count` into our store by just adding our custom store name to `record_into_store` (don't forget to also include "main" there).

```patch
--- c/toolkit/components/telemetry/Scalars.yaml
+++ i/toolkit/components/telemetry/Scalars.yaml
@@ -66,6 +66,9 @@ browser.engagement:
     release_channel_collection: opt-out
     record_in_processes:
       - 'main'
+    record_into_store:
+      - "main"
+      - "custom-store"
```

Next, we define our new custom ping in a new file in `toolkit/components/telemetry/pings/CustomPing.jsm`.
We only define a very simple interface: A way to start the custom ping, which itself sets up a (persistent) timer (firing every 24 hours).
When fired, `notify()` will be called, which then collects the payload from `custom-store` and schedule the ping for sending.
Telemetry will take care of actually sending the ping (and retrying, storing it in the archive, etc.).
For test reasons only we also send this ping when `start()` is called (so we don't actually have to wait 24 hours to see something).

```javascript
var EXPORTED_SYMBOLS = ["TelemetryCustomPing"];

var TelemetryCustomPing = Object.freeze({
  start() {
    UpdateTimerManager.registerTimer(
      "telemetry_custom_ping",
      this,
      24 * 60 * 60; /* 1 day */
    );

    this.sendPing();
  },

  notify() {
    this.sendPing();
  },

  sendPing() {
    // Let's record just one more value, so _something_ is included.
    let randValue = Math.floor(Math.random() * Math.floor(100));
    Services.telemetry.scalarSet("browser.engagement.tick_times_rand", randValue);

    // We only include the scalars, as that's all we are recording for this ping.
    let payload = {
      custom: "This is custom data",
      scalars: Services.telemetry.getSnapshotForScalars("custom-store", /* clear */ true),
    };

    TelemetryController.submitExternalPing("custom", payload,
      {
        addClientId: false,
        addEnvironment: true,
      }
    );
  }
});
```

Now we need to actually start the ping timer. This should be done in the initialization phase of `TelemetryController`:

```patch
--- c/toolkit/components/telemetry/app/TelemetryController.jsm
+++ i/toolkit/components/telemetry/app/TelemetryController.jsm
@@ -62,6 +62,7 @@ XPCOMUtils.defineLazyModuleGetters(this, {
   TelemetryReportingPolicy: "resource://gre/modules/TelemetryReportingPolicy.jsm",
   TelemetryModules: "resource://gre/modules/ModulesPing.jsm",
   TelemetryUntrustedModulesPing: "resource://gre/modules/UntrustedModulesPing.jsm",
+  TelemetryCustomPing: "resource://gre/modules/CustomPing.jsm",
   UpdatePing: "resource://gre/modules/UpdatePing.jsm",
   TelemetryHealthPing: "resource://gre/modules/HealthPing.jsm",
   TelemetryEventPing: "resource://gre/modules/EventPing.jsm",
@@ -720,6 +721,9 @@ var Impl = {
           if (AppConstants.NIGHTLY_BUILD && AppConstants.platform == "win") {
             TelemetryUntrustedModulesPing.start();
           }
+
+          // Start the custom ping, which reports minimal information.
+          TelemetryCustomPing.start();
         }

         TelemetryEventPing.startup();
```

**But it's not measuring anything!**

That is right, but for now we only record one value when sending the ping.

And that's it! Our custom ping, with data sourced from a custom store and a release-shipped metric is ready[^1].
Let's build Firefox (this is the part where you have time to grab a cup of coffee if you haven't compiled Firefox before):

```
./mach build
```

...

_2 - 40 minutes later._ Still with me?

Now run the freshly built Firefox:

```
./mach run
```

Once Telemetry is initialized (should take 60 seconds), you should be able to see the freshly generated custom ping (in a development build this ping is never actually send out).
To see it, go to `about:telemetry`, click on `Current Ping` in the upper-left corner, select `Archived ping data` and then the `custom` ping type. There you have it!

![Raw payload ouf the custom ping](https://tmp.fnordig.de/blog/2019/about-telemetry-customping.png)

The full changeset is available [in this commit on the gecko-dev mirror](https://github.com/badboy/gecko-dev/commit/a872a3fa06be30667c0ac5fc47007780e8a9f6b0) (don't worry, this is not landing in Firefox).

### What's next?

Currently there's no user of the multi-store feature, mainly because it was only finished in early December and is currently lacking some documentation (which this post should change a bit).
We expect some usage of this soon though.

---

[^1]: _Not entirely true. This needs some small changes to the build system._
