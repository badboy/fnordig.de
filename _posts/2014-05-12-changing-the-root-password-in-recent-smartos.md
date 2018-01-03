extends: post.liquid
title: Changing the root password in recent SmartOS
date: 12 May 2014 22:02:00 +0200
path: /:year/:month/:day/changing-the-root-password-in-recent-smartos
route: blog
---

Back in 2012 Jonathan Perkin wrote a little bit about [SmartOS and the global zone][perkin],
why and what in SmartOS is mounted read-only.

Back then `/etc/shadow`, the file containing the root password, was mounted with write permissions.
It is not anymore:

~~~shell
# ls -l /etc/shadow
-r--------   1 root     root         560 May 12 19:51 /etc/shadow
~~~

And thus `passwd` will fail when trying to change the password.
But it's easy to circumvent this. It's actually a lofs-mount as can be seen:

~~~shell
# mount | grep shadow
/etc/shadow on /usbkey/shadow read/write/setuid/devices/dev=1690008 on Mon May 12 20:05:36 2014
~~~

So to change your password use the following:

~~~shell
/usr/lib/cryptpass your-fancy-password
# replace crypt string in /usbkey/shadow
umount /etc/shadow
mount -F lofs /usbkey/shadow /etc/shadow
~~~

1. will create the crypt string of your password. Make sure to remove it from your bash history afterwards
2. place this string in `/usbkey/shadow` (it's the long string between the first two `:`)
3. unmount the file in place
4. remount the right file back in place

And that's it, the new root password is set.

[perkin]: http://www.perkin.org.uk/posts/smartos-and-the-global-zone.html
