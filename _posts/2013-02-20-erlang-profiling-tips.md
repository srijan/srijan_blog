---
layout: post
title: Erlang Profiling Tips
tags: [erlang, profiling, reltool, rebar, programming]
categories: [programming]
---

I have been using erlang recently for some of my work and private projects, and so I have decided to write about a few things there were hard to discover.

Profiling is an essential part of programming in erlang. [Erlang's efficiency guide][1] says:

> Even experienced software developers often guess wrong about where the performance bottlenecks are in their programs.

> Therefore, profile your program to see where the performance bottlenecks are and concentrate on optimizing them.

## Using profiling tools in releases (using rebar/reltool)

So, after finishing a particularly complicated bit of code, I wanted to see how well it performed, and figure out any bottlenecks.

But, I hit a roadblock. Following the [erlang manual for fprof][2], I tried to start it, but it wouldn't start and was giving the error:

    ** exception error: undefined function fprof:start/0
{: .language-erlang}

To make this work, I had to add `tools` to the list of apps in my `reltool.config` file. After adding this and regenerating, it all works.


## Better visualization of fprof output

So, after I got the fprof output, I discovered it was a long file with a lot of data, and no easy way to make sense of it.

I tried using [eprof][3] (which gives a condensed output), and it helped, but I was still searching for a better way.

Then I stumbled upon [a comment on stackoverflow][4], which linked to [erlgrind - a script to convert the fprof output to callgrind output][5], which can be visualized using [kcachegrind][6] or some such tool.


### Software Links

* [Erlang Profiling Guide][1]
* [Erlgrind][5]
* [Kcachegrind][6]

[1]: http://www.erlang.org/doc/efficiency_guide/profiling.html
[2]: http://www.erlang.org/doc/man/fprof.html
[3]: http://www.erlang.org/doc/man/eprof.html
[4]: http://stackoverflow.com/questions/14242607/eprof-erlang-profiling#comment19935708_14242607
[5]: https://github.com/isacssouza/erlgrind
[6]: http://kcachegrind.sourceforge.net/
