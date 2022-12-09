---
permalink: "/{{ year }}/{{ month }}/{{ day }}/select-solution-from-aoc-where-year-2022"
title: "SELECT solution FROM aoc WHERE year = 2022"
published_date: "2022-12-09 11:20:00 +0100"
layout: post.liquid
data:
  route: blog
---

Every year [Advent of Code][aoc] happens.
Every year I'm not super enthusiastic to actually solve those challenges.
Every year I still start (and then maybe stop after some days).

2022 was similar.
I don't have a new programming language to learn and I still write enough code day-by-day that more coding is not really necessary.
But yet sometimes it can be kind of nice to have a small challenge with a clear solution to go for
and so I set myself some rules and went ahead.

## My own rules

* Solve it in SQL.
  * I started to run that in [BigQuery], but moved to [SQLite].
* Only the SQL the system provides. How far can I take this?
  * It was easier on BigQuery with its large base of functionality, including string procesing, arrays, structs, ...
  * On SQLite initially I tried to avoid any custom functionality, I later relaxed this rule: [SQLean] is okay occasionally.
  * Once (so far) I used Python to preprocess the data. SQL is just really not good at text processing.
* Getting the solution once is good enough.
  * The code can be ugly, messy and inefficient.
* I don't write tests.
  * I do test. Just manually against the test input.
* No persistent data.
  * It's all in-memory tables, CTEs, temporary views and a bunch of `SELECT`.
* Learn some arcane SQL features.
  * Did you know SQL can recurse and select over windows? I do now!

These are my rules. I break them when I feel like it.

[AoC]: https://adventofcode.com/
[bigquery]: https://cloud.google.com/bigquery/
[sqlite]: https://sqlite.org/
[sqlean]: https://github.com/nalgeon/sqlean

## Sneak peek of day 1

`SELECT solution FROM aoc WHERE year = 2022 AND day = 1;`

I plan to release my solutions publicly, but I haven't yet.
So for now you get my solution to day 1:

```sql
CREATE TABLE data(raw);
.import input01.txt data
WITH
groups AS (
  SELECT rowid, ROW_NUMBER() OVER (ORDER BY rowid) cat FROM data WHERE raw = ''
),
elves AS (
  SELECT
    COALESCE(
      (SELECT cat FROM groups WHERE data.rowid < groups.rowid LIMIT 1),
      (SELECT cat + 1 FROM groups ORDER BY cat DESC LIMIT 1)
    ) AS elf,
    raw as calories
  FROM data WHERE raw != ''
),
part1 AS (
  SELECT
    elf,
    SUM(calories) AS total_calories
  FROM elves
  GROUP BY 1
  ORDER BY 2 DESC
)

--SELECT * FROM part1;
SELECT SUM(total_calories) as best_3 FROM (
    SELECT * FROM part1 LIMIT 3
);
```

Runnable as:

```
sqlite3 < aoc01.sql
```

(Oh, another rule: It needs to run as `sqlite3 < script.sql`)
