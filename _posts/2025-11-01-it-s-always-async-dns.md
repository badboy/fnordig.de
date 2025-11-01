---
permalink: "/{{ year }}/{{ month }}/{{ day }}/it-s-always-async-dns"
title: "It's <del>always</del> async DNS"
published_date: "2025-11-01 23:00:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
  On \*nix systems the default way to resolve a hostname into an IP address is `getaddrinfo`.
  However that function blocks until all the DNS queries return.
  macOS has a "hidden" async DNS API: `getaddrinfo_async_start`.
  It's undocumented and near impossible to find how to use it.
  So I did find out how to use it and show that.
---

On \*nix systems the default way to resolve a hostname into an IP address is [`getaddrinfo`].
However that function blocks until all the DNS queries return.
When the code is supposed to do more work asynchronous a different solution is required.
Some try to work around that with threads, but then you also need to deal with cancellation [and that's flawed too][pthread_cancel].
Others switch to [`getaddrinfo_a`], but that's glibc-only.
And then you need to [use all the different ways for different operating systems anyway][zig-async-dns-resolution].

So then [I read that on macOS `getaddrinfo_async_start`][ziggit] exists.
It's hidden.
It's severely underdocumented. Not at all you could say.
Apple probably doesn't want you to use it.

[bun], a JavaScript runtime, uses it.
There's an issue filed for [libuv][libuv-issue] (2019!) as well as an [accompanying  PR][libuv-pr] (2022!).
But that's about it what you can find on the internet.
Except maybe it's function definitions.

I had time today, so I figured out the minimal amount of code that you need to use it from C.
Without further ado:

```c
#include <arpa/inet.h>
#include <mach/mach.h>
#include <netdb.h>
#include <stdio.h>

typedef void (*getaddrinfo_async_callback)(int32_t status, struct addrinfo* res,
                                           void* context);
int32_t getaddrinfo_async_start(mach_port_t* p, const char* nodename,
                                const char* servname,
                                const struct addrinfo* hints,
                                getaddrinfo_async_callback callback,
                                void* context);
int32_t getaddrinfo_async_handle_reply(void* msg);

void done_cb(int32_t status, struct addrinfo* res, void* context) {
  if (status != 0) {
    printf("status=%s(%d)\n", gai_strerror(status), status);
    return;
  }

  char ipstr[INET6_ADDRSTRLEN];
  for (struct addrinfo* p = res; p != NULL; p = p->ai_next) {
    void* addr;
    const char* ipversion;

    if (p->ai_family == AF_INET) {
      struct sockaddr_in* ipv4 = (struct sockaddr_in*)p->ai_addr;
      addr = &(ipv4->sin_addr);
      ipversion = "A";
    } else {
      struct sockaddr_in6* ipv6 = (struct sockaddr_in6*)p->ai_addr;
      addr = &(ipv6->sin6_addr);
      ipversion = "AAAA";
    }

    inet_ntop(p->ai_family, addr, ipstr, sizeof(ipstr));
    printf("%s: %s\n", ipversion, ipstr);
  }
}

int main(int argc, char** argv) {
  struct addrinfo hints;
  mach_port_t port;
  int res;

  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  res = getaddrinfo_async_start(&port, argv[1], NULL, &hints, &done_cb, NULL);
  if (res != 0) {
    perror("getaddrinfo_async_start");
    return 1;
  }

  mach_msg_empty_rcv_t msg;
  mach_msg_return_t status;
  status = mach_msg(&msg.header, MACH_RCV_MSG, 0, sizeof(msg), port,
                    MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
  if (status != KERN_SUCCESS) {
    perror("KERN_SUCCESS");
    return 1;
  }
  getaddrinfo_async_handle_reply(&msg);

  return 0;
}
```

Put it into `async-dns.c`.
Build it with[^1]:

```
cc -o async-dns async-dns.c
```

Then run it:

```shell
; ./async-dns fnordig.de
AAAA: 2a01:4f8:221:2114::7
A: 46.4.212.174
```

Of course my code isn't really asynchronous.
It just blocks while waiting for the message.
However you can plug that into your favorite event loop, provided it supports mach ports,
and thus have it do other work while the DNS requests are in flight.

---

_Footnotes_:

[^1]: Or just `make async-dns`. Yes, that works.

[pthread_cancel]: https://eissing.org/icing/posts/rip_pthread_cancel/
[`getaddrinfo`]: https://www.man7.org/linux/man-pages/man3/getaddrinfo.3.html
[`getaddrinfo_a`]: https://man7.org/linux/man-pages/man3/getaddrinfo_a.3.html
[bun]: https://github.com/oven-sh/bun/blob/5aeef404798f9b1628e98f576f21c6a278c4cf6f/src/bun.js/api/bun/dns.zig#L88-L95
[libuv-issue]: https://github.com/libuv/libuv/issues/2349
[libuv-pr]: https://github.com/libuv/libuv/pull/3509
[zig-async-dns-resolution]: https://ziglang.org/devlog/2025/#2025-10-15
[ziggit]: https://ziggit.dev/t/zio-async-i-o-framework-based-on-libxev/12213/37
