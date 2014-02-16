---
layout: post
title: Vagrant box for Archlinux 64 bit
tags: [vagrant, archlinux, virtualbox]
categories: [programming]
published: true
description: "A vagrant box for Archlinux 64 bit"
---

I have been using [Vagrant][1] a lot since its beginning, and the boxes provided by them have been enough till now.

But, I wanted an up to date box with [Archlinux][2], and I could not find one online. So, I decided to build and release one myself.

It turned out to be surprisingly easy. I followed the steps given in [this page][3], and had a working box very soon.

I have [released the box][4], and I am planning to update it every few months.

For now, I have not included any provisioning stuff in the box, but might do so later if I need it.

Maybe I'll write a script to generate the box itself.

The box can be downloaded from this link: [http://vagrant.srijn.net][4], or using the following commands:

    $ vagrant box add arch64 http://vagrant.srijn.net/archlinux-x64-2013-08-17.box
    $ vagrant init arch64
    $ vagrant up

[1]: http://www.vagrantup.com/
[2]: https://www.archlinux.org/
[3]: https://github.com/okfn/ckan/wiki/How-to-Create-a-CentOS-Vagrant-Base-Box
[4]: http://vagrant.srijn.net/
