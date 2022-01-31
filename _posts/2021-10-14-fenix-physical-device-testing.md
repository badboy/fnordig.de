---
permalink: "/{{ year }}/{{ month }}/{{ day }}/fenix-physical-device-testing"
title: "Fenix Physical Device Testing"
published_date: "2021-10-14 17:00:00 +0200"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
excerpt: |
  The Firefox for Android (Fenix) project runs extensive tests on every pull request
  and when merging code back into the `main` branch.
  While many tests run within an isolated Java environment, Fenix also contains a multitude of UI tests.
  This post is about how to run these UI tests on actual physical devices in an automated way.
---

The [Firefox for Android (Fenix)](https://github.com/mozilla-mobile/fenix) project runs extensive tests on every pull request and when merging code back into the `main` branch.

While many tests run within an isolated Java environment, Fenix also contains a multitude of UI tests.
They allow testing the full application, interaction with the UI and other events.
Running these requires the Android emulator running or a physical Android device connected.
To run these tests in the CI environment the Fenix team relies on the [Firebase test lab](https://firebase.google.com/docs/test-lab/),
a cloud-based testing service offering access to a range of physical and virtual devices to run Android applications on.

To speed up development, the automatically scheduled tests associated with a  pull request are only run on virtual devices.
These are quick to spin up, there is basically no upper limit of devices that can spawn on the cloud infrastructure and they usually produce the same result as running the test on a physical device.

But once in a while you encounter a bug that can only be reproduced reliably on a physical device.
If you don't have access to such a device, what do you do? Or you know the bug happens on that one specific device type you don’t have?

You remember that the Firebase Test Lab offers physical devices as well and the Fenix repository is very well set up to run your test on these too if needed!

Here's how you change the CI configuration to do this.

> **NOTE**: Do not land a Pull Request that switches CI from virtual to physical devices! Add the `pr:do-not-land` label and call out that the PR is only there for testing!

By default the Fenix CI runs tests using virtual devices on `x86`.
That's faster when the host is also a `x86(_64)` system, but most physical devices use the Arm platform.
So first we need to instruct it to run tests on Arm.

Which platform to test on is defined in [`taskcluster/ci/ui-test/kind.yml`](https://github.com/mozilla-mobile/fenix/blob/58e12b18e6e9f4f67c059fe9c9bf9f02579a55db/taskcluster/ci/ui-test/kind.yml#L65).
Find the line where it downloads the `target.apk` produced in a previous step and change it from `x86` to `arm64-v8a`:

```patch
  run:
      commands:
-         - [wget, {artifact-reference: '<signing/public/build/x86/target.apk>'}, '-O', app.apk]
+         - [wget, {artifact-reference: '<signing/public/build/arm64-v8a/target.apk>'}, '-O', app.apk]
```

Then look for the line where it invokes the `ui-test.sh` and tell it to use `arm64-v8a` again:

```patch
  run:
      commands:
-         - [automation/taskcluster/androidTest/ui-test.sh, x86, app.apk, android-test.apk, '-1']
+         - [automation/taskcluster/androidTest/ui-test.sh, arm64-v8a, app.apk, android-test.apk, '-1']
```

With the old CI configuration it will look for Firebase parameters in `automation/taskcluster/androidTest/flank-x86.yml`.
Now that we switched the architecture it will pick up [`automation/taskcluster/androidTest/flank-arm64-v8a.yml`](https://github.com/mozilla-mobile/fenix/blob/58e12b18e6e9f4f67c059fe9c9bf9f02579a55db/automation/taskcluster/androidTest/flank-arm64-v8a.yml) instead.

In that file we can now pick the device we want to run on:

```patch
   device:
-   - model: Pixel2
+   - model: dreamlte
      version: 28
```

You can get a [list of available devices](https://firebase.google.com/docs/test-lab/android/available-testing-devices) by running `gcloud` locally:

```
gcloud firebase test android models list
```

The value from the `MODEL_ID` column is what you use for the `model` parameter in `flank-arm64-v8a.yml`.
`dreamlte` translates to a Samsung Galaxy S8, which is available on Android API version 28.

If you only want to run a subset of tests define the `test-targets`:

```yaml
test-targets:
 - class org.mozilla.fenix.glean.BaselinePingTest
```

Specify an exact test class as above to run tests from just that class.

And that's all the configuration necessary.
Save your changes, commit them, then push up your code and create a pull request.
Once the decision task on your PR finishes you will find a `ui-test-x86-debug` job (yes, `x86`, we didn't rename the job).
Its log file will have details on the test run and contain links to the test run summary.
Follow them to get more details, including the logcat output and a video of the test run.

---

_This explanation will eventually move into documentation for Mozilla's Android projects.  
Thanks to Richard Pappalardo & Aaron Train for the help figuring out how to run tests on physical devices and early feedback on the post.
Thanks to [Will Lachance](https://wrla.ch/) for feedback and corrections. Any further errors are mine alone._
