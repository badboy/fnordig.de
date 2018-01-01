permalink: "/{{ year }}/{{ month }}/{{ day }}/extending-redis-with-lua-packages"
title: Extending Redis with Lua packages
published_date: "2014-07-27 13:57:00 +0200"
layout: post.liquid
data:
  route: blog
---
**Warning**: If you patch your Redis as stated below, you won't get much support from the Community.  
**Do not run this in production!** You have been warned.

------

Redis comes with in-built support for Lua scripts. Using [eval][] (or [evalsha][]) it is possible to execute scripts right in the context of the Redis server.
Redis provides some guarantees for these Lua scripts: Lua scripts are atomic and do not interfere with other scripts or normal commands.
Redis tries its best to provide a sandbox you're scripts are evaluated in, but it won't stop you from doing stupid things.

This sandboxed mechanism also means that access to any external resources is not allowed. No IO, no external libraries (except thus already provided) and especially no compiled modules.

But what if you want to use a library anyway? Well, it's actually not that hard.
Three days ago a user came to the IRC channel (`#redis` on freenode) to ask how to use [LGMP][], an adapter to the GNU multiple precision arithmetic library, in Redis.

After some fiddling around I provided a solution:

First patch your local Redis checkout with the following patch:

~~~diff
diff --git i/deps/Makefile w/deps/Makefile
index 5a95545..9ec62be 100644
--- i/deps/Makefile
+++ w/deps/Makefile
@@ -58,8 +58,8 @@ ifeq ($(uname_S),SunOS)
  LUA_CFLAGS= -D__C99FEATURES__=1
 endif
 
-LUA_CFLAGS+= -O2 -Wall -DLUA_ANSI $(CFLAGS)
-LUA_LDFLAGS+= $(LDFLAGS)
+LUA_CFLAGS+= -O2 -Wall -DLUA_ANSI -DLUA_USE_DLOPEN $(CFLAGS)
+LUA_LDFLAGS+= -ldl $(LDFLAGS)
 
 lua: .make-prerequisites
  @printf '%b %b\n' $(MAKECOLOR)MAKE$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR)
diff --git i/src/scripting.c w/src/scripting.c
index ef00eed..c7f3735 100644
--- i/src/scripting.c
+++ w/src/scripting.c
@@ -549,10 +549,8 @@ void luaLoadLibraries(lua_State *lua) {
     luaLoadLib(lua, "struct", luaopen_struct);
     luaLoadLib(lua, "cmsgpack", luaopen_cmsgpack);
 
-#if 0 /* Stuff that we don't load currently, for sandboxing concerns. */
     luaLoadLib(lua, LUA_LOADLIBNAME, luaopen_package);
     luaLoadLib(lua, LUA_OSLIBNAME, luaopen_os);
-#endif
 
}
 
 /* Remove a functions that we don't want to expose to the Redis scripting
~~~

This makes sure the provided Lua is compiled with support to load modules and it actually enables the `package` module in the embedded Lua interpreter (it also enables the [OS module][os]). The `package` module will then provide the `require` method used to load external modules.

Next compile your Redis as usual:

~~~shell
make distclean # Just in case it was compiled before
make
~~~

Next, grab a copy of the LGMP files from [Wim Couwenberg](http://members.chello.nl/~w.couwenberg/) ([Direct link, .tar.bz2](http://members.chello.nl/~w.couwenberg/lgmp.tar.bz2), make sure to grab the Lua 5.1 sources).
Unpack it to a location, e.g. `~/code/lgmp` and compile it:

~~~shell
gcc -O2 -Wall -lgmp -o c-gmp.so lgmp.c -shared -fPIC -L ~/code/redis/deps/lua/src/ -I ~/code/redis/deps/lua/src
~~~

Adjust the paths for `-L` and `-I` to point to the Lua bundled with Redis.

Once this is done, just start the Redis server (but make sure you do it from the directory with the `gmp.lua` and `c-gmp.so`):

~~~shell
~/code/redis/src/redis-server &
~~~

Alternatively copy `gmp.lua` and `c-gmp.so` to the libraries the following command gives you:

~~~shell
$ ~/code/redis/src/redis-cli eval "return {package.cpath, package.path}" 0
1) "./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so"
2) "./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua"
~~~

As the last step, use the library:

~~~shell
$ ~/code/redis/src/redis-cli
127.0.0.1:6379> eval "local gmp=require'gmp'; return gmp.version" 0
"6.0.0"
127.0.0.1:6379> eval "local gmp=require'gmp'; local x = gmp.z(123); local y = gmp.z(456); return x:add(y):__tostring()"  0
"579"
~~~

And that's it. That's how you can load external modules into the embedded Lua interpreter.
Again: **Do not run this in production!** It may break at any time, it may erase your hard drive or kill kittens.

(These instructions are also available in [a short Gist](https://gist.github.com/badboy/7032fe739742caf22eaf).)

[eval]: http://redis.io/commands/eval
[evalsha]: http://redis.io/commands/evalsha
[lgmp]: http://members.chello.nl/~w.couwenberg/lgmp.htm
[os]: http://lua-users.org/wiki/OsLibraryTutorial
