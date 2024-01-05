---
permalink: "/{{ year }}/{{ month }}/{{ day }}/gotosocial-on-fly-io"
title: "Deploying GoToSocial on fly.io"
published_date: "2022-11-21 22:50:00 +0100"
layout: post.liquid
data:
  route: blog
---

Everyone and their dog is getting on [ActivityPub].
Yes, [me too][hachyderm], for now.
Mastodon is what everyone is going for,
but running an instance is kinda resource intensive
and I really don't want to be responsible for yet another service.

Mastodon is not the only implementation of ActivityPub though.
[GoToSocial] is another.
So why not try it?
Let's deploy it on [fly.io].

[ActivityPub]: https://github.com/badboy/gotosocial-fly
[hachyderm]: https://hachyderm.io/@jer
[gotosocial]: https://gotosocial.org/
[git]: https://github.com/badboy/gotosocial-fly
[fly.io]: https://fly.io/

We start by creating a new Fly app.
We stick to a generated name and put it into Frankfurt.

```shell
$ mkdir -p Documents/gotosocial-fly
$ cd Documents/gotosocial-fly
$ fly launch
Creating app in /Users/jer/Documents/gotosocial-fly
Scanning source code
Could not find a Dockerfile, nor detect a runtime or framework from source code. Continuing with a blank app.
? Choose an app name (leave blank to generate one):
automatically selected personal organization: jer
? Choose a region for deployment: Frankfurt, Germany (fra)
Created app young-darkness-8503 in organization personal
Wrote config file fly.toml
```

GoToSocial is available on [Docker].
We create a new `Dockerfile`, use the upstream image, add our configuration file and launch it.


```Dockerfile
FROM superseriousbusiness/gotosocial:latest

WORKDIR /gotosocial/storage
WORKDIR /gotosocial
ADD config.yaml /gotosocial/

CMD ["--config-path", "/gotosocial/config.yaml"]
```

The GoToSocial Dockerfile already [specifies an entrypoint][entrypoint],
so it's enough to specify the additional arguments using `CMD`.


[docker]: https://hub.docker.com/r/superseriousbusiness/gotosocial
[entrypoint]: https://github.com/superseriousbusiness/gotosocial/blob/b153808472655cc73245ad60a2aa38bf04833367/Dockerfile#L47

Last thing missing is the configuration file.

We create a `config.yaml` based on the [example].
The full file [is in the repository][git-config.yaml].
The important bits are the host, database config and disabling signup.
Pretty much everything else is left to the defaults.

```toml
host: "young-darkness-8503.fly.dev"
db-type: "sqlite"
db-address: "/gotosocial/storage/sqlite.db"
accounts-registration-open: false
```

The host should be the random name `fly launch` chose earlier or your own domain when you add it to the app.

[example]: https://github.com/superseriousbusiness/gotosocial/blob/b153808472655cc73245ad60a2aa38bf04833367/example/config.yaml
[git-config.yaml]: https://github.com/badboy/gotosocial-fly/blob/main/config.yaml

Now we can deploy the app.

```
$ fly deploy
==> Verifying app config
--> Verified app config
==> Building image
(cut)
--> Pushing image done
image: registry.fly.io/young-darkness-8503:deployment-01GJE1E4HW25RAND71YG1637E5
image size: 65 MB
==> Creating release
--> release v1 created

--> You can detach the terminal anytime without stopping the deployment
==> Monitoring deployment

 1 desired, 1 placed, 1 healthy, 0 unhealthy [health checks: 1 total, 1 passing]
--> v1 deployed successfully
```

The app was successfully deployed and should be reachable at [young-darkness-8503.fly.dev][flydev],
where we'll see ... not much:

[flydev]: https://young-darkness-8503.fly.dev/

![GoToSocial deployed!](https://tmp.fnordig.de/blog/2022/gotosocial-deployed.png)

What's missing is a user.
We need to create one using the command line tooling.
First SSH into the machine:

```
$ fly ssh console
Connecting to fdaa:0:252b:a7b:67:4911:d8ec:2... complete
/ #
```

Then we create a new user, confirm it and finally give it admin rights.
You can find these steps [in the GoToSocial docs](https://docs.gotosocial.org/en/latest/installation_guide/binary/#5-create-and-confirm-your-user) as well.

```
/ # /gotosocial/gotosocial --config-path /gotosocial/config.yaml admin account create --username jer
--email jer@example.org --password 'securePassword1'
(cut)
/ # /gotosocial/gotosocial --config-path /gotosocial/config.yaml admin account confirm --username jer
(cut)
/ # /gotosocial/gotosocial --config-path /gotosocial/config.yaml admin account promote --username jer
(cut)
```

The profile is now visible at <https://young-darkness-8503.fly.dev/@jer>.
GoToSocial doesn't come with its own web client, but we can use [Pinafore],
a small and fast web client (it does have an [admin interface] though).
We use the same domain to login, then use the email address and password from the `account create` command above.

[pinafore]: https://pinafore.social/
[admin interface]: https://young-darkness-8503.fly.dev/admin

![First post from my own GoToSocial instance](https://tmp.fnordig.de/blog/2022/gotosocial-client.png)

That post is also visible on young-darkness-8503 directly:

[![First post visible on my own instance](https://tmp.fnordig.de/blog/2022/gotosocial-first-post.png)][first post]


[first post]: https://young-darkness-8503.fly.dev/@jer/statuses/01GJE2E4MDR2R0GEH1N9KPRKQH

## What's next?

This is a test deploy.
I'm not going to keep it up for forever.
At the very least I need a proper domain on it.
And then the storage should probably be on a [Fly volume][fly-volumes]
so it survives re-deploys.
GoToSocial is alpha software.
It sure is missing some features (though I really don't know what).
It might also have lots of bugs.
Decide for yourself if you want to run it!

[fly-volumes]: https://fly.io/docs/reference/volumes
