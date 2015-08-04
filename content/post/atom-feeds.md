---
title: Atom feeds
tags: [atom, blog]
date: "2014-09-21T00:00:00"
aliases: "/notes/atom-feeds.html"
---

For implementing feeds for the [Isso commenting server][1], I was researching
about atom feeds, and though I would jot down some notes on the topic.

#### RSS2 vs Atom

Both are mostly accepted everywhere now a days, and it [seems like  a good idea
to provide both][2]. This particular post only talks about Atom feeds.

#### Nested Entries

Comments are threaded, [at least to one level deep][3], but Atom does not allow
nested entries. So, for the feed page for a post, we have two choices: listing
all comments, or just top level comments. If we have a feed page for each top
level comment, then that would be a flat list of all replies to the comment.

#### Feed URI

Every Atom entry must have a unique ID. [This page][4] has some intersting ways
to generate the ID. I think the best way is to generate a [tag URI][5] at the
time of comment creation, store it, and use it forever for that resource.

#### Reduce load/bandwidth by using `If-None-Match`

If we give out [ETags][6] with the feeds, then a client can do conditional
requests, for which the server only sends a full response if something has
changed.

[1]: http://posativ.org/isso/
[2]: http://wordpress.stackexchange.com/questions/2922/should-i-provide-rss-or-atom-feeds
[3]: http://blog.codinghorror.com/web-discussions-flat-by-design/
[4]: http://web.archive.org/web/20110514113830/http://diveintomark.org/archives/2004/05/28/howto-atom-id
[5]: http://en.wikipedia.org/wiki/Tag_URI
[6]: http://en.wikipedia.org/wiki/HTTP_ETag
