permalink: "/{{ year }}/{{ month }}/{{ day }}/blog-running-with-jekyll"
title: Blog running on jekyll again
published_date: "2011-08-25 00:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
I decided to setup a blog again. And again I'll use [jekyll][], a `blog-aware, static site generator in Ruby`.

I redesigned the page for better viewing (a layout for smartphones will follow).

What's still missing is a good deployment process. I'm currently thinking about using [github][] for the repository and having my server informed by their post-receive hook.

Ah, and of course some content. I will use this blog to document the things I do. May it be some weird configuration thing for my server or just some code I wrote or read the other day (and for that I need code highlighting here, I really would appreciate if I could use [CodeRay][] somehow)

I'm not yet sure if and how I will implement an option to comment on this site. I'm currently thinking about wether it would be possible to fetch comments via twitter and if that would be enough.

So as long as there is no direct comment integration here, feel free to contact me over at twitter: [@badboy\_](https://twitter.com/badboy_).

[jekyll]: https://github.com/mojombo/jekyll
[github]: https://github.com/
[CodeRay]: https://github.com/rubychan/coderay
