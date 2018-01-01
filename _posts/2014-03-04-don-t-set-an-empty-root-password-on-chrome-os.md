permalink: "/{{ year }}/{{ month }}/{{ day }}/don-t-set-an-empty-root-password-on-chrome-os"
title: "Don't set an empty root password on Chrome OS"
published_date: "2014-03-04 16:41:00 +0100"
layout: post.liquid
data:
  route: blog
---
So I got this [Chromebook][chromebook-post] in Developer Mode and wanted to set
a root password to atleast protect it a little.

Easy:

~~~bash
sudo chromeos-setdevpasswd
~~~

Oh, wait. You pressed enter twice here? Backup your data and reset the device.

This is what `chromeos-setdevpasswd` does:

~~~bash
#!/bin/sh

mkdir -p /mnt/stateful_partition/etc
echo "chronos:$(openssl passwd -1)" > /mnt/stateful_partition/etc/devmode.passwd
~~~

openssl does not care that you just used an empty password, atleast if you also verify it.
But so do `su` and `sudo`, which means you won't be able to get root rights again.

But it's Chrome OS after all, so most things are stored in your Google profile
anyway, resetting and restoring the thing is done easily.

[chromebook-post]: http://fnordig.de/2014/03/03/samsung-chromebook-a-short-review/
