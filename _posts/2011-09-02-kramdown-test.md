---
permalink: "/{{ year }}/{{ month }}/{{ day }}/kramdown-test"
title: now with code higlighting
published_date: "2011-09-02 00:00:00 +0100"
layout: post.liquid
data:
  route: blog
---
I am a programmer and I like to write code and I like to talk about code. That's why this blog really needs some syntax highlighting for my favorite languages.

With [jekyll][] as my static site generator it is easy to enable it. Just get the [kramdown][] library for [markdown](http://daringfireball.net/projects/markdown/) parsing and [coderay][] for the highlighting. Then enable both in your configuration.

This is my current _[_config.yml](https://github.com/badboy/fnordig.de/blob/master/_config.yml)_:

~~~yaml
paginate: 5
permalink: pretty
exclude: Rakefile
markdown: kramdown
kramdown:
  use_coderay: true

  coderay:
    coderay_line_numbers:
    coderay_tab_width: 2
    coderay_css: class
~~~

If you use `coderay_css: class` make sure to include a CSS file on your page (see my [coderay.css](/coderay.css)).

Adding syntax-highlighted code in your post now works like this:

        indent code by 4 spaces
        even multi-line
        and define language after code block
    {:lang="ruby"}

And now some real highlighting to show it in action:

~~~ruby
module CodeRay
  def about
    [self.name.downcase, 'rocks!'].join(" ")
  end
  module_function :about
end
~~~

And that's it.

[coderay-github]: https://github.com/rubychan/coderay
[coderay]: http://coderay.rubychan.de/
[jekyll]: https://github.com/mojombo/jekyll
[kramdown]: https://github.com/gettalong/kramdown
