---
title: Read only root on Linux
tags: [linux, sysadmin, devops]
date: "2015-02-28T00:00:00"
aliases: "/linux/read-only-root-on-linux.html"
---

In many cases, it is required to run a system in such a way that it is tolerant of uncontrolled power losses, resets, etc. After such an event occurs, it should atleast be able to boot up and connect to the network so that some action can be taken remotely.

There are a few different ways in which this could be accomplished.

### Mounting the root filesystem with read-only flags

Most parts of the linux root filesystem can be mounted read-only without much problems, but there are some parts which don't play well. [This debian wiki page](https://wiki.debian.org/ReadonlyRoot) has some information about this approach. I thought this approach would not be very stable, so did not try it out completely.

### Using aufs/overlayfs

aufs is a union file system for linux systems, which enables us to mount separate filesystems as layers to form a single merged filesystem. Using aufs, we can mount the root file system as read-only, create a writable tmpfs ramdisk, and combine these so that the system thinks that the root filesystem is writable, but changes are not actually saved, and don't survive a reboot.

I found this method to be most suitable and stable for my task, and have been using this for the last 6 months. This system mounts the real filesytem at mountpoint `/ro` with read-only flag, creates a writable ramdisk at mountpoint `/rw`, and makes a union filesystem using these two at mountpoint `/`.

The steps I followed for my implementation are detailed below. These are just a modified version of the steps in [this ubuntu wiki page](https://help.ubuntu.com/community/aufsRootFileSystemOnUsbFlash). I am using Debian in my implementation.

1. Install debian using live cd or your preferred method.

2. After first boot, upgrade and configure the system as needed.

3. Install `aufs-tools`.

4. Add aufs to initramfs and setup [this script](https://gist.github.com/srijan/383a8d7af6860de6f9de) to start at init.

		# echo aufs >> /etc/initramfs-tools/modules
		# wget https://cdn.rawgit.com/srijan/383a8d7af6860de6f9de/raw/ -O /etc/initramfs-tools/scripts/init-bottom/__rootaufs
		# chmod 0755 /etc/initramfs-tools/scripts/init-bottom/__rootaufs

5. Remake the initramfs.

		# update-initramfs -u

6. Edit grub settings in `/etc/default/grub` and add `aufs=tmpfs` to `GRUB_CMDLINE_LINUX_DEFAULT`, and regenerate grub.

		# update-grub

7. `reboot`

#### Making changes

To change something trivial (like a file edit), just remount the `/ro` mountpoint as read-write, edit the file, and reboot.

	# mount -o remount,rw /ro

To do something more complicated (like install os packages), press `e` in grub menu during bootup, remove `aufs=tmpfs` from the kernel line, and boot using `F10`. The system will boot up normally once.

Another method could be to use a configuration management tool (puppet, chef, ansible, etc.) to make the required changes whenever the system comes online. The changes would be lost on reboot, but it would become much easier to manage multiple such systems.

Also, if some part of the system is required to be writable (like `/var/log`), that directory could be mounted separately as a read-write mountpoint.
