---
title: Speeding up compiles
tags: [ccache, icecream, distributed, compile, linux, libreoffice]
description: "Speeding up compile times in C"
date: "2013-08-14T00:00:00"
aliases: "/programming/speeding-up-compiles.html"
---

I got interested in [LibreOffice][1] a few days ago, and wanted to contribute. I wanted to see how a large project is run, and the [Easy Hacks][2] section looked easy enough to begin.

But, there was one problem: LibreOffice is huge, and takes a long time to compile (especially for the first time). It took ~40 minutes to build on the best workstation I have access to (a 24 core intel server). It would take more than a day to build on my laptop, and I wanted to be able to build and iterate on my laptop.

The [How to Build][3] wiki had a few pointers, and I decided to look into them.


### [CCache][4]

As noted on their website, ccache is a compiler cache, and speeds up compilation by storing stuff, and reusing them on recompilation. This won't decrease the first compile time (in fact, it might increase it), but future compilations would be faster.

To use ccache, I made an exports file (see below) which I source before doing any LibreOffice related stuff. Programs like [ondir](5) can help automate this. I decided on a max cache size of 8GB, and set it with:

    $ ccache --max-size 8G

### [Icecream][6]

Icecream enables distributing the compiling load to multiple machines, like [distcc][7]. I decided to go with icecream because support for it is built into LibreOffice's autogen.sh.

Using icecream turned out to be as simple as installing and starting services on the build machines, doing `./autogen.sh --enable-icecream`, followed by `make`. For projects that don't have such icecream flags, its enough to add icecream's bin directory to the beginning of `$PATH`, and everything works.

Icecream can do a distributed build even if the machines in the cluster are of different types. [This section of their readme][8] gives more information about that.

Building LibreOffice on my laptop using icecream took about 50 minutes (for a clean build).

### My exports.sh file

<script src="https://gist.github.com/srijan/6214104.js"></script>

[1]: http://www.libreoffice.org/
[2]: https://wiki.documentfoundation.org/Easy_Hacks
[3]: https://wiki.documentfoundation.org/Development/How_to_build
[4]: http://ccache.samba.org/
[5]: http://swapoff.org/ondir.html
[6]: https://github.com/icecc/icecream
[7]: https://code.google.com/p/distcc/
[8]: https://github.com/icecc/icecream#using-icecream-in-heterogeneous-environments

