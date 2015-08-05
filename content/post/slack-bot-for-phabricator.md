---
date: 2015-08-04T23:49:01+05:30
title: Slack bot for Phabricator
tags: [development, slack, phabricator, bot]
---

[Phabricator][1] is a collection of open source web [applications useful for software
development][2] built on a single platform. We have been using phabricator tools for
about a month now, and it seems great. The best thing is: all different
components (code review, task/bug tracking, project management, repo browing)
are well-integrated with one another, and work really well together.

Except one thing, of course, and that is it's chat app (Conpherence). This is what they say
about it themselves:

> * Like Slack, but nowhere as good.
> * Seriously, Slack is way better.

Well, we use [Slack][3] ourselves in our organization, and I tried to find out
a way to integrate phabricator with slack.

My use case was something like this:

1. There are project specific channels (rooms?) in our slack
2. Important updates related to a project should be auto-posted to this channel
3. Discussions in this channel regarding the project should be **enhanced** by
   auto-linking of task ids or code review ids mentioned, to their URLs.

I found a few different ways:

### Phabricator bots on github

There are a couple of projects on github which integrate phabricator with slack:

* https://github.com/etcinit/phabricator-slack-feed
* https://github.com/psjay/ph-slack

Both of these are good solutions for point 2 above, but don't (currently) solve
point 3. A way to go forward would be to contribute new features to these projects.

### Phabricator's in-built chatbot

Phabricator already has the concept of a [chatbot][4] which connects to IRC.

This bot covers both points 2 and 3 from my requirement, and also has some extra
features, like recording chatlogs which can be browsed in the Phabricator web
interface, which can in turn be referred to in comments for tasks, etc.

Slack has an [IRC gateway][8] which can be used for this purpose.

But the phabdev article on chatbot has an omnious note:

> NOTE: The chat bot is somewhat experimental and not very mature.

Digging a little further, I found this task:
[T7829: PhabricatorBotFeedNotificationHandler is completely broken and unusable][5],
which has one piece of bad news in the comments:

> @epriestley: Bot stuff is generally a very low priority and I don't expect to
> review or merge any of it for a long time (roughly, around the Bot/API
> iteration of Conpherence, which is months/years away).

To make it work, [@staticshock][7] posted some [fixes][6].

I made some changes of my own to make the bot filter the feed by project, so
that one channel gets updates for only one or some of the projects.

My final diff can be found here: https://secure.phabricator.com/P1839.

And, my sample bot config is shared below:

```
{
  "server" : "organization.irc.slack.com",
  "port" : 6667,
  "nick" : "phabot",
  "pass": "random-password",
  "ssl": true,
  "join" : [
    "#project-updates",
  ],
  "handlers" : [
    "PhabricatorBotObjectNameHandler",
    "PhabricatorBotLogHandler",
    "PhabricatorBotFeedNotificationHandler"
  ],

  "conduit.uri" : "http://phab.example.com",
  "conduit.user" : "phabot",
  "conduit.token" : "api-token",

  "macro.size" : 48,
  "macro.aspect" : 0.66,

  "notification.channels" : ["#project-updates"],
  "notification.types": ["task"],
  "notification.projects": ["PHID-PROJ-ut55kdadskptl4he5iw39"],
  "notification.verbosity": 0
}
```

We have to pass a list of project PHIDs in `notification.projects`.

### The way forward

So, the version shared above works fine for me, for now. Currently, it does not
support connecting to multiple channels, having different config per channel,
detecting projects things other than tasks, ability to enter project name
instead of PHID in config file, etc. These are some things I would want to add
to my diff in the future.

Also, another good solution to all this would be to extend the chatbot code in
phabricator in a generic way to be able to support bots for different services
like slack, telegram, hipchat, etc.

[1]: http://phabricator.org/
[2]: https://phacility.com/phabricator/
[3]: https://slack.com/
[4]: https://secure.phabricator.com/book/phabdev/article/chatbot/
[5]: https://secure.phabricator.com/T7829
[6]: https://secure.phabricator.com/T7829#120246
[7]: https://secure.phabricator.com/p/staticshock/
[8]: https://slack.zendesk.com/hc/en-us/articles/201727913-Connecting-to-Slack-over-IRC-and-XMPP

