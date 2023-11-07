---
permalink: "/{{ year }}/{{ month }}/{{ day }}/git-opinions"
title: "git opinions"
published_date: "2023-11-07 22:22:00 +0100"
layout: post.liquid
data:
  route: blog
excerpt: |
    There's been a lot of chatter about git on the internet lately.
    So shortly after this morning's breakfast coffee I had opinions on the internet.
    Let's look into those.
---

_This blog post is in more raw form than previous blog posts.
I wrote very few posts this year so far and I wanted to get it out before I lose steam._

There's been a lot of chatter about git on the internet lately.
Starting with Julia Evans' excellent articles:
* [Some miscellaneous git facts][jvns-misc-facts]
* [Confusing git terminology][jvns-git-term]
* [git rebase: what can go wrong?][jvns-rebasing]

Then Mozilla's announcement that next year Firefox development will move from Mercurial to Git exclusively came out:
[Firefox Development Is Moving From Mercurial To Git][firefox-announcement].

So shortly after this morning's breakfast coffee I had [opinions on the internet][toot1]:

> Lots of talk about git (and mercurial) on my timeline.
>
> So some opinions:
>
> * git rebase is ok
> * git push --force on a PR is acceptable
> * github pull requests make reviews harder than necessary
> * using git-absorb and git-revise makes my life easier
> * git-cinnabar is an excellent hack

Let's look into those.

## git rebase is ok

I regularly have multiple branches on a single repository for different work items.
Some are separate but dependent work streams and might require to land in order,
some are touching different parts of the code base and can land independently.
Sometimes someone else lands patches that I will need to make my code work.

In all those cases a `git checkout main && git pull --rebase && git checkout - && git rebase -i main`
gets me those changes, rebases my work and gets me a clean history with it.
What I see locally is what I will end up pushing and what will end up in a pull request on GitHub.

This works surprisingly often without issues.
There are edge cases and sometimes merge/rebase conflicts, but that will happen on a merge too.

## git push --force on a PR is acceptable

_(This is in the context of GitHub's Pull Request model)_

Yes, force-pushing on a PR is ok.
GitHub shows that something was force-pushed and shows you both the old and new commit,
thus allowing you to locally diff those for what actually changed (but see below).

Though maybe don't force-push while a review is still being done and you're addressing review comments one-by-one.
Add those as new commits and wait until the end of review to review your commits.

Often enough I structure my changes into several commits,
each of which addresses a certain subset of the full changes with important notes in the commit message.
Those should be preserved in what finally lands.
Fixup commits and a force-push before merge gets me that.

## github pull requests make reviews harder than necessary

GitHub pull requests force a very particular model on code review:
It's single-threaded, it de-emphasizes individual commits and it refuses to show larger diffs by default.
I see that as a huge downside for larger projects with potentially bigger and frequent changes.

It also gets some things right:

* Single- and multi-line comments on changes
* Automatic change suggestions that can be applied with a single click
  * and suggestions are just a code block in the comment.
* It's possible to link to individual lines in the change
* Review comments can be queued up until the review is submitted
* Review comments can be marked as resolved
* It shows when a review comment doesn't apply anymore because the code was already changed in a later commit
* It inlines information about new commits, (force-)pushes and review status in the comment stream
* You can mark files as reviewed
  * If they are changed in a later commit the UI will tell you
* Small contributions (docs, typo fixes, change of a dependency version) can be done all through the web UI

But other things I don't like:

* By default you won't see the commit message anywhere
  * The "Commits" tab has them, but that's another click away
* By default you get the diff of the full pull request, getting to individual commits is hidden in a drop-down menu or in another tab
* You cannot comment on the commit message
  * Commit messages should carry information. That should get review too!
* Addressing review comments means new commits, or rebasing and force-pushes
  * the former then requires a rebase/squash before merging
  * the latter makes it hard to see only the little change addressing a comment
* No good history
  * You can sort of reassemble a history on your own using the inline comments, but there's not much in the UI to help you do that
* Merging has 3 options: Merge commit, rebasing and squash
  * Squash isn't it for me, see above about multiple commits in a single pull request
* The infamous "diff not shown for big files"
* The infamous "3 comments where hidden" on longer discussions

At Mozilla we use Phabricator ([Phorge] is the active community fork) and while it's far from perfect it gets a couple of things right in my opinion:

* A review is on a revision
* Multiple revisions can be linked into a stack
* A revision has a history
  * A change to that revision can be viewed across the history of that revision
* You get to review a revision one by one, you then land the whole stack once all revisions are reviewed
* You can abandon revisions and attach new ones to a stack
  * You still get the history and branching in that whole stack

1 revision = 1 commit (technically it could be multiple commits I think),
but locally you can add additional commits, reorder them, rebase them, squash them, then push them up for further review.
This fits my workflow much better.

It also falls flat on other things:

* Still no direct commenting on the commit message/description
  * but it's front and center and visible on top, so one can always call it out in the review comment
* You can't link to a changed line
* The commenting UI is not as nice to use
* It uses Remarkup as the markup language in comments
  * Anyone outside of Phabricator heard of this?
* Code change suggestions are possible, but are different from comments and require more clicks.


## using git-absorb and git-revise makes my life easier

See [TIL: git helpers][git-helpers].
Two little tools that make fixup commits and rebasing easier to manage.

## git-cinnabar is an excellent hack

[git-cinnabar] is a "remote helper to interact with mercurial repositories".
It's _the_ solution to contribute to the Firefox repository ("mozilla-central") using git.
It allows to translate between git and mercurial commits,
and gives me git branches for mercurial bookmarks (and branches).
All that thanks to the tireless work of glandium.
Because it existed [I never really switched to Mercurial][toot3].

[firefox-announcement]: https://groups.google.com/a/mozilla.org/g/firefox-dev/c/QnfydsDj48o/m/8WadV0_dBQAJ?pli=1
[toot1]: https://hachyderm.io/@jer/111368262809769894
[toot2]: https://hachyderm.io/@jer/111368305246880082
[toot3]: https://hachyderm.io/@jer/111368268261643005
[jvns-misc-facts]: https://jvns.ca/blog/2023/10/20/some-miscellaneous-git-facts/
[jvns-git-term]: https://jvns.ca/blog/2023/11/01/confusing-git-terminology/
[jvns-rebasing]: https://jvns.ca/blog/2023/11/06/rebasing-what-can-go-wrong-/
[git-helpers]: https://fnordig.de/til/git/git-helpers.html
[git-cinnabar]: https://github.com/glandium/git-cinnabar
[phorge]: https://phorge.it/
