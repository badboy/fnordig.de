---
permalink: "/{{ year }}/{{ month }}/{{ day }}/texttools-dot-tcl"
title: "Texttools dot tcl"
published_date: "2024-11-03 17:30:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  Recently I read Hillel Wayne's article about his texttools.py implementation.py).
  I also looked into Tcl a bit.
  So what better way than to combine these too and port his Python implementation
  (which was already using Tk) to Tcl (and Wish).
---

Recently I read Hillel Wayne's article about [his texttools.py implementation](texttools.py).

I also looked into [Tcl] a bit.
So what better way than to combine these too and port his Python implementation (which was already using Tk) to Tcl (and Wish).
The functionality is simple:
Paste text in the top box, choose a transform, output appears in the bottom box.

![The texttools tool](https://tmp.fnordig.de/blog/2024/texttools-tcl.png)

[tcl]: https://www.tcl.tk/
[texttools.py]: https://buttondown.com/hillelwayne/archive/texttools-dot-py/

The full implementation is a mere 60 lines of Tcl:

```tcl
#!/usr/bin/env wish

package require textutil

set active_transform 0

proc oneline {text} {
  return [regsub -all \n+ $text " "]
}

proc wordcount {text} {
  set lines [expr [llength [split $text \n]] - 1]
  set words [llength [regexp -all -inline {\S+} $text]]
  set len [string length $text]

  lappend out $lines
  lappend out $words
  lappend out $len
  return $out
}

proc dedent {text} {
  return [textutil::undent $text]
}

proc markdown_quote {text} {
  set text [string trim $text]
  return [string cat "> " [regsub -all \n $text "\n> "]]
}

proc identity {text} { return $text }

lappend transforms [list {None} identity]
lappend transforms [list {One line} oneline]
lappend transforms [list {Line/Word/Char} wordcount]
lappend transforms [list {Dedent} dedent]
lappend transforms [list {Markdown Quote} markdown_quote]

wm geometry . 750x650
wm title . "Text Tools"
wm resizable . false false

text .content
text .output
listbox .transform

foreach {elem} $transforms {
  .transform insert end [lindex $elem 0]
}
.transform selection set $active_transform

grid .transform -row 1 -column 1 -rowspan 2
grid .content -row 1 -column 2
grid .output -row 2 -column 2

focus .content

proc update_output {} {
  global active_transform
  global transforms

  set text [.content get 1.0 end]

  set tf [lindex $transforms $active_transform]
  set out [[lindex $tf 1] $text]
  .output replace 1.0 end $out
}

bind .content <KeyRelease> update_output
bind . <Escape> exit

proc select_transform {args} {
  global active_transform
  set active_transform [.transform curselection]
  update_output
}

bind .transform <Button-1> select_transform

update
```

It's availalable in a repository: [git.fnordig.de/jer/texttools](https://git.fnordig.de/jer/texttools)
