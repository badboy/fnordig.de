permalink: "/{{ year }}/{{ month }}/{{ day }}/d-oh-dns-over-https-in-rust"
title: "D'oh! - DNS over HTTPS in Rust"
published_date: "2018-02-07 09:05:00 +0100"
layout: post.liquid
data:
  route: blog
---

Last weekend I met [Daniel Stenberg][bagder], author of curl, at FOSDEM and we talked a bit about curl, Firefox and also Rust.
One recent project he was working on was *DNS over HTTPS* [support for Firefox][firefox] and [eventually for curl][curl] as well.

*DNS over HTTPS*, short *DOH*, is a recent idea to do DNS queries over HTTPS for privacy, performance and security reasons. There's a [RFC draft in version 3][draft03][^1] at the IETF describing it in more detail.  
The *tl;dr*: Send the DNS protocol in a HTTP POST request or base64-encoded in a GET request,
get back the DNS protocol in the response body and parse it.

Given how simple that sounds, I decided to implement a minimal DOH client in Rust.
I present to you:

<center>
### [dnsoverhttps][]
</center>

It exports one function to resolve a hostname to its IPv6 and IPv4 addresses:

```
extern crate dnsoverhttps;

fn main() {
    let name = "example.com";
    let addr = dnsoverhttps::resolve_host(name);

    for a in addr {
        println!("{} has address {}", name, a);
    }
}
```

It currently uses `dns.google.com` (or to be exact one of its IPs: `172.217.21.110`) and skips TLS certificate checks (because the underlying HTTP request library has no option to pass in the hostname yet).
It will also always query for both IPv6 and IPv4 addresses (`AAAA` and `A` records respectively).
`CNAME` records will work as well by the mere fact that the server recursively resolves it and `dnsoverhttps` simply takes the found IP address.
Other records are not supported at the moment.

For a quick try you can install the bundled CLI tool to replace the `host` tool to resolve hostnames.

```
cargo install dnsoverhttps
```

And then execute it:

```
$ ~/.cargo/bin/host example.com
example.com has address 2606:2800:220:1:248:1893:25c8:1946
example.com has address 93.184.216.34
```

[Documentation is available online][docs].

[bagder]: https://twitter.com/bagder
[curl]: https://github.com/curl/curl/wiki/DNS-over-HTTPS
[firefox]: https://bugzilla.mozilla.org/show_bug.cgi?id=1434852
[draft03]: https://tools.ietf.org/html/draft-ietf-doh-dns-over-https-02
[dnsoverhttps]: https://github.com/badboy/dnsoverhttps
[docs]: https://docs.rs/dnsoverhttps/0.1.0/dnsoverhttps/

[^1]: `dnsoverhttps` currently implements Version 2, because that's what `dns.google.com` supports. Version 3 changes the query parameter from `body` to `dns`.
