---
layout: post
title: Making Flex-Ajax Bridge work in Chrome and Chromium
tags: [flex, programming, adobe, ajax, flex-ajax bridge, google chrome, chromium]
categories: [programming]
description: "Making Flex Ajax Bridge work in Google Chrome and Chromium browsers"
---

Adobe has made it very easy to interact with flex applications from javascript by making the [Flex-Ajax Bridge](http://livedocs.adobe.com/flex/3/html/help.html?content=ajaxbridge_1.html).

I am presently using it in an application, which uses the flex part for recording and playing videos, and rails for everything else. But, I encountered a problem when trying to run it on Chromium and Google Chrome browsers. The flex swf was not loading at all in those browsers, but it was working fine in all other browsers I tested.

So, I searched online and found [a blog post mentioning this problem](http://www.timothyhuertas.com/blog/2010/11/30/fabridgejs-play-nice-with-chrome/ "FABridge.js play nice with Chrome") and a solution: mending a small bug in `FABridge.js`. The bug is in the function `FABridge__bridgeInitialized`. The change is:

### Old code:

`if (/Explorer/.test(navigator.appName) || /Konqueror|Safari|KHTML/.test(navigator.appVersion))`

### New Code:

`if ((!(/Chrome/.test(navigator.appVersion))) && ((/Explorer/.test(navigator.appName) || /Konqueror|Safari|KHTML/.test(navigator.appVersion))))`

Thanks to Tim for his solution. What is most surprising is that he blogged about this back in November 2010, and Adobe still has not fixed this issue!
