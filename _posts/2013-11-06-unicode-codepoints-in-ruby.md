extends: post.liquid
title: Unicode codepoints in ruby
date: 06 Nov 2013 12:04:00 +0100
path: /:year/:month/:day/unicode-codepoints-in-ruby
---
Another post of the category "better write it down before you forget it".

I ❤ Unicode. Atleast most of the time. That's why I have things like ✓, ✗ and
ツ mapped directly on my keyboard.

But sometimes you need not only the symbol itself, but maybe the codepoint as well. That's easy in ruby:

~~~ruby
irb> "❤".codepoints
=> [10084]
~~~

Got some codepoints and need to map it back to it's symbol? Easy:

~~~ruby
irb> [10084, 10003].pack("U*")
=> "❤✓"
~~~

Oh, of course the usual `\uXYZ` syntax works aswell, but you need the hexstring for that:

~~~ruby
irb> 10084.to_s 16
=> "2764"
irb> "\u{2764}"
=> "❤"
~~~

Sometimes you may need to see the actual bytes. This is easy in ruby aswell:

~~~ruby
irb> "❤".bytes
=> [226, 157, 164]
~~~

There is documentation on these things:

* [each_codepoint][]
* [codepoints][]
* [bytes][]

Enjoy the world of unicode! [❤][unicode-heart]

[each_codepoint]: http://www.ruby-doc.org/core-2.0.0/String.html#method-i-each_codepoint
[codepoints]: http://www.ruby-doc.org/core-2.0.0/String.html#method-i-codepoints
[bytes]: http://www.ruby-doc.org/core-2.0.0/String.html#method-i-bytes
[unicode-heart]: http://codepoints.net/U+2764
