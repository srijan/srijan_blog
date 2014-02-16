---
layout: post
title: Trying Emacs
tags: [emacs, editor]
categories: [programming]
published: true
description: "My experiment with trying emacs as a text editor for programming"
---

I have been using [Vim][1] as my text editor for the last few years, and have been very happy with it. But lately, some features of [Emacs][2] have got me interested (especially [org-mode][3]), and I wanted to try it out. After all, I won't know the difference until I actually try it, and opinions on text editors vary widely on the internet.

So, I decided to give it a try. First I went through the built-in Emacs Tutorial, and it seemed easy enough. I got used to the basic commands fairly quickly. I guess the real benefits will start to show a little later, when I try to optimize some ways of doing things.

For now, I just wanted to do some basic configuration so that I could start using emacs right now. So, I did the following changes (scroll to the bottom of this page for the full `init.el` file):

* Hide the menu, tool, and scroll bars

* Add line numbers

* Hide splash screen and banner

* Setup [Marmalade][4]

	Marmalade is a package archive for emacs, which makes it easier to install non-official packages.

* Maximize emacs window on startup

	My emacs was not starting up maximized, and I did not want to maximize it manually every time I started it. I found [this page][5] addressing this issue, and tried out one of the [solutions for linux][6], and it worked great.

For now, it all looks good, and I can start using it with only this small configuration.

For example, for writing this post, I installed [markdown-mode][7] using marmalade, and I got syntax highlighting and stuff.

I will keep using this, and adding to my setup as required, for a few weeks, and then evaluate whether I should switch completely.

### Complete ~/.emacs.d/init.el file:

{% gist 6243716 init.el %}

[1]: http://www.vim.org/
[2]: http://www.gnu.org/software/emacs/
[3]: http://orgmode.org/
[4]: http://marmalade-repo.org/
[5]: http://www.emacswiki.org/emacs/FullScreen
[6]: http://www.emacswiki.org/emacs/FullScreen#toc20
[7]: http://jblevins.org/projects/markdown-mode/
