extends: post.liquid
title: Create GitHub releases with Rust using Hubcaps
date: 23 Feb 2016 20:32:00 +0100
path: /:year/:month/:day/create-releases-using-hubcaps-a-rust-library
---

For one of my projects I need to access the GitHub API to create releases.
Luckily, through reading [This Week in Rust #119][twir], I discovered [Hubcaps][], a library for interfacing with GitHub.

Though it lacks some documentation and is not yet fully finished, it already provides APIs for the relevant parts regarding releases.

On GitHub a release is always associated with a [Git tag][gittag], but need to be specifially created to be shown on the site with the full description and optional assets attached to them.
It is also possible to mark releases as a draft (then it is only visible to repo contributors) or as a pre-release, useful for alpha releases of a library or application.

Once you have a Git tag in your repository the API can be used to create an associated release using the following Rust code:


~~~rust
extern crate hyper;
extern crate hubcaps;

use std::{env, process};
use hyper::Client;
use hubcaps::{Github, ReleaseOptions};

fn main() {
    let token = match env::var("GITHUB_TOKEN").ok() {
        Some(token) => token,
        _ => {
            println!("example missing GITHUB_TOKEN");
            process::exit(1);
        }
    };

    let client = Client::new();
    let github = Github::new("hubcaps/0.1.1", &client, Some(token));

    let user = "username";
    let repo = "my-library";
    let name = "ONE DOT OH";
    let body = "This is a long long body";
    let tag = "v1.0.0";

    let opts = ReleaseOptions::builder(tag)
        .name(name)
        .body(body)
        .commitish("master")
        .draft(false)
        .prerelease(false)
        .build();

    let repo = github.repo(user, repo);
    let release = repo.releases();
    match release.create(&opts) {
        Ok(_) => println!("Release created"),
        Err(e) => println!("Failed to create release: {:?}", e),
    };
}
~~~

If you clone [Hubcaps][] and put the above code in a file named `releases.rs` into the `examples/` folder, you can run it with `cargo run --example releases`.
You need to get a [personal access token](https://github.com/settings/tokens) first and set it in your environment (`export GITHUB_TOKEN=<your token here>`)

Of course it has the repository and tag hard-coded, but this is easy to adapt.

_The code was tested with Rust 1.6 and hubcaps 0.1.1_

_[Updated version](https://gist.github.com/badboy/0cbc3411b6c23c1cb33c) to work with hubcaps 0.2.0 online._

[twir]: https://this-week-in-rust.org/blog/2016/02/22/this-week-in-rust-119/
[hubcaps]: https://github.com/softprops/hubcaps
[gittag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging
