---
layout: post
title:  Reading ext2/ext3/ext4 filesystems on Windows 7
tags: [ext2, ext3, ext4, windows 7, linux]
categories: [linux]
---

If you dual boot windows with ubuntu (or some other linux distro) and often switch between the two, you will invariably need some file which is on the other system.

While getting that file is easy in linux (you can mount ntfs partitions), its a bit difficult in windows. There have been tools that supported only ext2, and other tools (ext2fsd) that can read ext4, but only with ‘extents’ feature disabled.

But, I found another software yesterday – [ext2read](http://sourceforge.net/projects/ext2read/) – that supports ext2, ext3 and ext4, even with extents. While it does not mount the partition, but you can browse through the files and copy them to some windows partition.

Here is a screenshot of it I took on windows 7:

[![Ext2Explore on windows screenshot](http://srijn.s3.amazonaws.com/blog/images/ext2explore.png)](http://srijn.s3.amazonaws.com/blog/images/ext2explore.png "Click to view full image")

Does anyone have a better alternative? Something that can mount an ext3/ext4 partition? Please let me know through the comments. 
