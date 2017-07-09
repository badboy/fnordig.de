extends: post.liquid
title: network config without ifconfig
date: 25 Dec 2011 14:52:00 +0100
path: /:year/:month/:day/network-config-without-ifconfig
---

[ifconfig](http://linux.die.net/man/8/ifconfig) is more or less deprecated and replaced by [ip](http://linux.die.net/man/8/ip), which has a different syntax.

I cannot remember its full syntax everytime I use it and lookup the syntax over at [tridex' post](http://tridex.net/2011-06-19/linux-netzwerke-ohne-ifconfig/).

But is just to much overhead if I just need one command. So I took half an hour today and "converted" it to a plain text version. You can find it at: <http://tmp.fnordig.de/ip.txt>

Or read here:

    # original: http://tridex.net/2011-06-19/linux-netzwerke-ohne-ifconfig/
    # text version by @badboy_ (fnordig.de)

    | Alte Syntax                 | Neue Syntax                  | Erklärung                                   |
    +-----------------------------+------------------------------+---------------------------------------------+
    | ifconfig eth0 up            | ip link set eth0 up          | Aktivieren der Netzwerkschnittstelle eth0   |
    | ifconfig eth0 down          | ip link set eth0 down        | Deaktivieren der Netzwerkschnittstelle eth0 |
    +-----------------------------+------------------------------+---------------------------------------------+
    | ifconfig eth0               | ip addr show eth0            | Zeigen der IP-Adresse von eth0              |
    +-----------------------------+------------------------------+---------------------------------------------+
    | ifconfig -a                 | ip link                      | Zeigen aller Netzerkschnittstellen          |
    +-----------------------------+------------------------------+---------------------------------------------+
    | ifconfig eth0 promisc       | ip link set eth0 promisc on  | Einschalten des Promisc-Modus               |
    | ifconfig eth0 -promisc      | ip link set eth0 promisc off | Ausschalten des Promisc-Modus               |
    +-----------------------------+------------------------------+---------------------------------------------+
    | ifconfig eth0 192.168.1.1   | ip addr add 192.168.1.1/24   | IP-Adresse zuweisen                         |
    |  netmask 255.255.255.0      |  dev eth0                    |                                             |
    +-----------------------------+------------------------------+---------------------------------------------+
    | route                       | ip route show                | Routen anzeigen                             |
    +-----------------------------+------------------------------+---------------------------------------------+
    | route add default gw        | ip route add default         | Default-Route hinzufügen                    |
    |  192.168.1.10               |  via 192.168.1.10            |                                             |
    +-----------------------------+------------------------------+---------------------------------------------+
    | route del default           | ip route del default         | Default-Route löschen                       |
    +-----------------------------+------------------------------+---------------------------------------------+
    | route add -net 192.168.2.0  | ip route add 192.168.2.0/24  | Netzwerk-Route anlegen                      |
    |  netmask 255.255.255.0      |  via 192.168.1.100 dev eth0  |                                             |
    |  gw 192.168.1.100 dev eth0  |                              |                                             |
    +-----------------------------+------------------------------+---------------------------------------------+
    | route del -net 192.168.2.0  | ip route del 192.168.2.0/24  |  Netzwerk-Route löschen                     |
    |  netmask 255.255.255.0      |  via 192.168.1.100 dev eth0  |                                             |
    |  gw 192.168.1.100 dev eth0  |                              |                                             |
