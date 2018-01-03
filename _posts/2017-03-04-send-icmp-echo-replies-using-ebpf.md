extends: post.liquid
title: "Send ICMP Echo Replies using eBPF"
date: 04 Mar 2017 17:25:00 +0100
path: /:year/:month/:day/send-icmp-echo-replies-using-ebpf
route: blog
---

For my master thesis I am working with eBPF, the [Extended Berkeley Packet Filter](https://www.kernel.org/doc/Documentation/networking/filter.txt).
By now it is used by several subsystems in the Linux kernel,
ranging from tracing and seccomp rules to network filtering.

As I am using it for network filtering I wanted a small useful and working example on how to parse
and resend packets with it.
Luckily, the hard part of attaching it early in the packet processing pipeline is already handled by `tc`,
Linux' traffic control utility from the iproute2 project.

However, it took me a while to get a reliably working ICMP ping-pong example to work.
Now that I have I published it to save others the trouble.  
The result is online in the [ebpf-icmp-ping][git] repository.
The rest of the blog post will explain some of the steps in [`bpf.c`](https://github.com/badboy/ebpf-icmp-ping/blob/cf2c1ff5bc16049e64bf8424984d226ecaa468ea/bpf.c) and how it is used.

A subset of C can be compiled to the eBPF bytecode
and luckily the Clang compiler has a eBPF backend to make it all work.

The usable subset is a lot more restricted than plain C and requires a bit more boilerplate
to assist the compiler (and Kernel verifier) to produce safe programs.
All memory access needs to be checked up front.
Assigning from one part in the passed buffer to another might fail
(I'm not 100% sure yet whether that's due to restrictions of eBPF or the code generation).
And you can't have loops, but luckily Clang/LLVM is quite good at unrolling loops with a fixed iteration count.

Let's dive in.

First we define our function and put it in a specific section of the generated ELF file.
`tc` will know how to pull it out.
Our function gets a single pointer to a kernel-allocated buffer of the network packet.

~~~c
SEC("action")
int pingpong(struct __sk_buff *skb)
~~~

Accessing data in this buffer can be done using different methods.
Either read out bytes at specified offsets or rely on the struct definitions of the Kernel.
We do the latter, but first we need to check that there is enough data.
If not, we don't do anything.

~~~c
void *data = (void *)(long)skb->data;
void *data_end = (void *)(long)skb->data_end;

if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct icmphdr) > data_end)
    return TC_ACT_UNSPEC;
~~~

Once that is done, the verifier let's us use pointers to the right parts of the buffer

~~~c
struct ethhdr  *eth  = data;
struct iphdr   *ip   = (data + sizeof(struct ethhdr));
struct icmphdr *icmp = (data + sizeof(struct ethhdr) + sizeof(struct iphdr));
~~~

We do some checks to ensure we have a packet we can handle and then parse out the addresses.
MAC addresses are 48 bits, so the best is to copy them out.

~~~c
__u8 src_mac[ETH_ALEN];
__u8 dst_mac[ETH_ALEN];
bpf_memcpy(src_mac, eth->h_source, ETH_ALEN);
bpf_memcpy(dst_mac, eth->h_dest, ETH_ALEN);
~~~

The IP addresses can be accessed more directly.

~~~c
__u32 src_ip = ip->saddr;
__u32 dst_ip = ip->daddr;
~~~

We can then swap the MAC addresses by storing the other address at the right place.

~~~c
bpf_skb_store_bytes(skb, offsetof(struct ethhdr, h_source), dst_mac, ETH_ALEN, 0);
bpf_skb_store_bytes(skb, offsetof(struct ethhdr, h_dest), src_mac, ETH_ALEN, 0);
~~~

Same goes for the IPs:

~~~c
bpf_skb_store_bytes(skb, IP_SRC_OFF, &dst_ip, sizeof(dst_ip), 0);
bpf_skb_store_bytes(skb, IP_DST_OFF, &src_ip, sizeof(src_ip), 0);
~~~

The IP header is checksummed, but simply swapping a few bytes does not affect the checksum,
so no need to recalculate it.
We can then modify the ICMP type, but here we need to calculate the new checksum.
The Linux kernel provides helper methods for eBPF to do this.

First recalculate the checksum:

~~~c
__u8 new_type = 0;
bpf_l4_csum_replace(skb, ICMP_CSUM_OFF, ICMP_PING, new_type, ICMP_CSUM_SIZE);
~~~

Then insert the actual data (the order is not relevant here).

~~~c
bpf_skb_store_bytes(skb, ICMP_TYPE_OFF, &new_type, sizeof(new_type), 0);
~~~

Last but not least we need to redirect the packet back out the same network interface it came in.
This is done using another helper function:

~~~c
bpf_clone_redirect(skb, skb->ifindex, 0);
~~~

The last argument specifies the direction, where `0` is `tx`, and thus outgoing and `1` is `rx`, thus incoming.
Finally we set a return code to inform the kernel that the packet should not be processed any further.

The full code is in [`bpf.c`](https://github.com/badboy/ebpf-icmp-ping/blob/cf2c1ff5bc16049e64bf8424984d226ecaa468ea/bpf.c).

To use this code we first need a `qdisc` to attach this program to as an action.

~~~bash
tc qdisc add dev eth0 ingress handle ffff:
~~~

Then we can attach the classifier (which does nothing) and our action (the ICMP pong) to the create ingress queue:

~~~bash
tc filter add dev eth0 parent ffff: bpf obj bpf.o sec classifier flowid ffff:1 \
  action bpf obj bpf.o sec action ok
~~~

If all worked correctly, `tc` can show some info:

~~~bash
$ tc filter show dev eth0 ingress
filter parent ffff: protocol all pref 49152 bpf
filter parent ffff: protocol all pref 49152 bpf handle 0x1 flowid ffff:1 bpf.o:[classifier]
        action order 1: bpf bpf.o:[action] default-action pass
        index 30 ref 1 bind 1
~~~

If you enabled the debug print, the output can be viewed as well:

~~~bash
$ tc exec bpf dbg
Running! Hang up with ^C!

  <idle>-0  [000] ..s. 81710.218035: : [action] IP Packet, proto= 1, src= 20490432, dst= 1714989248
~~~

And that's it.
`ICMP Echo Requests` are now handled inside the kernel using eBPF and never travel through the rest of the network stack.

[git]: https://github.com/badboy/ebpf-icmp-ping
