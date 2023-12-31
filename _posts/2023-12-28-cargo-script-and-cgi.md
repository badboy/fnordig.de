---
permalink: "/{{ year }}/{{ month }}/{{ day }}/cargo-script-and-cgi"
title: "cargo script and cgi"
published_date: "2023-12-28 18:30:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  Everything old is new again.
  These days things get deployed as Cloud Functions, Lambdas or whatever FaaS it is today.
  But those from the old days simply stuck with CGI and that's easily possible with Rust too.
---

Everything old is new again.
These days things get deployed as Cloud Functions, Lambdas or whatever [FaaS](https://en.wikipedia.org/wiki/Function_as_a_service) it is today.
But those from the old days [simply stuck with CGI](https://rednafi.com/go/reminiscing_cgi_scripts/).

Modern[^1] Rust is perfect for that kind of world!
Cargo now has support for single-file packages ([RFC 3424]),
which allows you to stuff all your code into a single `.rs` file and then run that.
It even caches the built binary, so it's efficient enough to run on every request.

I went ahead and updated the [cgi] crate ([my fork here][cgi-fork]).
Now all it takes is this little bit of Rust code:

````rust
#!/usr/bin/env -S cargo +nightly -q -Zscript
```cargo
[dependencies]
cgi2 = "0.7"
```

#[cgi::main]
fn main(_request: cgi::Request) -> cgi::Response {
    cgi::text_response(200, "Hello World!")
}
````

Install the [fcgiwrap] tool, follow the instructions to configure Nginx and voilà:
<https://fnordig.de/cgi-bin/hello-world.rs>

Need some state? Throw in a database and you can keep track of that too:
<https://fnordig.de/cgi-bin/counter.rs>
The source code is [available in a Gist][gist]. That's barely 50 lines (plus dependencies).

Go deploy some cloud functions ... I mean lambdas ... I mean CGI scripts!

[RFC 3424]: https://github.com/rust-lang/rfcs/blob/798ba4e1ef2175400e4c029cf952aa2d6df96f45/text/3424-cargo-script.md
[fcgiwrap]: https://www.nginx.com/resources/wiki/start/topics/examples/fcgiwrap/
[cgi]: https://crates.io/crates/cgi
[cgi-fork]: https://github.com/badboy/rust-cgi
[hello-world.rs]: https://fnordig.de/cgi-bin/hello-world.rs
[gist]: https://gist.github.com/badboy/13dae661300e7e09b6f5430297fc341c

---

_Footnotes:_

[^1]: Nightly.
