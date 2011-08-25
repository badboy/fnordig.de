---
layout: post
title: static blog system improved
---

My static blog system script now launches a small web server and auto-updates on a file change. This way you've got a live preview directly in your browser.

As the inital script was written in Javascript, I wrote the rest in Javascript, too.

The whole runs on [node.js](https://github.com/ry/node) and uses some fancy modules:

* [paperboy](https://github.com/felixge/node-paperboy) for static file delivery (the css file)
* [socket.io-node](https://github.com/LearnBoost/Socket.IO-node) as the websocket server
* [socket.io](https://github.com/LearnBoost/Socket.IO) injected into the html, so the website auto-reloads when informed through the server

The whole combination is amazingly fast, the updated text nearly appears in realtime.

You can find the script here: [watch.js](http://tmp.fnordig.de/watch.js). It's more like a quick hack and not fully tested. It may crash whenever it will, but for now it works for me :)

The small app.js is just this:

<pre><code>socket = new io.Socket('localhost');
socket.connect();
socket.on('message', function(data){
  data = JSON.parse(data);
  if(data.reload)
    window.location.reload();
});</code></pre>

So next thing: individual pages for posts, maybe templates.
