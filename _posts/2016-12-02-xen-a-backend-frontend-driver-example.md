---
permalink: "/{{ year }}/{{ month }}/{{ day }}/xen-a-backend-frontend-driver-example"
title: "Xen - a backend/frontend driver example"
published_date: "2016-12-02 10:10:00 +0100"
layout: post.liquid
data:
  route: blog
---
Recently I began working on my master thesis. For this I have to get familiar with the [Xen hypervisor][xen] and its implementation of drivers.
As the documentation on its implementation is quite sparse I want to write down some of my findings, so others don't have to re-read and re-learn everything.
In this post I'll focus on how to get a minimal *driver* in a paravirtualized VM running. Following posts will then focus on how to do communication through event channels and shared memory
These are all things I need for the project I am working on, so I need to figure out how this works anyway.

### Background

The Xen hypervisor is only a minimal hypervisor implementation, which is booted and then boots a special Linux machine, the so-called **dom0**.
This **dom0** is most often just a regular Linux distribution such as Ubuntu.
Using Xen-specific tools it is then possible to launch additional virtual machines (VMs). These are called **domU**.
In the default case, **dom0** is responsible to acutally talk to the hardware attached to a machine, such as hard disks and the network card.
However, VMs of course also need some way to store data or generate network traffic.
In Xen this is handled by virtual devices attached to the **domU**.
Generic drivers then proxy data that should be written to disk or network packets to send out through the **dom0** to the actual device.

These drivers follow a *split-driver* model, where one part of the driver, the backend, resides in the **dom0** and the other half, the frontend,
is a module in the **domU** machine.
Both parts can be implemented as kernel modules and be loaded dynamically.

What's not documented as clearly as it should be:
Activation of the *virtual device* and thus invoking the right methods of the kernel module is done by writing data to the [XenStore][xenstore].
For actual hardware this is already handled automatically. For your own custom *virtual device* this can be done manually.

[xen]: https://www.xenproject.org/
[xenstore]: https://wiki.xen.org/wiki/XenStore

### A minimal driver

Our driver won't do anything useful besides saying "Hello" and showing a message when it is activated.
The boilderplate for this example is quite huge, the full code can also be found in [the `xen-split-driver-example` repository][xen-split-driver-example].

I assume you already have a Xen host, you are connected to the **dom0** and have at least one **domU** running.

The frontend driver resides in `mydevicefront.c`:

~~~c
#include <linux/module.h>  /* Needed by all modules */
#include <linux/kernel.h>  /* Needed for KERN_ALERT */

#include <xen/xen.h>       /* We are doing something with Xen */
#include <xen/xenbus.h>

// The function is called on activation of the device
static int mydevicefront_probe(struct xenbus_device *dev,
              const struct xenbus_device_id *id)
{
	printk(KERN_NOTICE "Probe called. We are good to go.\n");
	return 0;
}

// This defines the name of the devices the driver reacts to
static const struct xenbus_device_id mydevicefront_ids[] = {
	{ "mydevice"  },
	{ ""  }
};

// We set up the callback functions
static struct xenbus_driver mydevicefront_driver = {
	.ids  = mydevicefront_ids,
	.probe = mydevicefront_probe,
};

// On loading this kernel module, we register as a frontend driver
static int __init mydevice_init(void)
{
	printk(KERN_NOTICE "Hello World!\n");

	return xenbus_register_frontend(&mydevicefront_driver);
}
module_init(mydevice_init);

// ...and on unload we unregister
static void __exit mydevice_exit(void)
{
	xenbus_unregister_driver(&mydevicefront_driver);
	printk(KERN_ALERT "Goodbye world.\n");
}
module_exit(mydevice_exit);

MODULE_LICENSE("GPL");
MODULE_ALIAS("xen:mydevice");
~~~

The backend driver is very similar and resides in `mydeviceback.c`:

~~~c
#include <linux/module.h>  /* Needed by all modules */
#include <linux/kernel.h>  /* Needed for KERN_ALERT */

#include <xen/xen.h>       /* We are doing something with Xen */
#include <xen/xenbus.h>

// The function is called on activation of the device
static int mydeviceback_probe(struct xenbus_device *dev,
			const struct xenbus_device_id *id)
{
	printk(KERN_NOTICE "Probe called. We are good to go.\n");
	return 0;
}

// This defines the name of the devices the driver reacts to
static const struct xenbus_device_id mydeviceback_ids[] = {
	{ "mydevice" },
	{ "" }
};

// We set up the callback functions
static struct xenbus_driver mydeviceback_driver = {
	.ids  = mydeviceback_ids,
	.probe = mydeviceback_probe,
};

// On loading this kernel module, we register as a frontend driver
static int __init mydeviceback_init(void)
{
	printk(KERN_NOTICE "Hello World!\n");

	return xenbus_register_backend(&mydeviceback_driver);
}
module_init(mydeviceback_init);

// ...and on unload we unregister
static void __exit mydeviceback_exit(void)
{
	xenbus_unregister_driver(&mydeviceback_driver);
	printk(KERN_ALERT "Goodbye world.\n");
}
module_exit(mydeviceback_exit);

MODULE_LICENSE("GPL");
MODULE_ALIAS("xen-backend:mydevice");
~~~

To compile each module indivudally, put them in their own directory and add a `Makefile` per module:

~~~make
obj-m += mydevicefront.o

all:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
~~~

Change the first line to `obj-m += mydeviceback.o` for the backend driver.  
You can then compile each module on their host and will get a `mydeviceback.ko` and `mydevicefront.ko`.

Next, you need to load the modules.
In the **dom0**:

~~~
insmod mydeviceback.ko
~~~

In the **domU**:

~~~
insmod mydevicefront.ko
~~~

Check with `dmesg` that on both sides you get the "Hello World".

Activation of the driver requires to add a virtual device to the Xenstore. I wrote a small script, `activate.sh` to do that.  

~~~bash
#!/bin/bash

DOMU_ID=$1

if [ -z "$DOMU_ID"   ]; then
  echo "Usage: $0 [domU ID]]"
  echo
  echo "Connects the new device, with dom0 as backend, domU as frontend"
  exit 1
fi

DEVICE=mydevice
DOMU_KEY=/local/domain/$DOMU_ID/device/$DEVICE/0
DOM0_KEY=/local/domain/0/backend/$DEVICE/$DOMU_ID/0

# Tell the domU about the new device and its backend
xenstore-write $DOMU_KEY/backend-id 0
xenstore-write $DOMU_KEY/backend "/local/domain/0/backend/$DEVICE/$DOMU_ID/0"

# Tell the dom0 about the new device and its frontend
xenstore-write $DOM0_KEY/frontend-id $DOMU_ID
xenstore-write $DOM0_KEY/frontend "/local/domain/$DOMU_ID/device/$DEVICE/0"

# Make sure the domU can read the dom0 data
xenstore-chmod $DOM0_KEY r

# Activate the device, dom0 needs to be activated last
xenstore-write $DOMU_KEY/state 1
xenstore-write $DOM0_KEY/state 1
~~~

This adds 3 paths per domain, setting up the virtual device and thus activating the driver.
Once you executed that, you again check `dmesg`. You should now see the `Probe called` message.

The full code can be found in [the example repository][xen-split-driver-example].

[xen-split-driver-example]: https://github.com/badboy/xen-split-driver-example
