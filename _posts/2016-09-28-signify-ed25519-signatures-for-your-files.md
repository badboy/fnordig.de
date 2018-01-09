permalink: "/{{ year }}/{{ month }}/{{ day }}/signify-ed25519-signatures-for-your-files"
title: "Signify - Ed25519 signatures for your files (in Rust)"
published_date: "2016-09-28 13:16:00 +0200"
layout: post.liquid
data:
  route: blog
---
From time to time I try to write a piece of code or port some existing library or application just for fun.
So a while back in June I had some free time again and I came across [signify][].
I ported it to rust: [signify-rs][]

`signify` is a small command line utility to create [Ed25519][] signatures of files.
It was developed to cryptographically sign and verify OpenBSD releases. Read ["Securing OpenBSD From Us To You"][openbsd] for more details.

Now all you need to create signatures and verify them is a private & a public key.
Both parts are super short, so it is no problem to embed or print them.
This is what a public key would look like:

> RWR/JMX+u3pyzGSyTSnOFINVcHJycZE/o6UTUshxvpcp6S4annmJK4DB

The corresponding private key is this:

> RWRCSwAAAAASfh0v1XJS4FYg59ntf4d7zYS9GR848h1/JMX+u3pyzIFNjvCMxLUgurelzAWTCSd9y6ghUcbcPVMuwnlDJy4WZLJNKc4Ug1VwcnJxkT+jpRNSyHG+lynpLhqeeYkrgME=

(**Warning: Do NOT use above keys for anything! I included both for demonstration only**)

`signify` will add an additional comment to the key files, but they are not used for any verification (besides making sure they are actually in the file).

Whereas pure Ed25519 keys are just 32 bytes, above keys already include some additional information used by signify to create and verify signatures. The private key can also be protected by a passphrase.

When I started porting this small application I knew nothing about Ed25519 or signify.
I more or less translated the existing C code into Rust.
Back then, I used [rust-crypto][], a pure Rust implementation various common cryptographic algorithms.
It provided all I needed: Ed25519 key generation, signing & verification and bcrypt for the passphrase handling.
In just one day I had a working application and less than 2 weeks later I also implemented proper passphrase-protection.

In August then the most promising Rust crypto library, [\*ring\*][ring], was released on crates.io as well (before that it could only be used as a git dependency).
I used \*ring\* before for [nobsign][] and [Brian Smith][brian], the author of \*ring\*, already helped out with some code review & helping me use the API properly.  
So I was not too surprised when Brian reached out to me asking if I would be willing to port `signify-rs` over to \*ring\* as well.

I was (however, it was shortly before [RustFest][], so I couldn't dedicate much time to it).

I took a look at the [\*ring\* documentation][ringdocu] and immediately realised I had a completely wrong understanding of Ed25519.
Whereas in `signify` the public key is stored in 32 byte and the private key is stored in 64 byte,
\*ring\* had both keys as only 32 byte long.
With feedback from Brian I realised that the longer private key as used in `signify`
is actually just the 32-byte public key concatenated to the (real) 32-byte private key, resulting in 64 byte total.

Equipped with this information (and after the first RustFest day was over), it was easy to port over `signify-rs` to \*ring\*.

`signify-rs` still depends on `rust-crypto` though, as it provides the necessary `bcrypt_pbkdf` for encrypting the private key with a user-chosen passphrase. \*ring\* does not provide `bcrypt` and probably won't do so anytime soon.
If anyone wants to implement a really good `bcrypt` crate, please contact me or Brian for feedback.

## Use `signify-rs`

First you need to install it, do so with `cargo`:

~~~
cargo install signify
~~~

Generate a key pair:

~~~
signify -G -p public-key -s secret-key
~~~

This will ask you for a passphrase to protect the secret key. Remember that.
Now you can sign a file:

~~~
signify -S -s secret-key -m README.md
~~~

This will create `README.md.sig` containing the signature.
To verify it:

~~~
signify -V -p public-key -m README.md
~~~

If it prints `Signature Verified` it went well. Otherwise it will show an error.

## A signature

This is the signature using above private key on the [README.md](https://github.com/badboy/signify-rs/blob/177717053fb155d554cb1f697310bda1143edba4/README.md):

> untrusted comment: signature from signify secret key  
> RWR/JMX+u3pyzIDv+Gt4JwMbWsb+dt0R/9tYDEjVw7zmBQoQR06Pcd2yr03XqvTSqaJBTbUhm74iUxB98BQVAZemq692g5Xv0gs=

If you put that signature in a file, put the public key from above into another, you can verify it!

## Future plans

I still have todos left for this project.
First I want this to be fully compatbile with the original implemenation.
The original implementation can embed signatures into the signed file and also verify an embedded signature. I want to add that.
I also want to distribute pre-compiled binaries for various platforms (hello, [rust-everywhere][])
and provide proper Ed25519 signatures on all those releases.

If you want to help with any of that, jump over [to the GitHub repository][gh] and start hacking.

[signify]: https://github.com/aperezdc/signify
[signify-rs]: https://github.com/badboy/signify-rs
[ed25519]: https://ed25519.cr.yp.to/
[openbsd]: https://www.openbsd.org/papers/bsdcan-signify.html
[rust-crypto]: https://crates.io/crates/rust-crypto
[ring]: https://crates.io/crates/ring
[brian]: https://twitter.com/BRIAN_____
[nobsign]: https://github.com/badboy/nobsign
[rustfest]: http://www.rustfest.eu/
[ringdocu]: https://briansmith.org/rustdoc/ring/
[rust-everywhere]: https://github.com/japaric/rust-everywhere
[gh]: https://github.com/badboy/signify-rs
