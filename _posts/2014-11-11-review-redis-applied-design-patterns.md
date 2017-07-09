extends: post.liquid
title: "Review: Redis Applied Design Patterns"
date: 11 Nov 2014 00:41:00 +0100
path: /:year/:month/:day/review-redis-applied-design-patterns
---

In the mid of October I was approached by Packt Publishing asking if
I would be willing to review a newly released eBook called *Redis Applied Design Patterns* by Arun Chinnachamy.
I agreed to review the 100 page eBook given that I'm free to criticize the book as I see fit.

It took me some time to finish the book, but flights to Salzburg, New York and Honolulu meant enough (offline) time to read everything in detail
and write the review. So here it is.

### What is it about?

The book gives an overview of different use cases of Redis.
It is definitely not for beginners, but for people that are already familiar how to setup Redis and how to use it.
The books starts with the basics of a key-value store and how it differs from relational databases.
It then goes on to discuss a wide variety of use cases.
From using Redis as a cache store, using it as the main data store for e-commerce inventories or a comment system
to using it for autosuggestion, real-time analysis and game leaderboards.
Each chapter of the book discusses one of the named use cases, explaining the used Redis commands and
showing code and ideas on how to implement the given system.

### The good things

Having different use cases documented and accessible in a concise way is really useful.
The book shows a wide range of these use cases and not only discusses the simplest implementation,
but also tries to give an outlook on further iterations for the given requirements, building a increasingly complex system step by step.

It doesn't focus on a single aspect of Redis and shows off a lot of the available commands and data types.
Included are explanations of the used commands as they are described on [redis.io][commands],
as well as links to the documentation for people that want a deeper understanding.
The included code samples are kept short and are a mix of PHP code, implementing the discussed use case,
and single Redis commands, showing how they work and what values they return.
Even for programmers without knowledge of PHP, it should be possible to understand the implementation and adopt it for the language of choice.

The chapters are short and self-contained and the book is short enough to be read in just one afternoon (it took me longer because I took a lot of notes to come up with this review).

### The not so good things

Quickly after I started reading the book I was a bit baffled about the overall text and code quality.
The very first thing I noticed was that some of the code examples used slightly different key names as the describing text itself.
This didn't block the understanding of the overall concept, but is certainly a thing that needs to be improved.

Slightly off-putting are the code samples itself, especially the ones that are larger than just a couple of lines.
They use an inconsistent code style (`CamelCase` vs. `snake_case` in one single line) and could use just a little more explanations here and there
(or the text should refer to lines more directly).
Some code examples are just plain wrong.
The more advanced problem solutions are only briefly mentioned in the text and no code examples are shown.

It is nice to have the used Redis commands explained once, but the book mostly copies the official documentation for this.
It also mentions the time complexity of each command, but nowhere in the book it is explained what `O(n)` actually means ([Big O notation][bigo] explained in the Wikipedia).

As mentioned, the chapters are mostly independent of each other, which makes it easy to just jump in and read them in whatever order you want.
But as the first 3 chapters explain how things work in Redis, other chapters could easily refer back to them.
Instead latter chapters discuss things again or link only to the online documentation.
One chapter is actually re-implementing the same stuff as in the chapter before.
Plain references between chapters could save this duplication and help the reader to jump between chapters.

I won't discuss each chapter in detail, but there are two things that I need to mention here.
First, the chapter about an auto-suggest system uses the old approach of using n-grams in Sorted Sets,
but since version 2.8.9 (released in April 2014) Redis has powerful lexicographic commands like [ZRANGEBYLEX][],
which are not mentioned in the book at all (though I don't know when the book was written, maybe a future version can include this).
Second, the summary of the last chapter talks about scaling Redis across multiple machines and mentions Sentinel as *under development* and usable for this, which is just incorrect (for the ones that don't know: [Sentinel][] is considered stable since 2.8 and is used for monitoring and failover, if you want to shard your data use [Redis Cluster][cluster]).
There are a few other minor incorrect things or explanations that leave out some important details.

If you are already familiar with Redis, these things are obvious, but if you only know the basics and want to read up on possible implementations, the errors and mistakes will misguide you.
This makes it hard to recommend the book as a useful resource on Redis design patterns.

### Conclusion

*Redis Applied Design Patterns* is a short little book explaining different use cases of Redis.
It gives insight into different techniques and implementations of high-level features.
But don't expect to be a super Redis pro after reading it.
The given examples are only touching the surface and show the most basic implementations.
The book should definitely be revised to fix several issues in quality and correctness.
A more in-depth discussion on more complex implementations and revised examples would make it recommendable,
but at this stage it is not.

In case you want to buy the book anyway, use [this link][buy].

[buy]: https://www.packtpub.com/networking-and-servers/redis-applied-design-patterns?utm_source=ashb.com&utm_medium=all&utm_campaign=Redis
[packtpub]: http://www.packtpub.com
[commands]: http://redis.io/commands
[zrangebylex]: http://redis.io/commands/zrangebylex
[sentinel]: http://redis.io/topics/sentinel
[cluster]: http://redis.io/topics/cluster-spec
[bigo]: http://en.wikipedia.org/wiki/Big_O_notation
