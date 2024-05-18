---
permalink: "/{{ year }}/{{ month }}/{{ day }}/dark-mode-for-the-ages"
title: "Dark mode for the ages"
published_date: "2024-05-18 13:23:00 +0200"
layout: post.liquid
data:
  route: blog
excerpt: |
  Last night I was still up and awake at 2 am.
  I opened this website and ... BOOM ... bright light in my eyes.
  So I did what anyone who can't sleep at that hour does:
  I implemented a dark mode theme for my website.
---

They say projects are not finished until you write about them.
So here we go.

Last night I was still up and awake at 2 am.
I opened this website and ... BOOM ... bright light in my eyes.
I do like this site's simple colorscheme,
but when everything around you is dark it does kinda burn in your eyes.
So I did what anyone who can't sleep at that hour does:
I went on the internet, looked up how to change colors in CSS and implemented a theme toggle on my website (Look for the sun or moon on the top right!)

There's many articles on this topic, the one I found was
[The simplest CSS variable dark mode theme][theme-switcher] by Luke Lowrey.

My site is a very simple plain ol' HTML & CSS page.
I use [Writ] as the base style and provide just a few things on top in my [style.css].
The colors are now defined like this:

```css
:root,
html[data-theme='light'] {
  --main-bg-color: white;
  --text-color: #111;
  --alt-text-color: black;
  --code-bg: rgba(0,0,0,.05);;
  --border-color: rgba(0,0,0,.05);
  --link-color: #00e;
  --link-color-visited: #60b;
  --inline-code: #111;
}

html[data-theme='dark'] {
  --main-bg-color: #111;
  --text-color: #b3b3b3;
  --alt-text-color: #999999;
  --code-bg: #ccc;
  --border-color: #414141;
  --link-color: #478be6;
  --link-color-visited: #c988ff;
  --inline-code: #323232;
}
```

and then used with `var(--main-bg-color)` further below.

The theme toggle button requires a bit of JavaScript, which I straight out copied from Luke's blogpost (and put into [theme.js]).

```javascript
var toggle = document.getElementById("theme-toggle");

var storedTheme = localStorage.getItem('theme') || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
if (storedTheme) {
    document.documentElement.setAttribute('data-theme', storedTheme)
}

toggle.onclick = function() {
  var currentTheme = document.documentElement.getAttribute("data-theme");
  var targetTheme = "light";

  if (currentTheme === "light") {
    targetTheme = "dark";
  }

  document.documentElement.setAttribute('data-theme', targetTheme)
  localStorage.setItem('theme', targetTheme);
};
```

It stores the user's preference in local storage and defaults to the system's prefered color scheme (see [`prefers-color-scheme`][mdn]).

Once I had it all in place I realized I've been testing the colors with my macOS' Night Shift mode on.
Oh well, looks good with it on, looks still decent with it off I guess.
The dark theme is not perfect and probably could use a bit more contrast.
Code blocks look odd as they are essentially still light mode (just slightly dimmed),
because the current code syntax highlighting does the styling inline
and so it's a bit hard to overwrite that in the external CSS.
But I decided it's better to ship the 80% solution then never get to shipping at all.


[theme-switcher]: https://lukelowrey.com/css-variable-theme-switcher/
[writ]: https://writ.cmcenroe.me/
[style.css]: https://fnordig.de/style.css
[theme.js]: https://fnordig.de/theme.js
[mdn]: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme
