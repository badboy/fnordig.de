---
permalink: "/{{ year }}/{{ month }}/{{ day }}/load-your-config-into-your-environment"
title: Load your config into your environment
published_date: "2016-03-04 12:30:00 +0100"
layout: post.liquid
data:
  route: blog
---
It became quite popular to store certain configuration variables in your environment, to be later loaded by your aplication.
This way of [having all configuration][config] available is part of the [twelve-factor app definition][12factor].

The idea is to place your variables in a `.env` file and load this as environment variables to be accessed by your application.
Most of the time you can just plug in one of the dozens of libraries that load this config from a file and your application can fetch the values as normal from the environment.

But sometimes you might want to have this config loaded into your shell or some other interactive tool.
That's where you can use `dotenv-shell`, a small tool, written in Rust.
It wraps around [rust-dotenv][dotenv] and allows to load the config and then execute a program (your shell by default).

First install the tool:

~~~
cargo install dotenv-shell
~~~

Create a `.env` file with your config:

~~~
echo "REDIS_URL=redis://localhost:6379" > .env
~~~

Then start a shell and you can access the configuration as environment variables:

~~~
$ dotenv-shell
$ echo $REDIS_URL
redis://localhost:6379
~~~

Of course you can launch whatever tool you want:

~~~
$ dotenv-shell /usr/bin/irb
irb(main):001:0> ENV['REDIS_URL']
=> "redis://localhost:6379"
~~~

[Available on GitHub][repo] and [as a Crate][crate].

**Update:**

Only now I learn about another application doing just the same: [benv](https://github.com/timonv/benv) by [@timonvonk](https://twitter.com/timonvonk).

[12factor]: http://12factor.net/
[config]: http://12factor.net/config
[dotenv]: https://github.com/slapresta/rust-dotenv
[repo]: https://github.com/badboy/dotenv-shell
[crate]: https://crates.io/crates/dotenv-shell
