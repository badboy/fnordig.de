---
permalink: "/{{ year }}/{{ month }}/{{ day }}/mdbook-toc-and-mermaid-preprocessors"
title: "mdbook - ToC and Mermaid preprocessors"
published_date: "2019-07-11 13:40:00 +0200"
layout: post.liquid
data:
  route: blog
---

[mdbook][] is a tool to create (online) books from markdown files.
It was created with Rust and is heavily used in the Rust community. Unsurprisingly the biggest and first user is [The Rust Programming Language Book](https://doc.rust-lang.org/book/).

`mdbook` comes with most features you expect from it. It renders directly to HTML,
but also has alternative backends allowing it to [create ePub files][epub] or do some [link checks on the content][linkcheck].

However it lacks some more extensive features, which we required for some internal documentation.
So a while back I sat down and added this functionality.
Back then the only way to extend mdbook's rendering process with more elaborate features was by completely wrapping the mdbook code and add additional features.
`mdbook` was merely a dependency of whatever additional preprocessor was built.
This had multiple drawbacks:

* Build multiple preprocessors into one tool or have one tool wrap other preprocessors
* You need to update the preprocessor's dependencies to get a new mdbook
* You need to use Rust to write the preprocessor

As long as I controlled both the only usage and the code that was ok for our internal use,
but the `mdbook` maintainers realised that this is not viable in the long run for them, so they build a new way to use external tools as preprocessors.
This change should make it much easier to build and use multiple preprocessors.
I even got a PR to update one of my tools.

I just never got around to merge and release that and then do the same for the other tool.
Until earlier this week a colleague asked me about the status of that tool, as he had similar requirements for their documentation.
So during work hours and yesterday's Rust Hack'n'Learn I sat down and integrated the missing pieces to release 2 mdbook preprocessors for easy reuse by others.


## mdbook-toc - add inline Table of Contents support

`mdbook-toc` allows you to automatically create Table of Contents per chapter.
This becomes very useful when you got some long chapters with a lot of little subparts (and you don't want to split it up across chapters/pages).

It turns this markdown:

```markdown
<!-- toc -->

# Header 1

## Header 1.1
```

into this:

```markdown
* [Header 1](#header-1)
  * [Header 1.1](#header-11)

# Header 1

## Header 1.1
```

which eventually becomes:

```html
<ul>
  <li>
    <a href="#header-1">Header 1</a>```
    <ul>
      <li>
        <a href="#header-11">Header 1.1</a>
      </li>
    </ul>
  </li>
</ul>

<h1 id="header-1">Header 1</h1>

<h2 id="header-11">Header 1.1</h2>
```

## mdbook-mermaid - add mermaid.js support

`mdbook-mermaid` adds [mermaid.js][] support to your book.
Diagrams and flowcharts are a wonderful thing to explain architecture & data in a much more concise and precise way than text would do.
Mermaid makes it possible to describe these diagrams in ASCII text, making them easy to modify and track changes over time.

It turns this:

~~~
```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```
~~~

into this:

![Simple Graph](https://tmp.fnordig.de/blog/simple-graph.png)


## How to use

Usage is rather simple. First you need to install it:

```
cargo install mdbook-toc mdbook-mermaid
```

You can also use readily available binaries from the release pages:

* [mdbook-toc release](https://github.com/badboy/mdbook-toc/releases)
* [mdbook-mermaid releases](https://github.com/badboy/mdbook-mermaid/releases)

You then need a little bit of configuration in your book's `book.toml` (the configuration file).

For `mdbook-toc` this is as simple as:

```toml
[preprocessor.toc]
command = "mdbook-toc"
```

For `mdbook-mermaid` this is slightly more involved:

```toml
[preprocessor.mermaid]
command = "mdbook-mermaid"
renderer = ["html"]

[output.html]
additional-css = ["mermaid.css"]
additional-js = ["mermaid.min.js", "mermaid-init.js"]
```

Copy the files (`mermaid.css`, `mermaid.min.js`, `mermaid-init.js`) from the [`assets/`](https://github.com/badboy/mdbook-mermaid/tree/master/assets) directory in the repository into your source directory.

Once everything is installed & configured, you can build your book as usual:

```
mdbook build path/to/your/book
```

And that's it!

## Who uses it?

* [Firefox Data Documentation](https://docs.telemetry.mozilla.org/introduction.html).
    * I switched the Firefox Data Documentation to `mdbook` a while ago, because the previous tool (`gitbook`) was slow and not maintained anymore.
      Relying on tooling that's used by the Rust project seemed to be a good bet.
* [Documentation for Mozilla localizers](https://mozilla-l10n.github.io/localizer-documentation/index.html)
    * Flod, one of the maintainers of the Localizer Documentation, poked me to ask about `mdbook-toc` earlier this week, because it was outdated and awkward to use.
      So I went ahead and polished it ready for a release again.
      It was [quickly integrated](https://github.com/mozilla-l10n/localizer-documentation/pull/157).

[mdbook]: https://github.com/rust-lang-nursery/mdBook
[epub]: https://github.com/Michael-F-Bryan/mdbook-epub
[linkcheck]: https://github.com/Michael-F-Bryan/mdbook-linkcheck
[mdbook-toc]: https://github.com/badboy/mdbook-toc
[mdbook-mermaid]: https://github.com/badboy/mdbook-mermaid
[mermaid.js]: https://mermaidjs.github.io/
