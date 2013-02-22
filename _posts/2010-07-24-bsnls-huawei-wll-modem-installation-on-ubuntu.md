---
layout: post
title:  BSNL's HUAWEI WLL Modem Installation on Ubuntu
tags: [bsnl, huawei, wll, modem, linux, ubuntu, india]
categories: [linux]
---

There are already many blog posts and forum entries regarding this. This is just my drop in the ocean.

The key here is using `usb_modeswitch` to switch to modem mode, modprobing to detect the modem, and then using `wvdial` (called weave dial) to dial through the modem. Here are the exact steps:

*	Install `wvdial`. Check for its dependencies carefully (i had to install 3 other packages before wvdial).

*	Edit the wvdial configuration. Run
	
		sudo vim /etc/wvdial.conf
	(replace vim with your favorite text editor)

	Add the following lines to the end to the file:
***
		[Dialer bsnl]
		Modem Type = Analog Modem
		Init1 = ATZ
		Stupid Mode = 1
		Phone = #777
		PPPD Options = lock noauth refuse-eap refuse-chap refuse-mschap nobsdcomp nodeflate
		Modem = /dev/ttyUSB0
		Username = <username>
		Dial Command = ATDT
		Password = <password>
		Baud = 9600
***
	For me, the modem was at ttyUSB0.

*	Try to run this:

		sudo wvdial bsnl

	If it says modem not detected, means you will have to use modprobe and/or usb_modeswitch (see below).If it connects successfully, you are done!

*	Since the modem was not detected, so we need to modprobe it. First, get your modem's Vendor Id and Product Id by running

		lsusb

	Search for a line like this:

		Bus 005 Device 001: ID 12d1:1010 Huawei Technologies Co., Ltd.

	In my case, the Vendor Id is 12d1 and Product Id is 1010. Now just run

		sudo modprobe usbserial vendor=0x12d1 product=0x1010

	After this, try to connect again (like in step 2). If still not successful, goto step 4.

*	Install `usb_modeswitch`. As before, check if dependencies are satisfied. After installing it, run this:

		sudo usb_modeswitch -v 0x12d1 -p 0x1010 -H –W

	This command manually switches the modem's mode from storage device to modem. Now execute step 2 again, and you will be connected to the internet. Keep this terminal open for as long as you want to be connected and press Ctrl+C when you want to disconnect.

Thanks to Ubuntu forums, and [this blog](http://mr-greens.blogspot.com/2010/05/bsnl-huawei-ets-1201-modem-installation.html) for inputs.
