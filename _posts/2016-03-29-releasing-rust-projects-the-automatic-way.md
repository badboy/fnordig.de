---
permalink: "/{{ year }}/{{ month }}/{{ day }}/releasing-rust-projects-the-automatic-way"
title: "Releasing Rust projects, the automatic way"
published_date: "2016-03-29 20:47:00 +0200"
data:
  route: blog
  tags:
    - rust
---
One of the strength of the Rust ecosystem is its package manager [Cargo][] and the package system [crates.io][].
Pulling in some dependencies is as easy as adding it to your projects' `Cargo.toml` and running `cargo build`.

Releasing your own project is nearly as easy. Make sure you got everything working, add a version number in your `Cargo.toml` and run `cargo publish`.
It will package the code and upload it.

Of course that's not the whole story.
For a proper release that people will like to use you want to follow some good practices:

1. Have tests and make sure they are green. Most people already use [Travis CI](https://travis-ci.org). The [travis-cargo](https://github.com/huonw/travis-cargo) project makes it easy to test all channels (stable, beta, nightly, maybe a specific version), run documentation tests and upload coverage info and documentation.
2. Keep a changelog. Your software is not done with the first release. It changes, bugs get fixed, new features get introduced. Keeping a changelog helps users to understand what changed from version to version.
3. Pick a version number. This is not nearly as easy as it sounds. Your project's version number carries a lot of information. Often more than we'd like. The Rust ecosystem recommends to strictly follow [semver][], but even that has ambiguities and requires a lot of thinking to do the right thing.
4. Release on the right platforms. Even though [crates.io][] is the package system you want your project in, having a GitHub release is a nice to have. Maybe your project is an application and you want to distributed pre-compiled binaries.

At the moment a lot of people process each of these steps manually.
Maybe they have a few scripts lying around that help in reducing the number of errors that can happen.
All in all there's still to much manual work required.
It does not have to be that way.

[Stephan Bönnemann][boennemann] build [semantic-release][] for the npm eco system a while ago.
It allows for fully automated package publishing by relying on a few conventions and a lot of automatisation.

I wanted to have a similar thing for the Rust eco system. That's why Jan aka [@neinasaservice][neinasaservice] and I sat down at last year's 32c3 and started hacking on a tool to achieve that.

It took us a while to get something working, but now I can present to you:

## [<center>🚀 semantic-rs 🚀</center>][semantic-rs]

## What is it?

[semantic-rs][] gives you fully automatic crate publishing.
It runs after your tests are finished, analyzes the latest commits, picks out a version number, creates a commit and git tag, creates a release on GitHub and publishes your crate on crates.io.

All you have to do is follow the [Angular.js commit message conventions][angular], which are really easy.
Your commit message consists of a type, an optional scope, a subject and an optional body.

~~~
<type>(<scope>): <subject>
<BLANK LINE>
<body>
~~~

The type should be one of the following:

* **feat**:     A new feature
* **fix**:      A bug fix
* **docs**:     Documentation only changes
* **style**:    White-space, formatting, missing semi-colons, etc
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **perf**:     A code change that improves performance
* **test**:     Adding missing tests
* **chore**:    Changes to the build process or auxiliary tools/libraries/documentation

The next version number is decided depending on type of commits since the last release.
A **feat** will trigger a minor version bump, a **fix** a patch version bump.
The other types don't cause a release.

However, should you make a breaking change, you need to document this in the commit message as well.
Include **BREAKING CHANGE** in the body of the commit message and add information what changed
and how to change existing code to make it work again (if possible).
This will then trigger a major version bump.

## What works?

The **Happy Path**.

If everything is configured properly and the tests succeed, semantic-rs will correctly pick a version,
add changes to a `Changelog.md`, create a release commit, tag it, create a GitHub release and publish on crates.io.

The [test-project](https://crates.io/crates/test-project) crate is published completely automatically now.

`semantic-rs` already has some safety features integrated.
It will only run when the build is on the master branch (or the branch you configure),
and it will make sure that it only runs once on the build leader (which is always the first job in your build matrix).
It also waits for the other jobs to finish and succeed before trying to do a release.

## What's missing?

In case of problems, semantic-rs will just bail out.
That might leave you with changes pushed to GitHub, but not published on crates.io (at worst),
or with no visible changes but no new release (at best).
We're working hard on making this safer to use with better error reporting.

Installing `semantic-rs` from source each time your tests run adds significant overhead to the build time, as it must be compiled again and again.
In the future we will provide binary releases that you can simpy drop into Travis and it will work.

It's not released on crates.io yet, because we're using a dependency from GitHub. That one should soon be fixed once they push out a release as well.

---

Now that we got that out of the way, let's see how to actually use it.

## How to use it

Right now usage of `semantic-rs` is not as straight-forward as it can be, we're working on that.
To run it on Travis you have to follow these manual steps.

The first job of your build matrix will be used to do the publish, so make sure it is a full build.
Make it your stable build to be on the safe side.
Your `.travis.yml` should contain this:

~~~yaml
rust:
  - stable
  - beta
  - nightly
~~~

Next, install `semantic-rs` on Travis by adding this to your `.travis.yml`:

~~~yaml
before_script:
  - |
      cargo install --git https://github.com/semantic-rs/semantic-rs --debug &&
      export PATH=$HOME/.cargo/bin:$PATH &&
      git config --global user.name semantic-rs &&
      git config --global user.email semantic@rs
~~~

(This installs `semantic-rs` in debug mode, which is quite a lot faster to compile without significant runtime impact at the moment)

This will also set a git user and mail address, which will be used to create the git tag.
You can change this to your own name and email address.

Now add a [personal access token](https://github.com/settings/tokens) from GitHub.
It only needs the `public_repo` permission (unless of course your repository is private).

Add it to your `.travis.yml` encrypted:

~~~shell
$ travis encrypt GH_TOKEN=<your token here> --add env.global
~~~

To release on [crates.io][] you need a token as well. Get it [from your account settings](https://crates.io/me) and add it to your `.travis.yml`:

~~~shell
$ travis encrypt CARGO_TOKEN=<your token here> --add env.global
~~~

At last make sure `semantic-rs` runs after the tests succeeds. Add this to the `.travis.yml`:

~~~yaml
after_success:
  - semantic-rs
~~~

Make sure to follow the [AngularJS Git Commit Message Conventions][angular].
`semantic-rs` will use this convention to decide which should be the next release version.

See [the full `.travis.yml`](https://github.com/badboy/test-project/blob/34246077dbf375d144f86a01711cbd9e527b11ea/.travis.yml) of our test project.

## What's next?

We still have some plans for semantic-rs.

First we need to make it more safe and easy to integrate into a project's workflow.

We also want to look into how we can determine more information about a project to assist the developers.
Ideas we have include running integration tests from the previous version to detect breaking changes
and statically analyzing code changes to determine their impact. Rust's [RFC 1105](https://github.com/rust-lang/rfcs/issues/1105) already defines the impact certain changes should have. Maybe it is possible to automatically check some of these things.

We would be happy to hear from you. If semantic-rs breaks or otherwise does not fit into your workflow, let us know. [Open an issue](https://github.com/semantic-rs/semantic-rs/issues/new) to discuss this.
If you want to use it and have more ideas what is necessary or could be improved, talk to us!

[semantic-rs]: https://github.com/semantic-rs/semantic-rs
[semantic-release]: https://github.com/semantic-release/semantic-release
[boennemann]: https://twitter.com/boennemann
[neinasaservice]: https://twitter.com/neinasaservice
[cargo]: https://github.com/rust-lang/cargo
[crates.io]: https://crates.io/
[semver]: http://semver.org/
[angular]: https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit?pref=2&pli=1#heading=h.uyo6cb12dt6w
