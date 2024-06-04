---
permalink: "/{{ year }}/{{ month }}/{{ day }}/playground-for-hare"
title: "A playground for Hare"
published_date: "2024-06-04 22:59:00 +0200"
layout: post.liquid
data:
  route: blog
excerpt: |
  I built an online for the programming language Hare in Hare.
  Why? Because I wanted to do something fun and learn Hare.
  How? By using some existing libraries and writing the rest myself.
---

I built a thing:

<center>

### [Hare Playground][playground]

</center>

And this is what it looks like:[^1]

![Screenshot of the Hare Playground, the default code example on the left, the out to the right](https://tmp.fnordig.de/blog/2024/hare-playground.png)

It's an online playground for the [Hare programming language][harelang].
Code is sent to the server for compilation and execution.
It responds with the standard and error output serialized into JSON, which gets rendered in the output box in the frontend.
This works just the same as [other](https://go.dev/play/) [playgrounds](https://play.rust-lang.org/).

It's a bit slow and might crash on you, but it works (if it doesn't: reload).

## Why?

Because I wanted to do something fun and learn Hare.
Hare is a rather new systems programming language (started in 2020) that's inspired by C,
but promises to do few things better.
The original blog post [Hare's advances compared to C][advances-on-c] has a good overview on that.

This project gave me the opportunity to explore a couple of areas in Hare,
read through the documentation and the Hare codebase and even fix a few bugs in existing code.

I might write another more detailed blog post on my impressions.
For now I can say that it was a few fun nights learning and exploring a new language.

## How?

The whole codebase is [in the hare-playground repository][hare-playground].
In about 500 lines of my own code plus 3 external libraries I implemented the webserver part,
including routing and static file serving.
I bet it has memory leaks.

```c
fn route_request(buf: *io::stream, serv_req: *http::server_request) (void | http_err) = {
	let request = &serv_req.request;
	switch (request.method) {
	case "GET" =>
		switch (request.target.path) {
		case "/" => handle_index(buf, serv_req);
		case =>
			handle_file(buf, serv_req)?;
			return;
		};
	case "POST" =>
		switch (request.target.path) {
		case "/v1/exec" => handle_exec(buf, serv_req)?;
		case => return notfound;
		};
	case "OPTIONS" =>
		handle_cors(serv_req);
		return;
	case => return notfound;
	};
};
```
> The "router" part of the webserver[^2]

The external libraries I pulled in are:
1. [hare-logfmt] for formatted logging messages (though I only log the minimum).
1. [hare-json] for parsing from and serializing to JSON (unmodified from upstream).
1. [hare-http] for the webserver parts: listening on a socket, parsing HTTP, creating the request and response objects.
I added a couple of commits to fix some issues (available in [my fork](https://git.fnordig.de/jer/hare-http/commits/branch/host-in-uri), I'll upstream them).

I also wrote a [small wrapper around pthread](https://git.fnordig.de/jer/hare-playground/src/branch/main/vendor/hare-thread/thread/thread.ha),
just so my server can handle more than one request at a time.

To run the user-submitted Hare code the server launches `hare` in a [bubblewrap][] sandbox.
This should make it somewhat safe to deal with arbitrary input.
The whole thing runs in a VM on [fly.io],
so even if a sandbox escape is possible the worst an attacker can do is break the VM and ruin the playground for others.

The whole backend even works on macOS (without the sandbox, _do not run in production!_),
thanks to the [Darwin port of Hare](https://github.com/hshq/harelang) (and some of [my own fixes on top](https://github.com/hshq/harelang/compare/master...badboy:harelang:master)).
I wrapped that in a [Nix flake](https://git.fnordig.de/jer/hare-nix) for easy installation.
`nix develop` is all you need in the playground repository.

The frontend is some basic HTML[^3], a couple of lines of JavaScript and [htmx].
The code editor is [Codejar], a small one-file editor implementation.
Code highlighting is handled by [highlight.js]
No JavaScript transpiler or bundler needed.
And yes, I use htmx, but still return JSON from the server and add it to the DOM using JavaScript in the right places.
I'd rather not do the whole HTML escape in Hare right now server-side.
Initially I built this using the JavaScript parts of [codapi],
but I ended up rolling it myself using htmx,
as that gives me more freedom placing & styling the button elements and controlling the output.

## Production when?

I will keep the playground running on Fly (for now).
I do not plan to work on it much further.
This is after all a playground for me to learn the language a bit and not a more serious long-term project.
The code is open-source ([MPL licensed](https://git.fnordig.de/jer/hare-playground/src/branch/main/COPYING)).

[playground]: https://hare-exec.fly.dev/
[harelang]: https://harelang.org/
[advances-on-c]: https://harelang.org/blog/2021-02-09-hare-advances-on-c/
[hare-playground]: https://git.fnordig.de/jer/hare-playground
[bubblewrap]: https://github.com/containers/bubblewrap
[fly.io]: https://fly.io/
[hare-nix]: https://git.fnordig.de/jer/hare-nix
[htmx]: https://htmx.org/
[codapi]: https://codapi.org/
[hare-http]: https://git.sr.ht/~sircmpwn/hare-http
[hare-json]: https://git.sr.ht/~sircmpwn/hare-json/
[hare-logfmt]: https://git.sr.ht/~blainsmith/hare-logfmt
[codejar]: https://medv.io/codejar/
[highlight.js]: https://highlightjs.org/

---

_Footnotes:_

[^1]: Sorry, no dark mode yet.  
[^2]: The syntax highlighter on this site doesn't know about hare, so this code is tagged as C.  
[^3]: Thanks to [Dennis](https://overengineer.dev/) for showing me how simple Flexbox is to use.
