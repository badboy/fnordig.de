extends: post.liquid
title: "GitHub Pages deployment made easy"
date: 17 Nov 2017 19:47:15 +0100
path: /:year/:month/:day/github-pages-deployment-made-easy
route: blog
---

Recently I tried to deploy a new [Cobalt][]-powered site from [Travis CI][travis], using the [then documented method][olddeploy].
It failed at random and all tries to debug it failed.

[cobalt]: https://github.com/cobalt-org/cobalt.rs
[travis]: https://travis-ci.org/
[olddeploy]: https://github.com/cobalt-org/cobalt.rs/blob/4350f2b012480a4b198f6ef0dabb0ddb47c42abb/README.md#with-travis-ci


That's when I came across Travis' [GitHub Pages Deployment integration](https://docs.travis-ci.com/user/deployment/pages/).

Add the following snippet to your `.travis.yml`:

```yaml
deploy:
  provider: pages
  skip_cleanup: true
  github_token: $GH_TOKEN
  local_dir: build
  on:
    branch: master
```

Now create a new [Personal Access Token](https://github.com/settings/tokens) on GitHub and make sure to include the `public_repo` scope (or the `repo` scope if you're deploying from a private repository).
Copy the provided token and execute the following code in a shell:

```shell
travis encrypt GH_TOKEN=thetokenyougot --add env.global
```

(make sure to replace `thetokenyougot` with the actual token)

Now whenever you push to the `master` branch, Travis will run your build first, then grab all files from the `build` folder, put that into a new commit in the `gh-pages` branch and force-push to GitHub again.
For more settings check the linked documentation (e.g. how to change the folder or branch to be deployed).

Meanwhile, [this became the documented method for Cobalt deployment](https://github.com/cobalt-org/cobalt.rs/pull/333).
