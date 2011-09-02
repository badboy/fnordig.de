---
layout: post
title: sshuttle - poor man's vpn
---


> [sshuttle](https://github.com/apenwarr/sshuttle) is a transparent proxy server that works as a poor man's VPN. Forwards over ssh. Doesn't require admin access. Works with Linux and MacOS, now including 10.6

It's as simple as

    $ ./sshuttle -r username@sshserver 0.0.0.0/0 -vv

and everything is tunneled through the ssh connection.

All you need is iptables, root access on the local machine and a python binary on server side. No root, no iptables, no extra program running on your server.

Of course you may tunnel just some IPs. Just change the argument to whatever ip network you need.

    $ dig www.youtube.com
    [ ... find youtube's ip ... ]
    $ ./sshuttle -r username@sshserver 74.125.39.0/24 -vv

and every request to Youtube gets tunneled. Great for "This video is not available in your country"-videos if you've got ssh access to a server with an US IP.

I use it for exactly that case: tunneling Youtube requests to view videos. But sometimes, when I exit sshuttle it fails before removing the iptable rules.
As sshuttle is just some python code wrapped around the iptables cli, I figured out what I needed to remove:

    $ iptables -t nat -D OUTPUT -j sshuttle-12300
    $ iptables -t nat -D PREROUTING -j sshuttle-12300
    $ iptables -t nat -F sshuttle-12300
    $ iptables -t nat -X sshuttle-12300

Maybe you have to change the "12300" to something else, use the following command to figure this out:

    $ iptables -t nat -L

(or just read the verbose output)

For more info about how it works and so on read the [README](https://github.com/apenwarr/sshuttle/blob/master/README.md).

Don't forget to read the help if you've got an unusual setup or other problems (some weird path to the python binary on the server, auto-updating hosts file needed, different subnets and excluded subnets, ...):

    $ ./sshuttle -h

Works pretty good and it's secure, so use it!
