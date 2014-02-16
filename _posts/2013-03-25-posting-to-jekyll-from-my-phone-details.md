---
layout: post
title: Posting to Jekyll from my phone - Details
tags: [jekyll, blogging, mobile, github, prose]
categories: [blogging]
published: true
description: "Details about posting to jekyll using a phone"
---

This is an update to [an earlier post](/blogging/posting-to-jekyll-from-my-phone.html).

The workflow goes like this:

My blog's code is in a [github repository](https://github.com/srijan/srijan_blog). When I want to create or edit a post, I open up [prose.io](http://prose.io) to edit my repository. Since it is a web based application, I can use any device with a browser to use it.

After editing my code, I commit and push the changes to my repository. It has a [webhook](https://help.github.com/articles/post-receive-hooks) configured to send a notification to a deploy script hosted on my VPS.

The deploy script pulls the latest changes, rebuilds the website (using [jekyll](https://github.com/mojombo/jekyll)), and pushes the generated site to the final webhost.

The webhook deploy script I use is something like this:

{% gist 5233531 deploy.php %}
