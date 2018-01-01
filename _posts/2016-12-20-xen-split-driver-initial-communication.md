permalink: "/{{ year }}/{{ month }}/{{ day }}/xen-split-driver-initial-communication"
title: "Xen - split driver, initial communication"
published_date: "2016-12-20 16:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
In the [previous post](/2016/12/02/xen-a-backend-frontend-driver-example/) I explained how to initially setup a split driver
for Xen with the backend in *dom0* and the frontend in a *domU*.

This time we are taking a look at the internal states each side goes through.
Most of this code is a trimmed down version of the [Xen network driver](https://github.com/torvalds/linux/blob/bc3913a5378cd0ddefd1dfec6917cc12eb23a946/drivers/net/xen-netfront.c#L2024-L2060).

The full code can be found in [chapter 2](https://github.com/badboy/xen-split-driver-example/tree/master/chapter02) of the example repository.

## Background

The frontend part of the driver sits in an uprivileged *domU* and gets its input from the kernel in this virtual machine.
Depending on its usecase it then passed on commands what to do and the data over to the backend part,
sitting in an privileged domain such as *dom0*.
For example in case of the network driver, the *domU* kernel generates network packets
which are passed over to the backend,
which is then responsible to transfering this data to the actual network card.

Before all of this can happen both parts need to be able to communicate with each other.
Each part must probably set up a few things before it can do its job.
Some of these things must be advanced in lock-step, so each part advances to its next status
and then waits for counterpart to advance as well.

## The state machine

Internally this is all done through a state machine.
Both sides start in the `XenbusStateInitialising` state.
The goal is to reach `XenbusStateConnected` once fully setup.

If no setup is required at all, it is as easy as saying so:

~~~c
xenbus_switch_state(dev, XenbusStateConnected);
~~~

Of course a driver rarely has to do nothing at all.
Instead in each intermediate state some work can be done.
This results in a fairly large state machine on both ends, but most of it is just boilerplate.

This results in about 30 lines extra in the frontend and 100 lines in the backend.
In this blog post I will focus only on a few relevant lines.

Both sides gain another callback function, to be notified when the other side changes its state.
This way they can advance in lock-step.

~~~c
static void mydevicefront_otherend_changed(struct xenbus_device *dev,
			    enum xenbus_state backend_state)
	…
}

static struct xenbus_driver mydevicefront_driver = {
	.ids  = mydevicefront_ids,
	.probe = mydevicefront_probe,
	.otherend_changed = mydevicefront_otherend_changed,
};
~~~

(The backend as a similar one)

The passed state will tell us the new state of the other side.
In the frontend we can simply wait for different state switches and switch over the frontend as well,
eventually reaching `XenbusStateConnected`

~~~c
switch (backend_state)
{
	…
	case XenbusStateInitWait:
		if (dev->state != XenbusStateInitialising)
			break;
		if (frontend_connect(dev) != 0)
			break;
		xenbus_switch_state(dev, XenbusStateConnected);

		break;
	…
}
~~~

The `frontend_connect` function should then set up everything necessary.

The backend has a similar function:

~~~c
static void mydeviceback_otherend_changed(struct xenbus_device *dev, enum xenbus_state frontend_state)
{
	switch (frontend_state) {
		…
		case XenbusStateConnected:
			set_backend_state(dev, XenbusStateConnected);
			break;
		…
	}
~~~

This defers to yet another function, actually just boilerplate to ensure the right order of state changes:


~~~c
static void set_backend_state(struct xenbus_device *dev,
			      enum xenbus_state state)
{
	while (dev->state != state) {
		switch (dev->state) {
		…
		case XenbusStateInitWait:
			switch (state) {
			case XenbusStateConnected:
				backend_connect(dev);
				xenbus_switch_state(dev, XenbusStateConnected);
				break;
			case XenbusStateClosing:
			case XenbusStateClosed:
				xenbus_switch_state(dev, XenbusStateClosing);
				break;
			default:
				BUG();
			}
			break;

		…
		}
	}
}
~~~

*Note: The whole state machine switching was taken from the network driver and may be reduced for other cases.*

Again, this calls into another function `backend_connect` where we can handle the setup.

For every invalid state switch it will trigger the `BUG()` macro, which crashes the module and in turn the kernel,
but at least you know where to start.

Last but not least let's set the initial state in the backend:

~~~c
static int mydeviceback_probe(struct xenbus_device *dev,
              const struct xenbus_device_id *id)
{
	xenbus_switch_state(dev, XenbusStateInitialising);
	return 0;
}

~~~

With the module code done, we need one last change: The guest domain must be able to write its state back to the XenStore.
Thus we set the correct permissions on paths in the XenStore using:

~~~
xenstore-chmod $DOM0_KEY r0 b$DOMU_ID
xenstore-chmod $DOMU_KEY r$DOMU_ID b0
~~~

The XenStore permissions are a bit unusual.
There are 4 different modes per file: **r**ead, **w**rite or **b**oth, **n**o access.
However, the owner of a file always has full access (**b**oth).

The very first permission always sets the owner and the permissions for any remaining user.
Every additional permission overwrites this first specified permission for the given user.

So the above `r0 b$DOMU_ID` means:

* Owner is domain 0, with full rights
* Every not-further specified domain can read the key
* The guest domain has read and write access (**b**oth)

For the second line it is the other way around.

## Run it

With everything in the code, we can compile the modules and load them into the kernel.

~~~
dom0# insmod mydeviceback.ko
domU# insmod mydevicefront.ko
d0m0# ./activate.sh 1
~~~

In the kernel log output of `dom0` you should see something along the lines:

~~~
Hello World!
Probe called. We are good to go.
Connecting the backend now.
~~~

And in the log output of `domU` you should see:

~~~
Hello World!
Probe called. We are good to go.
Connecting the frontend now.
Other side says it is connected as well.
~~~

At this point both sides are in `XenbusStateConnected` mode and can communicate.

As always, the full code can be found in
[chapter 2](https://github.com/badboy/xen-split-driver-example/tree/master/chapter02) of the example repository.

## Up next

Now that we know each state to go through,
we can set up communication through event channels.
We take a closer look at this in the next post.
