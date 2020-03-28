+++
date = "2016-08-04T23:23:00+05:30"
title = "My backup strategy: part 1"
tags = ["backups", "linux", "archlinux", "duplicity", "duply", "systemd", "usb"]
+++

I don't have a lot of data to backup - just my home folder (on my Archlinux
laptop) which just has configuration for all the tools I'm using and my
programming work.

For photos or videos taken from my phone, I use google photos for backup - which
works pretty well. Even if I delete the original files from my phone, the photos
app still keeps them online.

Coming back to my laptop, I'm currently using [duplicity][4] (with the
[duply][5] wrapper) to backup to multiple destinations. Why multiple locations?
I wanted one local copy so that I can restore fast, and at least one at a remote
location so that I can still restore if the local disk fails.

For off-site, I'm using the fantastic [rsync.net][1] service. For local backups,
I'm using two destinations: a USB HDD at my home, and a NFS server at my work.
**Depending on where I am, the backup will be done to the correct destination**.

This post will deal with the backups to my local USB disk.

Here's what I've been able to achieve: the backups will run every hour as long
as the USB disk is connected. If it is not connected, the backup script will not
even be triggered. I did not want to see backup failures in my logs if the HDD
is not connected.

I've done this using a systemd timer and service. I've defined these units in
[the user-level part for systemd][2] so that root privileges are not required.

### Mounting the USB Disk

To automatically mount the USB disk, I've added the following line to my
`/etc/fstab`:

```
UUID=27DFA4B43C8C0635 /mnt/Ext01 ntfs-3g nosuid,nodev,nofail,auto,x-gvfs-show,permissions 0 0
```

### Duply config for running the backup

Here's my **duply** config file (kept at `~/.duply/ext01/conf`) (mostly
self-explanatory):

```
TARGET='file:///mnt/Ext01/Backups/'
SOURCE='/home/srijan'
MAX_AGE=1Y
MAX_FULL_BACKUPS=15
MAX_FULLS_WITH_INCRS=2
MAX_FULLBKP_AGE=1M
DUPL_PARAMS="$DUPL_PARAMS --full-if-older-than $MAX_FULLBKP_AGE "
VOLSIZE=4
DUPL_PARAMS="$DUPL_PARAMS --volsize $VOLSIZE "
DUPL_PARAMS="$DUPL_PARAMS --exclude-other-filesystems "
```

This can be run manually using:
```
$ duply ext01 backup
```

Exclusions can be specified in the file `~/.config/ext01/exclude` in a glob-like
format.

### Systemd Service for running the backup

Next, here's the **service file** (kept at
`~/.config/systemd/user/duply_ext01.service`):

```
[Unit]
Description=Run backup using duply: ext01 profile
Requires=mnt-Ext01.mount
After=mnt-Ext01.mount

[Service]
Type=oneshot
ExecStart=/usr/bin/duply ext01 backup
```

The `Requires` option says that this unit has a dependency on the mounting of
Ext01. The `After` option specifies the order in which these two should be
started (run this service *after* mounting).

After this step, the service can be run manually (via systemd) using:
```
$ systemctl --user start duply_ext01.service
```

### Systemd timer for triggering the backup service

Next step is triggering it automatically every hour. Here's the **timer file**
(kept at `~/.config/systemd/user/duply_ext01.timer`):

```
[Unit]
Description=Run backup using duply ext01 profile every hour
BindsTo=mnt-Ext01.mount
After=mnt-Ext01.mount

[Timer]
OnCalendar=hourly
AccuracySec=10m
Persistent=true

[Install]
WantedBy=mnt-Ext01.mount
```

Here, the `BindsTo` option defines a dependency similar to the `Requires` option
above, but also declares that this unit is stopped when the mount point goes
away due to any reason. This is because I don't want the trigger to fire if the
HDD is not connected.

The `Persistent=true` option ensures that when the timer is activated, the
service unit is triggered immediately if it would have been triggered at least
once during the time when the timer was inactive. This is because I want to
catch up on missed runs of the service when the disk was disconnected.

After creating this file, I ran the following to actually link this timer to
mount / unmount events for the Ext01 disk:

```
$ systemctl --user enable duply_ext01.timer
```

That's it. Now, whenever I connect the USB disk to my laptop, the timer is
started. This timer triggers the backup service to run every hour. Also, it
takes care that if some run was missed when the disk was disconnected, then it
would be triggered as soon as the disk is connected without waiting for the next
hour mark. Pretty cool!

#### NOTES:

- Changing any systemd unit file requires a `systemd --user daemon-reload`
  before systemd can recognize the changes.
- The [systemd documentation][3] was very helpful.

### Coming Soon

Although it would be similar, but I'll also document how to do the above with
NFS or SSHFS filesystems (instead of local disks). The major difference would be
handling loss of internet connectivity, timeouts, etc.


[1]: http://www.rsync.net
[2]: https://wiki.archlinux.org/index.php/Systemd/User
[3]: https://www.freedesktop.org/software/systemd/man/index.html
[4]: http://duplicity.nongnu.org/
[5]: http://duply.net/
