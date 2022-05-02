---
permalink: "/{{ year }}/{{ month }}/{{ day }}/hytradboi"
title: "Reflections on HYTRADBOI"
published_date: "2022-04-30 15:26:00 +0200"
layout: post.liquid
data:
  route: blog
excerpt: |
  Yesterday the HYTRADBOI conference happened.
  These are my talk talk recommendations and thoughts on the conference format.
---

Yesterday the [HYTRADBOI][hytradboi] conference happened.

> Have you tried rubbing a database on it?

First of: a big thanks to the organizer [Jamie Brandon][jamie] and a huge shout-out to all speakers for putting in the time and effort to fill this conference with amazing content.

[jamie]: https://www.scattered-thoughts.net/
[hytradboi]: https://www.hytradboi.com/

All talks are now freely available on [the website][hytradboi].
I didn't see ALL the talks, so what follows is a list of those I can recommend to watch:

### [Why Airtable is easy to learn and hard to outgrow](https://www.hytradboi.com/2022/why-airtable-is-easy-to-learn-and-hard-to-outgrow)

by Mary Rose Cook.

I peaked at Airtable a couple of times, but never found a good use case for which I needed Airtable.
I get why people use it though and Mary gives an excellent rundown of its capabilities and functionality.

### [Working with virtual time in SQL](https://www.hytradboi.com/2022/working-with-virtual-time-in-sql)

by Frank McSherry.

Showcasing Materialize and how it streams incremental views over data.
I need to re-watch this, it flew by too fast.

Side note: I researched streaming systems and incremental SQL queries in 2017 or so and nearly ended up with a Master thesis topic around this.

### [Building data-centric apps with a reactive relational database](https://www.hytradboi.com/2022/building-data-centric-apps-with-a-reactive-relational-database)

by Nicholas Schiefer.

The [Building data-centric apps with a reactive relational database](https://riffle.systems/essays/prelude/) essay as a 10 minute talk.
Shows the MyTunes app in action, so worth a look even if you read the essay already.

### [How to query (almost) everything](https://www.hytradboi.com/2022/how-to-query-almost-everything)

by Predrag Gruevski.

Easily the talk I recommend the most.
I ended up in the talk's room afterwards, discussing with the speaker and others about it more.
Predrag showed the [trustfall] query engine, which can be connected to basically any data source, be that an existing database, an API, a file system or anything else you can think of, with a bit of more code.
Queries are written in GraphQL.

And yes, it's written in Rust, which of course is another advantage. I plan to take a closer look at this.

[trustfall]: https://github.com/obi1kenobi/trustfall/

### [Debugging by querying a database of all program state](https://www.hytradboi.com/2022/debugging-by-querying-a-database-of-all-program-state)

by Kyle Huey.

Demo-ing [Pernosco](https://pernos.co/) and going into the details how the data system behind it works.
I've used Pernosco a handful of times for Firefox debugging. It is extremely powerful.
I didn't realize how complex collecting and storing data for a debug run really is.

### [Simple Graph: SQLite as (probably) the only graph database you'll ever need](https://www.hytradboi.com/2022/simple-graph-sqlite-as-probably-the-only-graph-database-youll-ever-need)

by Denis Papathanasiou.

Did you know you can use SQLite as a graph database?
Sure, it's not as optimized as a dedicated graph database, but maybe it's enough for your application.
Code is at [github.com/dpapathanasiou/simple-graph](https://github.com/dpapathanasiou/simple-graph)
[The database schema](https://github.com/dpapathanasiou/simple-graph/blob/main/sql/schema.sql) fits into two tweets.

### [Datasette: a big bag of tricks for solving interesting problems using SQLite](https://www.hytradboi.com/2022/datasette-a-big-bag-of-tricks-for-solving-interesting-problems-using-sqlite)

by Simon Willison.

Another talk from Simon showcasing [Datasette] and [sqlite-utils].
Solid talk. Go watch it if you don't know Datasette yet.

[datasette]: https://datasette.io/
[sqlite-utils]: https://datasette.io/

---

## The conference

I was [kinda excited](https://twitter.com/badboy_/status/1514580543144448006) for this conference from the get go.
Over the past 6 months or so my interest in all things data grew beyond my job (as a sort-of data engineer that is),
but I was also looking forward to see yet another approach on running an online conference.

I know how hard it is to put together events. Jamie did this one all on his own. Kudos to that!

The conference came with its own chat: a private [Matrix] server containing an Announcement room, a Hallway room and two additional rooms, one per track.
The server went online 2 weeks ago already, but was mostly quiet for that time.
Unfortunately by the time the conference started (yesterday 18:00 Berlin time) the server faced major availability issues.
Scaling up a Matrix server for 550 users requires some work and it took some time for [Jamie to figure out the issue](https://twitter.com/sc13ts/status/1520114317026160640).
That bumpy start dampened the conference experience a little bit. I administrate a Matrix server myself and I don't think I would have figured this out beforehand.
So once again kudos to Jamie!

With 550 people attending the chat got quite busy and it became hard to follow individual discussions.
Luckily speakers and attendees naturally gravitated towards breaking out into individual talk rooms.
For RustFest in 2020 we went with one room per talk from the start and I would recommend that for other events of that size as well.

The talks where all <= 10 minutes.
I'm a huge fan of lightning talks of that length.
In my opinion it is the absolute best way to cover a large amount of topics in a short amount of time.
If a talk is not of interest to you you don't have to wait long for the next topic.
10 minute talks also make it more likely that you actually watch them after the conference again.

The talks were separated into 2 tracks with 3 talks back-to-back.
But because all talks were pre-recorded they were instantly accessible in whatever order or at whatever time one wanted.
This was actually a problem for me initially:
I wanted to cook dinner while listening to talks, but because they were individual videos I had to interrupt cooking to switch videos.
I would have preferred a way for talks to automatically run back-to-back in a single stream this time.

This format of delivery also made the chat harder to follow.
Not everyone starts the talks at the same time or in the same order necessarily.
That's where individual rooms per talk could come in handy again.
As my evening progressed I did choose my own order and speed to watch the talks.
Given it was my Friday evening after work, this "choose your own track" way of watching the talks played in my favor.

I think some middle ground of this format is worthwhile:
The ability to watch in sync with others to steer the discussion,
but also the possibility to re-watch talks at a time convenient for me.
Of course this requires a bit more setup and infrastructure.

Before I left the conference (and well before it officially ended) I did ask whether the Matrix server would stay on for a bit longer.
Others asked the same and it seems it will now be available for another week or so, making it possible to scroll back through the discussions.
That's one of the reasons why I dislike individual, private and time-limited chat platforms for conferences:
The discussions there are often highly valuable and it's worth coming back to read them,
but if everything is its own thing it will be lost much quicker.
Sure, most active conversations probably drop off 24 hours after the conference, but some might be going or have some information valuable to others later.

All in all I think this was a pretty good online conference.
The few talks I saw were all worth watching and I have some more on my list to watch now.
I had good conversations with some people and new projects to look into now.
None of the issues mentioned were a real deal breaker for me and can be easily addressed next time.

I hope for another edition next year!

[Matrix]: https://matrix.org/
