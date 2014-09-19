---
layout: post
title: posts
---

{% for post in site.posts %}
* {{post.date | date_to_string}}: [{{post.title}}]({{post.url | remove_first: '/' | prepend: site.baseurl}})
{% endfor %}
