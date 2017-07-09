extends: simple.liquid
title: Posts
route: posts
path: /posts
---

{% assign years = "2017, 2016, 2015, 2014, 2013, 2012, 2011" | split: ", " %}
{% for year in years %}
  ### {{year}}

  {% for post in posts %}
    {% assign postyear = post.date | date: "%Y" %}
    {% if postyear == year %}
* {{post.date | date: "%d %b"}}: [{{post.title}}](/{{post.path}})
    {% endif %}
  {% endfor %}
{%endfor%}
