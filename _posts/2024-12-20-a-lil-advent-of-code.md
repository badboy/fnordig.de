---
permalink: "/{{ year }}/{{ month }}/{{ day }}/a-lil-advent-of-code"
title: "A Lil Advent of Code"
published_date: "2024-12-20 20:00:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  I solved the first 3 days worth of puzzles of this year's Advent of Code in Lil,
  a tiny programming language, part of the Decker project.
  These are my solutions and brief thoughts on Lil.
---

_This post won't include too much explanation. I wanted a place to at least put my code and that's what I have a blog for._

It's December, so everyone is doing [Advent of Code](https://adventofcode.com/).
I'm not. Or so I told myself.

This week, while on vacation, I had some downtime and played around with [Decker][][^1] and its accompanying programming language [Lil].

Armed with the [tutorial][liltutorial], the [reference card][lilquickref] and the [Lil Terminal][lilt] installed, I set out to learn it and solved three days worth of puzzles from the ongoing Advent of Code 2024[^2].

[Decker]: https://beyondloom.com/decker/
[Lil]: https://beyondloom.com/decker/lil.html
[liltutorial]: https://beyondloom.com/decker/learnlil.html
[lilquickref]: https://beyondloom.com/decker/lilquickref.html
[lilt]: https://beyondloom.com/decker/lilt.html

Want to jump ahead? [Day 1](#day1) | [Day 2](#day2) | [Day 3](#day3) | [Thoughts](#thoughts)

## <a name="day1"></a> Day 1

On Day 1 you get two lists side-by-side, need to order each one individually, then take the absolute differences and add them up.
Part 2 requires you to find the number of times an element shows up in the other list.

That can be done in Lil like this:

```
example:"%i  %i" parse "\n" split "
3   4
4   3
2   5
1   3
3   9
3   3
"

on sort l do
  extract value orderby value asc from l
end

on reverse l do
  extract value orderby index desc from l
end

on part1 input do
  sorted:sort @ flip input
  result:sum each x in (sorted[0] - sorted[1]) mag x end
  print[result]
end

on dump name x do
  print[name]
  print["," fuse (list "%J") format x]
end

on part2 input do
  lists:flip input
  left:extract value where value > 0 from lists[0]
  right:extract value where value > 0 from lists[1]
  counts:each elem in left
    sum right=elem
  end
  result:sum left*counts
  print[result]
end

part1[example]
part2[example]
```

Example:

```
; lilt aoc1.lil
11
31
```

## <a name="day2"></a> Day 2

On Day 2 you have to determine which reports are safe.
A report is a line of numbers and if they match some rules it is considered safe.
Count those safe ones.

And part 2 allows you to make some reports safe by ignoring some results.

```
example:"7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

on spreadcheck elems do
  prod each elem in -2 window elems
    diff:mag elem[0]-elem[1]
    (diff-1) > 0 and (diff-1) < 3
  end
end

on allincr elems do
  prod each elem in -2 window elems elem[0] < elem[1] end
end

on alldecr elems do
  prod each elem in -2 window elems elem[0] > elem[1] end
end

on reportcheck report do
  report:on _ elem do "%i" parse elem end @ report
  (max allincr[report],alldecr[report]) * spreadcheck[report]
end

on part1 input do
  reports:on _ line do " " split line end @ "\n" split input

  result:sum reportcheck @ reports
  show[result]
end

on part2 input do
  reports:on _ line do " " split line end @ "\n" split input

  result:each report in reports
    report:on _ elem do "%i" parse elem end @ report
    valid:(max allincr[report],alldecr[report]) & spreadcheck[report]
    if valid
      1
    else
      max each i in range count report
        newreport:extract value where !(index=i) from report
        (max allincr[newreport],alldecr[newreport]) & spreadcheck[newreport]
      end
    end
  end
  show[sum result]
end

part1[example]
part2[example]
```

Example:

```
; lilt aoc2.lil
2
4
```

## <a name="day3"></a> Day 3

I couldn't stop, so I also solved day 3.

Day 3 has a garbled string containing some instructions to multiply some numbers.
Part 2 has additional instructions that turns on or off those instructions.

I opted to iterate the string input and match for the expected patterns.

```
example:"xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
example2:"xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

on part1 input do
  f:"mul(%i,%i)"
  result:sum each i in range count input
    curinp:i drop input
    ab:f parse i drop input
    offset:(count "mul(")+(count "," fuse ab)
    if curinp[offset]=")"
      prod ab
    end
  end
  show[result]
end

on part2 input do
  f:"mul(%i,%i)"
  do_:"do()"
  dont:"don't()"
  enabled:1
  result:sum each i in range count input
    curinp:i drop input
    if ((count do_) limit curinp)=do_
      enabled:1
    end
    if ((count dont) limit curinp)=dont
      enabled:0
    end

    if (4 limit curinp)="mul("
      ab:f parse curinp
      offset:(count "mul(")+(count "," fuse ab)
      if enabled & curinp[offset]=")"
        prod ab
      end
    end
  end
  show[result]
end

part1[example]
part2[example2]
```

Run it:

```
; lilt aoc3.lil
159892596
92626942
```

## <a name="thoughts"></a> Thoughts

I like Lil.
It's small, it's simple and it's surprisingly fast.
It also gets the job done.
These `name:data` variable assignments threw me off a bit, but I got over that hump.

[jq](https://jqlang.github.io/jq/) is a powerful tool to work with JSON, but for the sake of it I can't remember any more of its syntax than the basic `.[]`.
Reading and transforming a JSON file using Lil instead felt very intuitive.
I opted to write a script I needed to transform some JSON into some other output it was intuitive.

This is how you read and parse a JSON file[^3]:

```
json:"%j" parse read["droids.json"]
```

And then you can access the data:

```
 extract n:name d:description where name like "Astro.*" from table json.data
{"n":("Astromech Droid"),"d":("Astromech droids are a series of versatile utility robots generally used for the maintenance and repair of starships and related technology. These small droids are often equipped with a variety of tool-tipped appendages that are stowed in recessed compartments. The R2 unit is a popular example of an astromech droid.")}
```

Not needing to deal with missing fields or inconsistencies in the format
makes it easy to ignore the error cases,
something that comes in handy for one-off scripts.

Now I need to take a closer look at Decker and how this powerful language can be used with it.

---

_Footnotes:_

[^1]: Decker is a "multimedia platform for creating and sharing interactive documents". I have yet to actually do something cool with Decker itself.  
[^2]: I didn't _know_ I would be doing 3. But I finished Day 1 quickly, Day 2 not long after and Day 3 was done an hour later. I looked at Day 4 and how to solve it was not immediately clear, so I stopped.  
[^3]: Data from the [`droids` endpoint of the Star Wars Databank](https://starwars-databank-server.vercel.app/api/v1/droids/)
