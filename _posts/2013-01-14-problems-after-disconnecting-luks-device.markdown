---
layout: post
title: Problems after disconnecting LUKS device
date: 14.01.2013 23:28
---

Yesterday I got my 2TB backup disk. I formatted it and then used [LUKS][] to encrypt it and [LVM][] for the Volume Management.
After I copied some files to the new disk, I unmounted the disk, unplugged it and ...

### ... Oh, shit.

I forgot to `cryptsetup luksClose` it.

That's not a good thing to do. __Always remember to luksClose! It's so much easier__

So after reconnecting the device, you can't really decrypt and mount it, because it did not get unmapped (`/dev/mapper/name` still exists and so do `/dev/name/*`)

### No problem, we fix that!

_(in the following my mapping name is `extern`, change accordingly)_

First see current status, especially `Open count`

    dmsetup info

Now remove each mapped device (`-backup` and `-media` for me, I have 2 partiions on the disk):

    dmsetup remove extern-backup
    dmsetup remove extern-media

Once again check `Open count`, it should be `0` now. If so, go on and remove the mapping:

    dmsetup remove extern

Now you got rid of all old mappings. Let's try to mount the disk again. Plug it in, then do:

    cryptsetup luksOpen /dev/sdb2 extern

Type your password.
If the Volume Groups are missing, use:

    vgscan
    vgchange -ay extern

Now you can mount your partitions:

    mount /dev/extern/backup /mnt/backup

Once you're done, deactivate the volume groups and close the crypt device:

    vgchange -an extern
    cryptsetup luksClose extern

Now remember to always use these two commands after unmounting the device and use the following to open it:

    vgchange -ay extern
    cryptsetup luksOpen /dev/sdb2 extern

I wrote a little helper script which does exactly these steps as needed. I'll include it in my next post, when I talk about how I use the setup for backups.

[luks]: https://wiki.archlinux.org/index.php/LUKS
[lvm]: https://wiki.archlinux.org/index.php/LVM
