---
layout: post
title: "novemb.rs Code Sprint weekend 2016 - Retrospective"
date: 29.11.2016 11:55
---

*This post is a tiny bit late, but better late than never.*

So on 19th and 20th of November, just over a week ago, we had the very first [novemb.rs Code Sprint](http://novemb.rs/).
In 10 locations in Europe and the US as well as online, people gathered to hack on projects, start new ones or just to learn Rust.
Bringing people together is one goal of the Rust community and coding, learning and having fun together is a lot of fun as well.

{::options parse_block_html="true" /}
<div class="image" style="text-align:center">
![novemb.rs @ C4](http://tmp.fnordig.de/novemb.rs/th-novembrs-sign.jpg)
<p>We opened doors at Chaos Computer Club Cologne</p>
</div>
{::options parse_block_html="false" /}

I was part of the [novemb.rs Event in Cologne](http://rust.cologne/2016/11/19/novemb-rs.html).
On both days about a dozen people showed up, from noon to late in the evening.

In Cologne, we had several different projects and ideas being worked on:

* Some audio/midi processing. I don't have much to show here, but I hope we will see (and hear) more of this soon, maybe even a talk at our meetup next year.
* [@panicbit](https://github.com/panicbit) and [@killercup](https://github.com/killercup) tried to port [FLIF](http://flif.info/), a "Free Lossless Image Format" to Rust. This kept everyone on-site entertained for quite a bit.
* [@Florob](https://github.com/Florob/rust-xmpp) worked on a problem with buffering, when mixing [rust-openssl](https://github.com/sfackler/rust-openssl) with a [`BufReader`](https://doc.rust-lang.org/stable/std/io/struct.BufReader.html). No code to show sadly either.
* [@colin-kiegel](https://github.com/colin-kiegel) followed up on my [Pull Request on `rust-derive-builder`](https://github.com/colin-kiegel/rust-derive-builder/pull/28), diving deep into Macros 1.1. We decided to move forward with some of the ideas to make that crate use the new way of doing things, once they hit stable.
* As part of my "job" as a community team member I took a look at [rustaceans.org](http://rustaceans.org/), a website is for finding Rustaceans. We will soon extend it to make it easier to find potential speakers for your meetup or event.
* [@sangyye](https://twitter.com/sangyye) dropped by to learn some more Rust. He's one of the organisators behind [Cologne.rb](http://cologne.onruby.de/) and **\*hint\* \*hint\*** [there might be a joint meetup next year](https://github.com/Rustaceans/rust-cologne/issues/19).
* Personally, I wanted to work on [semantic-rs](https://github.com/semantic-rs/semantic-rs/). but didn't get to write a single line of code for that project.
Though I fixed a few other projects and wrote another few hundred lines for a (not yet published) project.

Thanks to our attendees and thanks to my co-organizers Colin, Flo & Pascal.
And another big thanks to Mozilla for sponsoring the pizza and the C4 for offering the space.

### Things that worked well

* We got people together! About a dozen of people per day in Cologne and another handful at other locations as well.
* We got some things coded. See above.
* We learned and discussed Rust and had fun the whole weekend.

### Things that we should improve

* Organization in other locations was a bit ad-hoc and on short-term, which is why we might have missed out on a few people.
* With a bit more time ahead it might be easier to get people involved. We also lacked in communication and (in the beginning) didn't make it clear what the event was supposed to be in.
* novemb.rs tried to focus on people in UTC-1 to UTC+4, which covers most of Europe, but also the African continent.
    People from the US jumped in and opened their offices or other locations as well, but we were unable to get anything going on the African continent.
    We should try harder to get people from everywhere involved.
* Online Communication between locations wasn't used that much. The whole idea was to have a distributed code sprint, so working together on projects across locations would have been nice. Maybe we should offer to have ad-hoc video calls as well?

{::options parse_block_html="true" /}
<div class="image" style="text-align:center">
[![Rust @ Whiteboard](//tmp.fnordig.de/novemb.rs/th-2016-11-20_14.36.28.jpg)](//tmp.fnordig.de/novemb.rs/2016-11-20_14.36.28.jpg)
<p>Coding on the whiteboard (only half of the attendees in the picture)</p>
</div>
{::options parse_block_html="false" /}

### Try again?

Definitely! Given that the overall organization effort is low I'd like to make this a more regular thing.
With the experience from this year we have enough points to improve and we can plan this in advance. Plus, we already have the domain anyway ;)

Until then, there are of course other opportunities to get in contact with fellow Rustaceans.
We have a monthly meetup in Cologne, with a Christmas-themed [`impl Glühwein for RustCologne`](http://rust.cologne/2016/12/07/christmas-maket.html) happening next week.
Feel free to join us on the Weihnachtsmarkt or in January at another more regular meetup.
If you are not from the Rhein area, take a look if there's a [Rust User Group](https://www.rust-lang.org/en-US/user-groups.html) near you.


{::options parse_block_html="true" /}
<div class="image" style="text-align:center">
[![Rust](//tmp.fnordig.de/novemb.rs/th-2016-11-20_12.11.20.jpg)](//tmp.fnordig.de/novemb.rs/2016-11-20_12.11.20.jpg)
<p>Signs showed the way</p>
</div>
{::options parse_block_html="false" /}
