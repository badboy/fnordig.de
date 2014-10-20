---
layout: post
title: Redis Cluster with pre-existing data
date: 11.03.2014 17:05
---

With Beta 2 of Redis Cluster <del>arriving soon</del> [released just now][cluster-beta2], I finally found some time to play around with it.

A few days back in the `#redis` IRC channel someone asked how to migrate data from one existing normal Redis instance into a Cluster of several machines.
Back then I did not know how to do it, so today, after a [short conversation with antirez][twitter-conv] and a small bug fix, I got going. This is how it works.

------

**tl;dr**: Create cluster with empty nodes, reshard all (empty) slots to just one instance, restart that instance with the dump in place and reshard again.

------

*Short info upfront:* I'm using the latest git checkout as of right now, [cc11d103c09eb5a34f9097adf014b5193a8c9df3][redis-git-checkout]. I shortened the output of some of the commands, all necessary information is still present.

First you need a cluster. To start, create the config for 3 instances on port 7001-7003. This is even simpler than the [Cluster tutorial][].

~~~shell
mkdir cluster-test && cd cluster-test

for port in 7001 7002 7003; do
  mkdir ${port}
  cat > ${port}/redis.conf <<EOF
port $port
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
dir ./
save 900 1
save 300 10
save 60 10000
EOF
done
~~~

This creates the config for 3 instances. Now start them (use one terminal per server or add `daemonize yes` to the config):

~~~shell
cd 7001; redis-server ./redis.conf
~~~

Once done, let the nodes meet each other:

~~~shell
$ ./redis-trib.rb create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003
>>> Creating cluster
Connecting to node 127.0.0.1:7001: OK
Connecting to node 127.0.0.1:7002: OK
Connecting to node 127.0.0.1:7003: OK
...
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
~~~

At this point the instances should be empty and each one should have an ID and some assigned slots:

~~~shell
$ ./redis-trib.rb call 127.0.0.1:7001 info memory | grep 'used_memory_human:'  
used_memory_human:919.44K
used_memory_human:919.44K
used_memory_human:919.44K
$ ./redis-trib.rb check 127.0.0.1:7001
...
>>> Performing Cluster Check (using node 127.0.0.1:7001)
M: 6b916c5189438ee2a8b2248cdab264b16492abe9 127.0.0.1:7001
   slots:0-5460 (5461 slots) master
   0 additional replica(s)
...
~~~

Before we can re-use an existing dump, let's reshard all slots to one instance.
We specify the number of slots we move (all, so 16384), the id we move to (here Node 1 on port 7001) and where we take these slots from (all other nodes).

~~~shell
$ ./redis-trib.rb reshard 127.0.0.1:7001
Connecting to node 127.0.0.1:7001: OK
Connecting to node 127.0.0.1:7002: OK
Connecting to node 127.0.0.1:7003: OK
>>> Performing Cluster Check (using node 127.0.0.1:7001)
M: 635607ddd921c61e2b6afa425a60b2ad206d1645 127.0.0.1:7001
   slots:0-5460 (5461 slots) master
   0 additional replica(s)
M: e3a0fde219b53dafa0e7904b47251b38e3c35513 127.0.0.1:7002
   slots:5461-10921 (5461 slots) master
   0 additional replica(s)
M: 7bd6d759fb11983e63925055ad27eaab45ee0b24 127.0.0.1:7003
   slots:10922-16383 (5462 slots) master
   0 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 16384
What is the receiving node ID? 635607ddd921c61e2b6afa425a60b2ad206d1645
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: all
...
Do you want to proceed with the proposed reshard plan (yes/no)? yes
...
~~~

A quick check should show that everything is fine:

~~~shell
$ ./redis-trib.rb check 127.0.0.1:7001
...
M: 635607ddd921c61e2b6afa425a60b2ad206d1645 127.0.0.1:7001
   slots:0-16383 (16384 slots) master
   0 additional replica(s)
...
[OK] All 16384 slots covered.
~~~

We now have a Cluster consisting of 3 master nodes, with all 16384 slots only assigned to the first instance. Setting a key on this instance works fine. Every other node will report a `MOVED` error:

~~~shell
$ redis-cli -p 7001 set foo bar
OK
$ redis-cli -p 7002 set foo bar
(error) MOVED 12182 127.0.0.1:7001
~~~

Next step: Importing our existing data. Grab the `dump.rdb` from your existing instance (make sure you've got a recent version, by either sending `SAVE` or `BGSAVE` on that instance first), put it into the right directory and restart the node:

~~~shell
$ cp /tmp/dump.rdb 7001/
$ du -h 7001/dump.rdb
22M	7001/dump.rdb
$ redis-cli -p 7001 shutdown nosave
$ redis-server ./redis.conf
...
[23191] 11 Mar 16:11:58.978 * DB loaded from disk: 3.253 seconds
[23191] 11 Mar 16:11:59.035 * The server is now ready to accept connections on port 7001
~~~

The Cluster instance saved information about nodes it was connected to in the `nodes.conf` file, so on restart it can join the cluster again.
Let's see if the data is really there and our Cluster is in a stable state:

~~~shell
$ ./redis-trib.rb check 127.0.0.1:7001
...
[OK] All 16384 slots covered.
$ ./redis-trib.rb call 127.0.0.1:7001 info memory | grep 'used_memory_human:'
used_memory_human:212.29M
used_memory_human:918.44K
used_memory_human:918.44K
~~~

Yes, looks like it is. Now onto resharding to make use of all instances. We want to distribute it evenly across all 3 nodes, so about 5461 slots per instance.
The reshard command will again list the existing nodes, their IDs and the assigned slots.

~~~shell
$ ./redis-trib.rb reshard 127.0.0.1:7001
...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 5461
What is the receiving node ID? e3a0fde219b53dafa0e7904b47251b38e3c35513
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1:635607ddd921c61e2b6afa425a60b2ad206d1645
Source node #2:done
...
Do you want to proceed with the proposed reshard plan (yes/no)? yes
...
~~~

When it finished some data should be moved to the second instance:

~~~shell
$ ./redis-trib.rb call 127.0.0.1:7001 info memory | grep 'used_memory_human:'
used_memory_human:144.49M
used_memory_human:72.70M
used_memory_human:918.44K
~~~

Now repeat the reshard step to migrate another 5461 slots to the third instance.
Final check after the second reshard:

~~~shell
$ ./redis-trib.rb call 127.0.0.1:7001 info memory | grep 'used_memory_human:'
used_memory_human:76.71M
used_memory_human:72.70M
used_memory_human:72.70M
$ ./redis-trib.rb check 127.0.0.1:7001                                  
...
[OK] All 16384 slots covered.
~~~

That looks good. We have all our data distributed onto 3 nodes, just as we wanted. The whole process might seem a bit complicated right now, but maybe with more time we can improve it and write a few simple scripts to do this instead of manually resharding.

Oh, and putting new data into Redis works as well:

~~~shell
$ redis-cli -p 7001 set foo bar    
OK
$ redis-cli -p 7001 set baz bar
(error) MOVED 4813 127.0.0.1:7002
$ redis-cli -p 7002 set baz bar
OK
~~~

If you have a smart client already, it can automatically follow the redirection.

It was my first time playing with Redis Cluster and there is a lot more to it.
If you're interested, see the [Cluster tutorial], the [Cluster specification] or read the [source code][cluster source].
If you had the time to play with Redis Cluster, are already using it or planning to use it, I'm interested to here about your use case. Just drop me a message via [Twitter][], mail (janerik at fnordig dot de) or directly to the [Redis mailing list][redis-ml].

[redis-git-checkout]: https://github.com/antirez/redis/commit/cc11d103c09eb5a34f9097adf014b5193a8c9df3
[twitter-conv]: https://twitter.com/badboy_/status/443376731932864512
[Cluster tutorial]: http://redis.io/topics/cluster-tutorial
[Cluster specification]: http://redis.io/topics/cluster-spec
[cluster source]: https://github.com/antirez/redis/blob/unstable/src/cluster.c
[redis-ml]: https://groups.google.com/forum/#!forum/redis-db
[twitter]: http://twitter.com/badboy_
[cluster-beta2]: https://groups.google.com/forum/#!msg/redis-db/qaVm3WNYCpw/TaTVorkmlM8J
