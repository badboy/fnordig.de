---
permalink: "/{{ year }}/{{ month }}/{{ day }}/review-feedback"
title: "Review Feedback: a response to the Feedback Ladder"
published_date: "2020-03-18 12:30:00 +0100"
layout: post.liquid
data:
  route: blog
  tags:
    - mozilla
---

Last week I read [Feedback Ladders: How We Encode Code Reviews at Netlify](https://www.netlify.com/blog/2020/03/05/feedback-ladders-how-we-encode-code-reviews-at-netlify/) and also shared that with my team at Mozilla.
In this post I want to summarize how we organize our reviews and compare that to Netlify's _Feedback Ladder_.

My team is mainly responsible for all work on [Firefox Telemetry](https://searchfox.org/mozilla-central/source/toolkit/components/telemetry) and [our other projects](https://github.com/mozilla/glean).
(Nearly) everything we do is first tracked in Bugs on [Bugzilla](https://bugzilla.mozilla.org/home).
No code change (nor doc change) will land without review.
For changes to land in Firefox the developer is responsible for picking the right reviewer, though right now that's mostly shared work between chutten and me. Sometimes we need to involve experts from other components of Firefox.

On Glean we rely on an [auto-assign bot](https://github.com/apps/auto-assign) to pick a reviewer after opening a pull request.
Sometimes the submitter also actively picks one from the team as a reviewer, e.g. if it's a followup to previous work or if some niche expertise is needed.

When reviewing we use a system not too dissimilar to the Feedback ladder.
However it is much more informal.

Let's compare the different steps:

## ⛰ Mountain / Blocking and requires immediate action

In Mozilla speak that would be an "r-" - "Rejected".
In my team this rarely (never?) happens on code changes.

On any bigger changes or features we usually start with a design proposal, that goes through feedback iterations with stakeholders (the direct team or colleagues from other teams, depending on scope).
This would be the point to shut down ideas or turn them around to fit our and our user's needs.
Design proposals vary in depth, but may already include implementation details where required.

## 🧗‍♀️ Boulder / Blocking

For us this is "Changes requested".
Both review tools we use (Phabricator and plain GitHub PRs) have this as explicit review states.

The code change can't land until problems are fixed.
Once the developer pushed new changes the pull request will need another round of review.

All problems should be clearly pointed out during the review and comments attached to where the problem is.
However, unlike the Feedback ladder, our individual comments don't follow a strict wording, so the developer who submitted the change can't differentiate between them easily.

## ⚪️ Pebble / Non-blocking but requires future action

This is famously known here as "r+wc" - "review accepted, with comments".

Now for us this is actually two different parts:

First, the reviewer is fine with the overall change, but found some smaller things that definitely need to be changed, such as documentation wording, code comments or naming.
However, it is considered the developer's task to ensure these changes get made before the PR is landed and no additional round of review needs to follow.
GitHub luckily allows reviewers to submit the _exact change_ required and the developer can apply it with a button click, so there's not always the need to go back to the code editor, commit code, push it, ...

Second, some things require a follow-up, such as some possible code refactor, additional features or tracking the bug fix through the release process for later validation
(we deal with data, so for some fixes we need to see real-world data coming in to determine if the fix worked).
Reviewers should ask for a bug to be filed and the developer usually posts the filed bug as a comment.
In that state the pull request is then ready to get merged.

Again, there's no formal concept or wording (other than "this needs a follow-up bug" and GitHub's "Apply suggestion") we use to make the review comments stick out.

## ⏳ Sand / Non-blocking but requires future consideration

This is very similar to the "⚪️ Pebble" step, but the follow-up bugs filed are more likely going to be "Investigate ..." or "Proposal for ...".

## 🌫 Dust / Non-blocking, “take it or leave it”

This is all the other little comments and will usually end in a "r+" - "Review done & accepted".
We enforce code formatting via tools, so there's rarely need to discuss this.
Therefore this comes down to naming or slightly different code patterns.

More often than not I label these in my comments as "small nit: ...".
More often than not these are still taken in and applied.

---

## So ... ?

In my team we already use an informal but working method to express the different kinds of review feedback.
We certainly lack in clarity and immediate visibility of the different patterns and that's certainly a thing we can improve.
Not only might that help us right now, it would also help in later onboarding new folks.

I'm not fully sold on the metaphors used in the _Feedback Ladder_, but I do like using emojis in combination with plaintext to signal things.
