---
permalink: "/{{ year }}/{{ month }}/{{ day }}/edit-this-file-on-github"
title: "\"Edit this file on GitHub\""
published_date: "2020-02-06 16:38:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
    - rust
---

At work I help with maintaining two large documentation books:

* [Firefox Data Docs](https://docs.telemetry.mozilla.org/) aka docs.telemetry.mozilla.org aka dtmo
* [The Glean SDK book](https://mozilla.github.io/glean/book/index.html)

Back in 2018 I migrated dtmo from gitbook to [mdbook](https://github.com/rust-lang/mdBook) (see [the pull request](https://github.com/mozilla/firefox-data-docs/pull/187)).
mdbook is maintained by the Rust project and hosts the [Rust book](https://doc.rust-lang.org/book/) as well as a multitude of other community projects.
It provided all we need, plus a way to extend it with some small things, I blogged about [ToC and mermaid](http://localhost:8000/2019/07/11/mdbook-toc-and-mermaid-preprocessors/) before.

During the Mozilla All Hands last week my colleague Mike casually asked why we don't have links to quickly edit the documentation.
When someone discovers a mistake or inaccuracy in the book the current process involves finding the repository of the book, then finding the right file, then edit that file (through the GitHub UI or by cloning the repository),
then push changes, open a pull request, wait for review and finally get it merged and deployed.

I immediately set out to build this feature.

I present to you: **[mdbook-open-on-gh](https://github.com/badboy/mdbook-open-on-gh/)**

It's another preprocessor for mdbook, that adds a link to the edit dialog on GitHub (if your book is actually hosted on GitHub).
And that's how it looks:

![Screenshot of a Glean SDK book site showing the "Edit this file on GitHub" link](https://tmp.fnordig.de/blog/2020/open-on-gh-gleanbook.png)

It's already deployed on dtmo and the Glean SDK book and simplifies the workflow to: click the link, edit the file on GitHub, commit and open a PR, get a review and merge it to deploy.

If you want to use this preprocessor, install it:

```
cargo install mdbook-open-on-gh
```

Add it as a preprocessor to your `book.toml`:

```toml
[preprocessor.open-on-gh]
command = "mdbook-open-on-gh"
renderer = ["html"]
```

Add a repository URL to use as a base in your `book.toml`:

```toml
[output.html]
git-repository-url = "https://github.com/mozilla/glean"
```

To style the footer add a custom CSS file for your HTML output:

```toml
[output.html]
additional-css = ["open-in.css"]
```

And in `open-in.css` style the `<footer>` element or directly the CSS element id `open-on-gh`:

```css
footer {
  font-size: 0.8em;
  text-align: center;
  border-top: 1px solid black;
  padding: 5px 0;
}
```

This code block shrinks the text size, center-aligns it under the rest of the content
and adds a small horizontal bar above the text to separate it from the page content.


Finally, build your book as normal:

```
mdbook path/to/book
```
