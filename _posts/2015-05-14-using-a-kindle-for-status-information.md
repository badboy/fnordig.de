---
layout: post
title: Using a Kindle for status information
date: 14.05.2015 20:50
---

Back in 2011 I got a Kindle 4 (the non-touch version) and for some time it was
the primary device for reading, be it ebooks, technical documentation or slides
and transcripts from university.

But then I was using it less and less and for the last one and a half years it basically layed around unused.
While it is a good device for book reading, it isn't for other content.
It's slow, it can't handle PDFs properly (zooming is just awful) and adding notes is really annoying with that on-screen keyboard.

For some time now I have this link saved: [Kindle Weather Display][weather-display].

Well, what better to do with a lazy holiday then doing some hacking with the Kindle? And so I did and this is the current result: It displays the weather forecast.

{::options parse_block_html="true" /}
<div style="text-align:center">
[![For now it shows the weather forecast](//tmp.fnordig.de/kindle/th-Photo-2015-05-14-19-27.jpg)](http://tmp.fnordig.de/kindle/Photo-2015-05-14-19-27.jpg)
</div>
{::options parse_block_html="false" /}


As the original article is quite short on the precise steps to get this finished, I wanted to write them up here.

> (Just in case: I'm not responsible if you break your kindle while hacking around with it.)

First you need to jailbreak your Kindle, this will make the following things a bit easier. You should get it done using this [short guide](http://wiki.mobileread.com/wiki/Kindle4NTHacking#Jailbreak).
The next step is to set up SSH to get shell access on the Kindle.
I used the USBnet variant described in the [Kindle 4 NT Hacking Guide](http://wiki.mobileread.com/wiki/Kindle4NTHacking#SSH) (yes, that's the same as the Jailbreak one).
Despite its name this can enable the SSH daemon on the WiFi interface too.
Attach the Kindle via USB, mount it and then open the `usbnet/etc/config` and add:

~~~bash
K3_WIFI="true"
~~~

Now you can also enable auto-starting USBnet. Caution: As long as USBnet is running, you can't mount the Kindle.


~~~bash
# the Kindle should be mounted into /mnt/sdb1
mv /mnt/sdb1/usbnet/DISABLED_auto /mnt/sdb1/usbnet/auto
~~~

Next, reboot your device. Once it's back up you should be able to connect to it via SSH on the IP it has in your WiFi network.

~~~bash
ssh root@192.168.1.42
~~~

The root password is either `mario` or of the form `fionaABCD`. Use the [Kindle root password tool][kindle-password] to find out based on the serial number.

There's just one more tool: Kite, the application launcher.
You can get it [in this forum post][kite]. Installation is easy once you got the `kite.gz`.
Copy the `kite` file to the kindle, then execute it:

~~~
jer@brain$ gunzip kite.gz
jer@brain$ scp kite root@192.168.1.42:/tmp/
jer@brain$ ssh root@192.168.1.42
root@kindle# cd /tmp
root@kindle# chmod +x kite
root@kindle# ./kite
~~~

One thing to note: You just downloaded some binary blob from some random forum and executed it.
But you did that with the jailbreak and USBnet above anyway.
And hey, that's how these things worked back in the old days, it actually was totally normal in the [PSP scene](http://fnordig.de/2014/12/03/a-story-of-hacking-or-rust-on-the-psp/) too

Back to our project: Reboot the Kindle and in the start screen you should see some note that Kite is started as well.
The Kindle will also contain some new directories:

~~~
root@kindle# ls -l /mnt/us/kite
drwxr-xr-x    2 root     root         8192 May 14 12:13 onboot
drwxr-xr-x    2 root     root         8192 May 14 11:57 ondrop
~~~

`onboot` is the relevant one. All scripts in there are executed by Kite on startup of the Kindle.
That's where we disable some stuff and display our image for the first time.
Write the following code to a file `init-weather.sh` and place it in `onboot` (or [just get it from the repository](https://github.com/badboy/kindle-weather-display/blob/master/kindle/init-weather.sh)):

~~~bash
#!/bin/sh

/etc/init.d/framework stop
/etc/init.d/powerd stop
/mnt/us/weather/display-weather.sh
~~~

This will disable the framework (= the Kindle UI basically) and the power management daemon (= responsible for disabling WiFi and switching to the screensaver if idle for too long).
In case you want to get back to the old state, just enable framework and powerd again (and first remove the `init-weather.sh` which will otherwise directly disable them again).

The `display-weather.sh` script now does the hard stuff, which is pretty easy: Clear the screen, get a new image, display it.

~~~bash
#!/bin/sh

cd "$(dirname "$0")"

rm -f display.png
eips -c
eips -c

if wget -q http://server/path/to/display.png; then
    eips -g display.png
else
    eips -g weather-image-error.png
fi
~~~

`eips` is the tool to write something on the screen or display an image.

Now to regularly and automatically get a new image, set up a cronjob:

~~~
root@kindle# mntroot rw
root@kindle# echo '0 7,19 * * * /mnt/us/weather/display-weather.sh' >> /etc/crontab/root
root@kindle# mntroot ro
root@kindle# /etc/init.d/cron restart
~~~

The script will now be executed every day at 7:00 and 19:00, showing a picture from the internet (well, at best it's a picture you generated).

As this post is already getting quite long, I leave the server-side up to you.
All files (for both the Kindle and the server part) are in the GitHub repository: [kindle-weather-display][repo].
This is the final result: My Kindle hanging on the wall right under the calendar. :)

{::options parse_block_html="true" /}
<div style="text-align:center">
[![It's hanging at the wall](//tmp.fnordig.de/kindle/th-Photo-2015-05-14-16-44.jpg)](http://tmp.fnordig.de/kindle/Photo-2015-05-14-16-44.jpg)
</div>
{::options parse_block_html="false" /}

[weather-display]: http://mpetroff.net/2012/09/kindle-weather-display/
[kite]: http://www.mobileread.com/forums/showthread.php?t=168270
[repo]: https://github.com/badboy/kindle-weather-display
[kindle-password]: https://www.sven.de/kindle/

---

Thanks to [@e2b](https://twitter.com/e2b) for proofreading a draft of this post.
