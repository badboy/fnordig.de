permalink: "/{{ year }}/{{ month }}/{{ day }}/run-server-side-git-hook-when-there-are-no-updates"
title: "Run server-side git hook when there are no updates"
published_date: "2013-11-02 10:14:00 +0100"
layout: post.liquid
data:
  route: blog
---
I make heavy use of of [hooks in git][git-hooks], especially post-receive, to
do different kind of things (deploying the blog, running some scripts, updating
some checked out repos).

From time to time when I create new hooks they fail due to some weird reasons.
It's hard to investigate because of the slightly different shell environment
the hooks use. But once pushed post-receive hooks won't run again, so just
changing the hook won't help.

There is an easy solution: pre-receive.
I came across this on [Stack Overflow][so] but I keep forgetting it, so here it is.

Add a `pre-receive` file in the hooks directory, make it executable and for
testing let it exit with a non-zero status:

    echo "exit 1" > repo.git/hooks/pre-receive
    chmod +x repo.git/hooks/pre-receive

Now to execute that hook:

    git push origin master HEAD:non-existing-branch

If the pre-receive hook exits with success (`exit 0`) the non-existing-branch
will be created, just keep that in mind.
Now you're free to throw whatever debug code you need into that `pre-receive`
file and see the output locally.

[git-hooks]: http://git-scm.com/book/en/Customizing-Git-Git-Hooks
[so]: http://stackoverflow.com/questions/13401244/git-run-server-side-hook-when-there-are-no-updates
