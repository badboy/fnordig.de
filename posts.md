---
layout: post
title: posts
---

{% for post in site.posts %}
  {% capture currentyear %}{{post.date | date: "%Y"}}{% endcapture %}
  {% if currentyear != year %}
### {{ currentyear  }}
    {% capture year %}{{currentyear}}{% endcapture %}
  {% endif %}
* {{post.date | date_to_string}}: [{{post.title}}]({{post.url | remove_first: '/' | prepend: site.baseurl}})
{% endfor %}
