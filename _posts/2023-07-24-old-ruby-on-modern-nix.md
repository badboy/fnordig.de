---
permalink: "/{{ year }}/{{ month }}/{{ day }}/old-ruby-on-modern-nix"
title: "Old Ruby on modern Nix"
published_date: "2023-07-24 14:40:00 +0200"
layout: post.liquid
data:
  route: blog
tags:
  - nix
---

The other day I had to deploy an old Ruby 2.7 application.
As I've recently started experimenting with NixOS I used this as an opportunity to figure out how to reliably and consistently deploy this application.
Along the way I had to figure out a couple of things and the available Nix documentation was either outdated or things didn't work as specified.

## A dev shell for old Ruby

To get started all I wanted was a dev shell with the right Ruby version available.
So I started with [ruby-nix]:

```
nix flake init -t github:inscapist/ruby-nix/main
```

That got me a basic `flake.nix` installing Ruby 3.2.
I trimmed that down just slightly and swapped in Ruby 2.7 (here's the [list of available Ruby version][ruby_avail]):


[ruby-nix]: https://github.com/inscapist/ruby-nix
[ruby_avail]: https://github.com/bobvanderlinden/nixpkgs-ruby/blob/master/ruby/versions.json

```nix
{
  description = "An old Ruby application";

  nixConfig = {
    extra-substituters = "https://nixpkgs-ruby.cachix.org";
    extra-trusted-public-keys =
      "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM=";
  };

  inputs = {
    nixpkgs.url = "nixpkgs";
    ruby-nix = {
      url = "github:inscapist/ruby-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fu.url = "github:numtide/flake-utils";
    bob-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fu, ruby-nix, bob-ruby }:
    with fu.lib;
    eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bob-ruby.overlays.default ];
        };
        rubyNix = ruby-nix.lib pkgs;
        ruby = pkgs."ruby-2.7.8";
      in rec {
        inherit (rubyNix {
          inherit ruby;
          name = "old-ruby-app";
        })
          env;

        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            buildInputs = [ env ];
          };
        };
      });
}
```

The important line is this:

```nix
ruby = pkgs."ruby-2.7.8";
```

`pkgs` contains the `bob-ruby` overlay and so the previously listed Ruby versions are all directly available.

Now on to installing it into a shell:

```bash
nix develop
```

And boom:

```
error: Package ‘openssl-1.1.1u’ in /nix/store/b1l1kkp1g07gy67wglfpwlwaxs1rqkpx-source/pkgs/development/libraries/openssl/default.nix:210 is marked as insecure, refusing to evaluate.


Known issues:
 - OpenSSL 1.1 is reaching its end of life on 2023/09/11 and cannot be supported through the NixOS 23.05 release cycle. https://www.openssl.org/blog/blog/2023/03/28/1.1.1-EOL/

You can install it anyway by allowing this package, using the
following methods:

a) To temporarily allow all insecure packages, you can use an environment
   variable for a single invocation of the nix tools:

     $ export NIXPKGS_ALLOW_INSECURE=1

 Note: For `nix shell`, `nix build`, `nix develop` or any other Nix 2.4+
 (Flake) command, `--impure` must be passed in order to read this
 environment variable.

b) for `nixos-rebuild` you can add ‘openssl-1.1.1u’ to
   `nixpkgs.config.permittedInsecurePackages` in the configuration.nix,
   like so:

     {
       nixpkgs.config.permittedInsecurePackages = [
         "openssl-1.1.1u"
       ];
     }

c) For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can add
   ‘openssl-1.1.1u’ to `permittedInsecurePackages` in
   ~/.config/nixpkgs/config.nix, like so:

     {
       permittedInsecurePackages = [
         "openssl-1.1.1u"
       ];
     }
```

That's ... unfortunate, but at least it tells us what to do:


```
NIXPKGS_ALLOW_INSECURE=1 nix develop --impure
```

And that works:

```
$ NIXPKGS_ALLOW_INSECURE=1 nix develop --impure
(nix:nix-shell-env)
; ruby -v
ruby 2.7.8p225 (2023-03-30 revision 1f4d455848) [arm64-darwin22]
```

Partial success!

## A failed attempt to deploy this on NixOS

I set up a server running NixOS recently and wanted to deploy something like the above to it.
So I added my custom flake as an input and then references it in my `configuration.nix`.

Lo and behold, it failed with an error message like the one above.
But hey, option b) in there said what to do:

```nix
{
 nixpkgs.config.permittedInsecurePackages = [
   "openssl-1.1.1u"
 ];
}
```

Except no matter where, when and how I added this in my configuration it did not work.
I spent a couple of hours trying out every solution I could find on the internet.
None of them worked and neither the error messages nor the documentation could clear this up.

Failure.

## The hack: Ignoring vulnerabilities

[openssl_1_1_vuln]: https://github.com/NixOS/nixpkgs/blob/12303c652b881435065a98729eb7278313041e49/pkgs/development/libraries/openssl/default.nix#L237-L241

Vulnerabilities in `nixpkgs` are declared by adding a `meta.knownVulnerabilities` list.
That's what triggers the error above and the erorr message includes the custom description.
For OpenSSL 1.1 this Vulnerability is declared in [`pkgs/development/libraries/openssl/default.nix`][openssl_1_1_vuln].

Knowing this I later stumbled upon a StackOverflow question: [Nix(OS): Set "permittedInsecurePackages" only for one package build (in an overlay?)](https://stackoverflow.com/questions/53566342/nixos-set-permittedinsecurepackages-only-for-one-package-build-in-an-overl),
which had an answer: Patch the package to just contain an empty `knownVulnerabilities` list.

So I changed my `flake.nix` in the Ruby app to override that just for the Ruby version:

```nix
ignoringVulns = x: x // { meta = (x.meta // { knownVulnerabilities = []; }); };
ruby = pkgs."ruby-2.7.8".override {
  openssl = pkgs.openssl_1_1.overrideAttrs ignoringVulns;
};
```

And now it works without any issues:

```
$ nix develop
(nix:nix-shell-env)
; ruby -v
ruby 2.7.8p225 (2023-03-30 revision 1f4d455848) [arm64-darwin22]
```

No more changes to my NixOS configuration required. Only this particular flake overrides the `openssl` version and that's good enough for this deployment.

Success.
