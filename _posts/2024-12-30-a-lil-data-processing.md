---
permalink: "/{{ year }}/{{ month }}/{{ day }}/a-lil-data-processing"
title: "A Lil data processing"
published_date: "2024-12-30 10:00:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  I used Lil to process some JSON data in a git repository and turn that into SQL statements.
---

As I [mentioned before](/2024/12/20/a-lil-advent-of-code/) I've been playing around with [Lil] and I like it so far.
So much that for a side project I wrote yet another small one-off script in Lil.

[Lil]: https://beyondloom.com/decker/lil.html

## The scenario

I have a git repository with various files, each of which contains coordinates of a given trip.
Early on in this project's lifetime a script fetched new data, converted it to JSON, updated the corresponding file and committed the changes.
Only later I extended it to actually save additional metadata, such as a timestamp per data point.

So for these early tracking points I now want to restore _some_ sort of timeline, not an exact one, but as close as I can get.
The best I can do is to associate every tracking point added by a commit with that commit's timestamp.
Oh, and also I will end up storing that data in SQLite, not in JSON anymore.

## The data

Every commit diff looks something like this[^1]:

```diff
diff --git trip001.json trip001.json
index 99af4c9..e0c1dea 100644
--- trip001.json
+++ trip001.json
@@ -42,4 +42,6 @@
 ,{"type":"Feature", "properties":{}, "geometry": { "type": "Point", "coordinates": [-28.01577,46.74132] }}
 ,{"type":"Feature", "properties":{}, "geometry": { "type": "Point", "coordinates": [-28.01572,46.74132] }}
 ,{"type":"Feature", "properties":{}, "geometry": { "type": "Point", "coordinates": [-28.01574,46.74126] }}
+,{"type":"Feature", "properties":{}, "geometry": { "type": "Point", "coordinates": [-28.01568,46.74132] }}
+,{"type":"Feature", "properties":{}, "geometry": { "type": "Point", "coordinates": [-28.01571,46.74704] }}
 ] }
```

I will look for each line starting with a `+` and read that line as JSON (after stripping its first `,`).
Then parse out the coordinates[^2].

## The script

Let's start by getting all commits for a particular file:

```lil
commits:"\n" split shell["git log --follow --pretty=format:'%H' -- trip001.json"].out
commits:extract value orderby index desc from commits
```

The second line sorts the resulting list in reverse, ensuring I have the earliest commit first[^3].

```lil
valuefmt:"(%i, %f, %f, '%s', %i);"
insertstmt:"INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES"
```

Just some globals to use later: The SQL statement to generate and a formatting string for the values to put in.

```lil
cmd:" " fuse "git log -1 --pretty=format:%at",commits[0]
id:"%i" parse shell[cmd].out
```

I need _some_ ID and I decided to use the earliest commit's UNIX timestamp to start of with.
This gets incremented to generate a new unique ID per data point.

```lil
each commit in commits
```

Now iterating each commit in the list.

```lil
  cmd:" " fuse "git show --pretty=format:%aI",commit
  diff:"\n" split shell[cmd].out
  dateTime:diff[0]
  unixTime:"%e" parse dateTime
```

To get the diff for every commit invoke `git show`.
The first line will be the commit date in strict ISO 8601 format (that's the `%aI` in that command).
Lil's parsing functionality can turn this into a UNIX timestamp for me.

```lil
  each line in diff
```

The rest of the diff contains the actual text diff.
Go through it line by line.

```lil
    if line[0] = "+"
      s:1 drop line
      if s[0] = ","
        s:1 drop s
      end
      j:"%j" parse s
```

Only lines that start with a `+` (added lines in the diff) are processed further,
stripping the `,` at the start and parsing it as JSON.

```lil
      coord:j.geometry.coordinates
      long:coord[0]
      lat:coord[1]
```

`j` is already the parsed JSON, so I can access its fields.
Should those fields not exist it will coerce to `0`. No error is thrown.

```
      if long = 0
      else
        values:valuefmt format (id, lat, long, dateTime, unixTime)
        stmt:" " fuse (insertstmt, values)
        print[stmt]
        id:id + 1
      end
```

The coordinates might still be `0`, e.g. for the initial `+++ trip001.json`, which will never be valid JSON.
No need to insert null coordinates.
Last but not least, we print the final statement and increment the ID.

```lil
    end
  end
end
```

And it's done.
Now for every data point it outputs an SQL statement:

```shell
; lilt import-trip001.lil
INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES (1717709835, 46.74132, 28.01577, '2024-06-06T21:37:15Z', 1717709835);
INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES (1717709836, 46.74132, 28.01572, '2024-06-06T21:37:15Z', 1717709835);
INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES (1717709837, 46.74126, 28.01574, '2024-06-06T21:37:15Z', 1717709835);
INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES (1717709838, 46.74132, 28.01568, '2024-06-06T21:37:15Z', 1717709835);
INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES (1717709839, 46.74704, 28.01571, '2024-06-06T21:37:15Z', 1717709835);
```

Here's the full script once again:

```lil
commits:"\n" split shell["git log --follow --pretty=format:'%H' -- trip001.json"].out
commits:extract value orderby index desc from commits

valuefmt:"(%i, %f, %f, '%s', %i);"
insertstmt:"INSERT INTO messages (id, latitude, longitude, dateTime, unixTime) VALUES"

cmd:" " fuse "git log -1 --pretty=format:%at",commits[0]
id:"%i" parse shell[cmd].out

each commit in commits
  cmd:" " fuse "git show --pretty=format:%aI",commit
  diff:"\n" split shell[cmd].out
  dateTime:diff[0]
  unixTime:"%e" parse dateTime

  each line in diff
    if line[0] = "+"
      s:1 drop line
      if s[0] = ","
        s:1 drop s
      end
      j:"%j" parse s
      coord:j.geometry.coordinates
      long:coord[0]
      lat:coord[1]

      if long = 0
      else
        values:valuefmt format (id, lat, long, dateTime, unixTime)
        stmt:" " fuse (insertstmt, values)
        print[stmt]
        id:id + 1
      end
    end
  end
end
```

---

_Footnotes:_

[^1]: The coordinates are intentionally obscured.  
[^2]: They are in `longitude, latitude` order. In case you were wondering. Like me every time I stare at them.
[^3]: Sure, I could have used `--reverse`, but where's the fun in that?  
