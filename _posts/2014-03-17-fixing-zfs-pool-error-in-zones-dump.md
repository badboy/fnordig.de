extends: post.liquid
title: Fixing zfs pool error in zones/dump
date: 17 Mar 2014 14:08:00 +0100
path: /:year/:month/:day/fixing-zfs-pool-error-in-zones-dump
route: blog
---

At work we're using [SmartOS][], an Open Solaris clone featuring all kinds of cool stuff. One of the best things is the underlying file system: ZFS.

With ZFS it is easy to create, mirror, extend storage pools, it's also very easy to snapshot pools and backup them using `zfs send` and `zfs receive`.
In the process of a manual backup of one of the pools today I wanted to see the status of the whole system by using `zpool status`.
This is what it showed:

~~~shell
$ zpool status -v
  pool: zones
 state: DEGRADED
status: One or more devices has experienced an error resulting in data
        corruption.  Applications may be affected.
action: Restore the file in question if possible.  Otherwise restore the
        entire pool from backup.
   see: http://illumos.org/msg/ZFS-8000-8A
config:

        NAME        STATE     READ WRITE CKSUM
        zones       DEGRADED    16     0     0
          mirror-0  DEGRADED    32     0     0
            c0t4d0  DEGRADED    32     0     0  too many errors
            c0t6d0  DEGRADED    32     0     0  too many errors
        logs
          c0t9d0    ONLINE       0     0     0
        cache
          c0t8d0    ONLINE       0     0     0

errors: Permanent errors have been detected in the following files:

        zones/dump:<0x1>
~~~

At first this looks a litte bit weird. What is this `zones/dump` even for? Why is it broken?
The answer: Solaris dumps the memory onto the disk on a system crash.
I tried googling this error, why it would get corrupt, if the disks are really broken or if it is just a software error.

Turns out this bug is known. We recently upgraded our SmartOS, which brings up this issue.
The disk and the pool are not really broken, but simply the data is misinterpreted.
To correct it you must replace the dump and later scrub the whole pool again.
I executed the following commands to do this (found them in a [forum post](http://www.kdump.cn/forums/viewtopic.php?pid=2761#p2761)):

~~~shell
zfs create -o refreservation=0 -V 4G zones/dump2
dumpadm -d /dev/zvol/dsk/zones/dump2
zfs destroy zones/dump
zfs create -o refreservation=0 -V 4G zones/dump
dumpadm -d /dev/zvol/dsk/zones/dump
zfs destroy zones/dump2
~~~

This will first create a new file system, swap it in as the dump file system,
delete the old one and once again create a new one with the old name and putting it back in place.

In case the `dumpadm -d` part fails, complaining about the file system being to small, just resize it:

~~~shell
zfs set volsize=20G zones/dump2
~~~

See [Swap and Dump Volume Sizes for ZFS File Systems](http://docs.oracle.com/cd/E23824_01/html/821-1459/fsswap-31050.html#SAGDFSfsswap-31050).

The scrubbing took 21 hours with our large data set, but it was not noticable in running machines on this host due to its low priority.
The final status:

~~~shell
  pool: zones
 state: DEGRADED
…

errors: Permanent errors have been detected in the following files:

        <0x17f>:<0x1>
~~~

Well, now the `zones/dump:<0x1>` is gone. But it still shows an error for the same file system, just that it is not named anymore. We're scheduling a maintenance soon to reboot the machine. Let's hope this will clear the error. Otherwise we will replace the HDD.

[smartos]: http://smartos.org/
