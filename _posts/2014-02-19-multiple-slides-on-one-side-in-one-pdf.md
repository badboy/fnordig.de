---
permalink: "/{{ year }}/{{ month }}/{{ day }}/multiple-slides-on-one-side-in-one-pdf"
title: Multiple slides on one side in one pdf
published_date: "2014-02-19 18:33:00 +0100"
layout: post.liquid
data:
  route: blog
---
Ever had multiple slide sets, e.g. from a lecture, and you needed an overview to print out?
With [LaTeX](http://en.wikipedia.org/wiki/LaTeX) that's easy:

~~~latex
\documentclass[a4paper,12pt,landscape]{article}
 
\usepackage{pdfpages}
 
\begin{document}
  \includepdf[offset=5mm 0, nup=4x4, pages={3,4,5,6}]{slide-set-1.pdf}
  \includepdf[offset=5mm 0, nup=4x4, pages={2,10,20,42}]{slide-set-2.pdf}
\end{document}
~~~

Now just compile this using `pdflatex` and you have a single pdf with a nice overview.
