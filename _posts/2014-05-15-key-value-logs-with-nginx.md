extends: post.liquid
title: key=value logs with nginx
date: 15 Apr 2014 18:24:00 +0200
path: /:year/:month/:day/key-value-logs-with-nginx
---

In [Six Ways to Make Your Production Logs More Useful][fun-with-logs] [@roidrage][] talked about how to make your logs much more useful.
One of the proposed solutions was to use a format that is more structured and thus easier to read: `key=value` logging.
This way it's easy to parse for a human eye, but a machine will have no problems either.
And of course your standard shell tools (with the combination of some basic regular expressions) will still work to find what you want in your logs.

This blog and all of my other sites run on [nginx][] and with nginx it is very easy to use a custom log format.
Just define a new `log_format`, give it a meaningful name and the layout you want. For example I use the following now:

~~~shell
log_format  keyvalue  'time=$time_iso8601 ip=$remote_addr user=$remote_user req="$request" '
                  'status=$status bytes_sent=$body_bytes_sent req_time=$request_time ref="$http_referer" '
                  'ua="$http_user_agent" forwarded="$http_x_forwarded_for"';
~~~

Put this in your `http {}` block and wherever you define a new access log file append `keyvalue` (or the name you have chosen) like this:

~~~shell
access_log  /var/log/nginx/access.log  keyvalue;
~~~

And voilà:

~~~shell
$ tail -1 /var/log/nginx/access.log
time=2014-04-15T18:20:54+02:00 ip=127.0.0.1 user=- req="GET / HTTP/1.1" status=301 bytes_sent=184 req_time=0.000 ref="-" ua="curl/7.36.0" forwarded="-"
~~~

If you want to know which variables are available, read the [nginx docs][docs].

_Update:_ [@rhoml][] pointed me to a [full overview of available variables][variables].


[fun-with-logs]: http://blog.travis-ci.com/2014-04-11-fun-with-logs/
[@roidrage]: https://twitter.com/roidrage
[nginx]: http://nginx.org/
[docs]: http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format
[@rhoml]: https://twitter.com/rhoml/status/456115016178364416
[variables]: http://nginx.org/en/docs/http/ngx_http_core_module.html#variables
