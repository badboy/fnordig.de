---
layout: post
title: fast and simple proxy server
date: 02.10.2011 01:27
---

So you have this friend sitting somewhere else in the world and want to give him a simple proxy to access a geoip-protected site or something similar.  But what tool to use?

When searching for a proxy I found [dante](http://www.inet.no/dante/), but found it just to hard to just configure in a few minutes.

I'm a ruby programmer and I knew [Github](https://github) once released a small open-source proxy programm.
It's called [proxymachine](https://github.com/mojombo/proxymachine), made by [@mojombo](https://github.com/mojombo/), one of the founders of github.

Get it with:

    gem install proxymachine
{:lang="text"}

and you're nearly done.

Pipe the following into a text file:

    proxy do |data|
      next  if data.size < 9
      v, c, port, o1, o2, o3, o4, user = data.unpack("CCnC4a*")
      return { :close => "\x0\x5b\x0\x0\x0\x0\x0\x0" }  if v != 4 or c != 1
      next  if ! idx = user.index("\x0")
      {
        :remote => "#{[o1,o2,o3,o4]*'.'}:#{port}",
        :reply => "\x0\x5a\x0\x0\x0\x0\x0\x0",
        :data => data[idx+9..-1]
      }
    end
{:lang="ruby"}

and start it with

    proxymachine -h 0.0.0.0 -p 1234 -c your_socks_config.rb
{:lang="text"}

Tada! You got your own [SOCKS4](http://en.wikipedia.org/wiki/SOCKS#SOCKS4) Proxy up and running.

[@nerdsein](https://twitter.com/#!/nerdsein/status/120258441041297409) got another solution: [Mocks](http://sourceforge.net/projects/mocks/), "**M**y **O**wn so**CK**s **S**erver."
Download it over at Sourceforge, unpack it and compile the code with:

    gcc -lnsl -o mocks child.c error.c misc.c socksd.c up_proxy.c
{:lang="text"}

You can configure a little bit more than with proxymachine, but you can stick with the default config for now:


    PORT                    = 10080
    MOCKS_ADDR              = 0.0.0.0
    LOG_FILE                = mocks.log
    PID_FILE                = mocks.pid
    BUFFER_SIZE             = 65536
    BACKLOG                 = 5
    NEGOTIATION_TIMEOUT     = 5
    CONNECTION_IDLE_TIMEOUT = 300
    BIND_TIMEOUT            = 30
    SHUTDOWN_TIMEOUT        = 3
    MAX_CONNECTIONS         = 50

    FILTER_POLICY    = ALLOW
{:lang="text"}

See the README and the config file in the archive for comments on it. Then start it with:

    src/mocks -c mocks.config start
{:lang="text"}

and kill it with:

    src/mocks -c mocks.config shutdown
{:lang="text"}

Oh, and in case you have the possibility to just ssh to the server, you can start up a SOCKS proxy on this connection, too:

    ssh -D1234 example.com
{:lang="text"}
