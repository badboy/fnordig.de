---
permalink: "/{{ year }}/{{ month }}/{{ day }}/doh-everything"
title: "DOH everything"
published_date: "2018-02-09 14:52:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - rust
---

Two days ago [I wrote about a new small utility crate](/2018/02/07/d-oh-dns-over-https-in-rust/) for doing DNS over HTTPS.
When I started with the code on Monday I had an actual use case in mind.

Due to some combination of [SmartOS](https://www.joyent.com/smartos), Ubuntu 17.04 and glibc my server currently has problems resolving DNS.
It turns out a server without a working DNS resolver is kind of a pain, adding hostnames and their IPs to `/etc/hosts` gets tiring pretty fast.

Luckily, glibc's [`gethostbyname`](http://man7.org/linux/man-pages/man3/gethostbyname.3.html) makes us of external plugins to do the actual resolving.
That's how `/etc/hosts` and an external resolver work in the first place.
The [documentation on the exact plugin mechanism](http://www.gnu.org/software/libc/manual/html_node/NSS-Modules-Interface.html#NSS-Modules-Interface) is quite sparse, but luckily *systemd* comes with its own resolve plugin: [nss-resolve.c](https://github.com/systemd/systemd/blob/master/src/nss-resolve/nss-resolve.c).

All it takes to build a resolver plugin is to implement two functions[^1]:

```
enum nss_status _nss_$plugin_gethostbyname4_r(...)
enum nss_status _nss_$plugin_gethostbyname3_r(...)
```

Both take a bunch of arguments, but it boils down to this:

1. Get the hostname (and optionally the address family to look for)
2. Resolve this hostname to its IP addresses[^2]
3. Copy the data into the provided buffer
4. Let the result point somewhere into this buffer
5. Clear the error values and return a success value

If at any point an error is encountered, several error values are set and the function returns a failure.

If all goes right, the requesting application will receive a data structure to read the different IP addresses from, which it can then use to establish a connection.

Equipped with [dnsoverhttps](https://crates.io/crates/dnsoverhttps) the resolving part is suprisingly easy.
First turn the passed name into a string, then call into the library and collect the results.

```rust
unsafe {
    let slice = CStr::from_ptr(orig_name);
    let name = slice.to_string_lossy();
    let addrs = match dnsoverhttps::resolve_host(&name) {
        Ok(a) => a,
        Err(_) => {
            *errnop = EINVAL;
            *h_errnop = NO_RECOVERY;
            return NSS_STATUS_UNAVAIL;
        }
    };

    // ...
}
```

Filling the appropiate data structures and memory buffer is a bit more complex and involves some pointer trickery.
Instead of trying to find the right (unsafe) approach in Rust to do it correctly I opted to copy the `systemd`-code for now.

In the Rust part we can forward the received arguments and add an array of results[^3]:

```rust
let addrs : Vec<_> = addrs.into_iter().map(ip_addr_to_tuple).collect();

write_addresses4(orig_name, pat, buffer, buflen, errnop, h_errnop, ttlp,
  addrs.as_ptr(), addrs.len())
```

This calls into a function [written in C](https://github.com/badboy/libnss_dnsoverhttps/blob/a3f25c92881ec1d1100ea4e7f7d399d1c51b80b6/src/write_addr.c#L13-L19) and [compiled just before the Rust code is compiled](https://github.com/badboy/libnss_dnsoverhttps/blob/a3f25c92881ec1d1100ea4e7f7d399d1c51b80b6/build.rs).
It's also statically linked into the resulting shared object, ready to be deployed.

In order to use it, the library has to be copied into a directory where the system can find it:

```
cp target/release/libnss_dnsoverhttps.so /usr/lib/libnss_dnsoverhttps.so.2
```

And then it can finally be used by adding it to `/etc/nsswitch.conf` like this:

```
hosts: dnsoverhttps files mymachines dns myhostname
```

`curl` and other processes calling `gethostbyname` will from now on get addresses resolved by this small module.

<br>

---

[^1]: And forward `_nss_$plugin_gethostbyname2_r` and `_nss_$plugin_gethostbyname_r` to `_nss_$plugin_gethostbyname3_r`.

[^2]: Remember that you can't use `gethostbyname` here, because you _are_ `gethostbyname`.

[^3]: In between turning our vector of addresses into a simpler structure.
