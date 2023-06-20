---
permalink: "/{{ year }}/{{ month }}/{{ day }}/ssh-keyscan-fdlim-get-bad-value"
title: "ssh-keyscan: fdlim_get: bad value"
published_date: "2023-06-20 15:00:00 +0200"
layout: post.liquid
data:
  route: blog
excerpt: |
    `ssh-keyscan: fdlim_get: bad value` - That's the error message I got the other day when I was trying out some project.
    The web was incredibly useless in telling me what the hell was going wrong here.
    So I set out to find why this was happening, how to fix it and hopefully make this error message findable on the web.
    And this is the story how I found a type confusion bug in some 20-year old OpenSSH code.
---

```
ssh-keyscan: fdlim_get: bad value
```

That's the error message I got the other day when I was trying out some project.
The web was incredibly useless in telling me what the hell was going wrong here.
So I set out to find why this was happening, how to fix it and hopefully make this error message findable on the web.
And this is the story how I found a type confusion bug in some 20-year old OpenSSH code.

## What is `ssh-keyscan`?

`ssh-keyscan` is a small utility to "gather SSH public keys from servers" and part of the OpenSSH package (see [the man page][manpage]).
The one that (most likely) provides you the SSH client and server.

You run it like this:

```text
$ ssh-keyscan github.com
# github.com:22 SSH-2.0-babeld-dca4d356
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
<snip>
```

and get all public keys from that host.
Or if you only need a specific type you pass that:

```text
$ ssh-keyscan -t ed25519 github.com
# github.com:22 SSH-2.0-babeld-dca4d356
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
```

[manpage]: https://manpages.debian.org/bookworm/openssh-client/ssh-keyscan.1.en.html

## What went wrong?

Running it on my freshly booted M1 MacBook errors out:

```
$ ssh-keyscan github.com
ssh-keyscan: fdlim_get: bad value
$ echo $?
255
```

Yeah, not particularly helpful.
What's `fdlim_get`? What bad value did it encounter?
Is this a Mac problem? Or a problem in ssh-keyscan?

So I tried from two of my Linux machines. No issues.

## What's the code?

`fdlim_get` is a function in the `ssh-keyscan` code base in OpenSSH.
You can find it [in `ssh-keyscan.c` on GitHub](https://github.com/openssh/openssh-portable/blob/b4ac435b4e67f8eb5932d8f59eb5b3cf7dc38df0/ssh-keyscan.c#L129-L144).
It's supposed to get the maximum and current limit for file descriptors the program can use.
The error we're seeing is [from a `fdlim_get(1)` call further down in that file][fdlim_get_call].

[fdlim_get_call]: https://github.com/openssh/openssh-portable/blob/b4ac435b4e67f8eb5932d8f59eb5b3cf7dc38df0/ssh-keyscan.c#L830-L832

```c
maxfd = fdlim_get(1);
if (maxfd < 0)
	fatal("%s: fdlim_get: bad value", __progname);
```

Time to compile my own `ssh-keyscan`, so I can modify and debug it:

```
git clone https://github.com/openssh/openssh-portable
cd openssh-portable
autoreconf
./configure --with-ssl-dir=/opt/homebrew/Cellar/openssl@1.1/1.1.1u
make ssh-keyscan
```

And now I can run it locally:

```
$ ./ssh-keyscan
usage: ssh-keyscan [-46cDHv] [-f file] [-O option] [-p port] [-T timeout]
                   [-t type] [host | addrlist namelist]
```

That was surprisingly easy.
Let's dive into the code and try to understand it:

```c
static int
fdlim_get(int hard)
{
#if defined(HAVE_GETRLIMIT) && defined(RLIMIT_NOFILE)
	struct rlimit rlfd;

	if (getrlimit(RLIMIT_NOFILE, &rlfd) == -1)
		return (-1);
	if ((hard ? rlfd.rlim_max : rlfd.rlim_cur) == RLIM_INFINITY)
		return SSH_SYSFDMAX;
	else
		return hard ? rlfd.rlim_max : rlfd.rlim_cur;
#else
	return SSH_SYSFDMAX;
#endif
}
```

Using some printf-debugging is a quick way to see some of those values.
Adding the following lines right after the `getrlimit` call should tell me more:

```c
printf("int size=%lu\n", sizeof(int));
printf("type size=%lu\n", sizeof(typeof(rlfd.rlim_max)));
printf("rlfd.rlim_max=%llu\n", rlfd.rlim_max);
printf("rlfd.rlim_cur=%llu\n", rlfd.rlim_cur);
printf("RLIM_INFINITY=%llu\n", RLIM_INFINITY);
printf("SSH_SYSFDMAX=%ld\n", SSH_SYSFDMAX);
```

After a `make ssh-keyscan` and `./ssh-keyscan github.com` cycle I get:

```
$ ssh-keyscan github.com
int size=4
type size=8
rlfd.rlim_max=9223372036854775807
rlfd.rlim_cur=9223372036854775807
RLIM_INFINITY=9223372036854775807
SSH_SYSFDMAX=9223372036854775807
ssh-keyscan: fdlim_get: bad value
```

Remember the `fdlim_get(1)` call and check [later][fdlim_get_call] looked like this:

```c
maxfd = fdlim_get(1);
if (maxfd < 0)
	fatal("%s: fdlim_get: bad value", __progname);
```

And `fdlim_get` is defined to return an `int`, which is only 4 byte wide (that's 32 bit).

What's the biggest number one can fit into an int?

```c
printf("INT_MAX=%d\n", INT_MAX);
```

```
INT_MAX=2147483647
```

That's smaller than `9223372036854775807`.
What's `9223372036854775807` as a 32-bit integer?

```c
printf("int(SSH_SYSFDMAX)=%d\n", (int)SSH_SYSFDMAX);
```

```
int(SSH_SYSFDMAX)=-1
```

So from `getrlimit` I get pretty large values, but because `ssh-keyscan` stuffs them into a smaller type, it wraps around and returns `-1`.
And that's smaller than `0` and thus a `bad value`.

## What now?

Why am I getting such large values to begin with?

```
$ ulimit -n
unlimited
```

_(`ulimit -n` shows the file descriptor limit for the current shell)_

That's probably a large value.
How does one change that in macOS?
Multiple ways!
First let's ask the OS what is configured:

```
$ launchctl limit maxfiles
	maxfiles    256            unlimited
```

The first number, `256`, is a soft limit and the other, `unlimited`, the hard limit per process.
Soft limit? Hard limit?
The soft limit is configurable by the user up to the hard limit, which can only be changed by `root`.
But there's also a kernel configuration for it:

```
$ sysctl -a | grep maxfiles
kern.maxfiles: 122880
kern.maxfilesperproc: 61440
```

That's the hard limit for a single process (`maxfilesperproc=61440`) and for all processes (`maxfiles=122880`).
This doesn't even match the `launchctl` output.

Let's change this using `launchctl`[^1]:

```
$ sudo launchctl limit maxfiles 245760 491520
$ launchctl limit maxfiles
	maxfiles    245760         491520
$ sysctl -a | grep maxfiles
kern.maxfiles: 491520
kern.maxfilesperproc: 245760
```

Now both outputs match.

Did that help with our `ssh-keyscan` problem?

```
$ ulimit -n
unlimited
```

Still unlimited, I don't have high hopes now.

```
$ ./ssh-keyscan github.com
int size=4
type size=8
rlfd.rlim_max=9223372036854775807
rlfd.rlim_cur=9223372036854775807
RLIM_INFINITY=9223372036854775807
SSH_SYSFDMAX=9223372036854775807
ssh-keyscan: fdlim_get: bad value
```

And indeed it still fails and I get large values.
What if I change the limit just for this shell session?

```
$ ulimit -n 245760
$ ulimit -n
245760
$ ./ssh-keyscan github.com
int size=4
type size=8
rlfd.rlim_max=9223372036854775807
rlfd.rlim_cur=245760
RLIM_INFINITY=9223372036854775807
SSH_SYSFDMAX=245760
int size=4
type size=8
rlfd.rlim_max=9223372036854775807
rlfd.rlim_cur=245760
RLIM_INFINITY=9223372036854775807
SSH_SYSFDMAX=245760
# github.com:22 SSH-2.0-babeld-dca4d356
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
<snip>
```

It works!
_(We get the whole debug output twice, because `fdlim_get` is called twice)_

Wait, why did `SSH_SYSFDMAX` change? Isn't that a constant?
Yes and no:

```
$ grep -R "define SSH_SYSFDMAX" .
./defines.h:# define SSH_SYSFDMAX sysconf(_SC_OPEN_MAX)
./defines.h:# define SSH_SYSFDMAX 10000
```

In [`defines.h`](https://github.com/openssh/openssh-portable/blob/b4ac435b4e67f8eb5932d8f59eb5b3cf7dc38df0/defines.h#L728-L733):

```c
/* Maximum number of file descriptors available */
#ifdef HAVE_SYSCONF
# define SSH_SYSFDMAX sysconf(_SC_OPEN_MAX)
#else
# define SSH_SYSFDMAX 10000
#endif
```

It's `sysconf(_SC_OPEN_MAX)`, a function call!
And `_SC_OPEN_MAX` is [defined as](https://manpages.debian.org/bullseye/manpages-dev/sysconf.3.en.html#OPEN_MAX):

> The maximum number of files that a process can have open at any time. Must not be less than `_POSIX_OPEN_MAX (20)`.

So it's the limit I configured using `ulimit -n 245760` above.

I am still confused why `launchctl limit maxfiles` and `sysctl -a` are different on a freshly booted machine,
but configuring values with `launchctl` then touches those `sysctl` values too.

According to ~~some people~~ everyone I asked `ulimit -n` gives them `256`, a small but much more sensible value.
I still have no clue why it's `unlimited` on my machine.

Turns out I ran into that problem 2 years ago in another project (and got it fixed):
[entr: Segmentation fault on MacBook M1 due to unlimited file descriptors](https://github.com/eradman/entr/issues/63).

This MacBook is cursed.
At least now there will be search results for `fdlim_get: bad value` on the internet.

---

_Footnotes:_

[^1]: I cannot recommend to run `sudo launchctl limit maxfiles 1024 1024`. You won't be able to shut down your system anymore.
