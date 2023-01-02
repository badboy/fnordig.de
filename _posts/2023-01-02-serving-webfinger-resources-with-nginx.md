---
permalink: "/{{ year }}/{{ month }}/{{ day }}/serving-webfinger-resources-with-nginx"
title: "Serving WebFinger resources with Nginx"
published_date: "2023-01-02 14:30:00 +0100"
layout: post.liquid
data:
  route: blog
---

As I'm starting to use Mastodon more and more,
I'm also learning more about how the underlying ActivityPub protocol works[^1].

While it is not possible to statically host something that allows one to publish posts on ActivityPub from one's own domain,
it is possible to expose user accounts as aliases for accounts on other servers.
I learned this from Maarten Balliauw's post ["Mastodon on your own domain without hosting a server"][source]
and then implemented it for my own server.

[source]: https://blog.maartenballiauw.be/post/2022/11/05/mastodon-own-donain-without-hosting-server.html

I'm running Nginx as the web server in front of all other services.
Nginx is powerful and expressive enough to do a whole bunch of routing in its configuration itself,
no further tools needed.
WebFinger uses the `/.well-known/webfinger` path on a domain to retrieve information about available accounts.
The `resource` query parameter identifies which account it wants the information of.

Matching query parameters using Nginx requires a bit of extra setup.
I already posted the necessary bits in a [TIL entry][til] last month.
To adopt this for WebFinger I created a map to match on the `resource=acct:user` part:

[til]: https://fnordig.de/til/nginx/match-query-parameters.html

```
map $query_string $account_name {
    ~resource=acct:janerik@fnordig.de$ janerik;
    ~resource=acct:jer@fnordig.de$ janerik;
}
```

Due to how Nginx matches against the query string this will only match `resource=` when it's the last query parameter.
But because I don't even need to handle any additional parameters from the query string this is good enough.

I then added a location block for the exact URL for that virtual host:

```
location = /.well-known/webfinger {
    root  /var/www/sites/webfinger;

    if ($account_name) {
      rewrite ^(.*)$ /$account_name.json break;
    }

    try_files $uri = 404;
}
```

And I then have a file `/var/www/sites/webfinger/janerik.json` with the right content:

```json
{
  "subject": "acct:jer@hachyderm.io",
  "aliases": [
    "https://hachyderm.io/@jer",
    "https://hachyderm.io/users/jer"
  ],
  "links": [
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "https://hachyderm.io/@jer"
    },
    {
      "rel": "self",
      "type": "application/activity+json",
      "href": "https://hachyderm.io/users/jer"
    },
    {
      "rel": "http://ostatus.org/schema/1.0/subscribe",
      "template": "https://hachyderm.io/authorize_interaction?uri={uri}"
    }
  ]
}
```

This whole setup allows me to precisely match only the usernames I want it to match (and not just being a catch-all domain)
and makes it easy to extend it in the future, should I ever need to.

---

_Footnotes:_

[^1]: See also: [Deploying GoToSocial on fly.io](/2022/11/21/gotosocial-on-fly-io/).
