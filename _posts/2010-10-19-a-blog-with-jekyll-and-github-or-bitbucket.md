---
layout: post
title: A blog with jekyll and github/bitbucket
tags: [blog, jekyll, github, bitbucket, free blog host]
categories: [blogging]
description: "Hosting a jekyll blog on github or bitbuket"
---

Today, a friend asked me to start him up with a blog of his own. I was going to suggest [posterous](http://posterous.com/), but he had some conditions:

* It should be ‘entirely’ configurable
* It should be free
* Once setup, it should be very easy to update
* He should be able to point some (already existing) sub-domain to it for free

The first condition ruled out [posterous](http://posterous.com/), [tumblr](http://www.tumblr.com/), [wordpress.com](http://wordpress.com/), [blogger](http://blogger.com/) and other blog hosting platforms. Though most of these are almost totally configurable, but I knew my friend wanted more.

The second option ruled out paying for a shared host and setting up [wordpress.com](http://wordpress.com/) or any other [content management system](http://en.wikipedia.org/wiki/Content_management_system) on it.

Considering just these two conditions, I thought about setting up static pages on free hosting platforms like [github](https://github.com/), [bitbucket](https://bitbucket.org/), or [google app engine](http://code.google.com/appengine/). But then he said he wanted it to be easy to update. He did not want to edit a lot of html.

Then I thought of [Jekyll](http://jekyllrb.com/) – a simple, blog aware, static site generator. These static output pages could be easily uploaded to github or bitbucket. And it can be customised indefinitely. And since we can use textile or markdown to write the content, it is easy to update and upload. Also, setting up a sub-domain to point to these is very simple.

### Setting up [Jekyll](http://jekyllrb.com/)

This was easier than expected. First, I created a file called `_config.yml` with some basic settings. Then two folders – `_layouts` and `_posts`. Jekyll uses files and folders starting with an underscore for its configuration and settings. Then I create two basic layouts: `default.html` and `post.html`. And almost all is done.

Next, I created an index page – `index.html` with some random ‘about’ text with some quote, followed by a list of blog posts published using liquid converters (scroll down for complete code link).

Next, I created one sample post inside the `_posts` folder. Then I ran Jekyll in server mode
`jekyll --server`
and opened `http://localhost:4000/` in my browser to see how the output looked. Also, the generated files were put inside a folder called `_sites` which I could now upload on any host and my blog would be ready.

### Publishing on [github](https://github.com/)

I just made a new git repository inside the `_sites` folder, added the files, committed them, and pushed to the github repository. More information on this can be found on [Github Pages](http://pages.github.com/).

### Publishing on [bitbucket](https://bitbucket.org/)

This was also similar to setting up on github. Init the repository, add files, commit, and push to bitbucket repository. More information can be found on this [guide by Steve Losh](http://hgtip.com/tips/beginner/2009-10-13-free-hosting-at-bitbucket/).

The hosted blogs can be found on:

[http://mohityadav.github.com/](http://mohityadav.github.com/)

[http://mohityadav.bitbucket.org/](http://mohityadav.bitbucket.org/)

Note that my friend has not set up a custom sub domain on these, and the sites are very basic (no designs).
The complete source for jekyll config can be found here:
[http://hg.srijanchoudhary.com/jekyll-setup-gh-bb/](http://hg.srijanchoudhary.com/jekyll-setup-gh-bb/)

### Further thoughts:

Here, I have used html for index page and posts. But, Jekyll can be used as easily with textile and markdown.
Apparently, this can also be hosted on google app engine (instead of github or bitbucket), though I have not tried it yet. If anyone of you has, please leave your comments.
Also, this static blog does not have commenting features. But, it can be implemented using Disqus, which I might cover in another post.
If any of you have any other suggestions for my friend’s four condition blog, please leave your comments. 
