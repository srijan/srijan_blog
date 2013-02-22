---
layout: post
title: Creating sounds themes for Ubuntu 9.10 and 10.04
tags: [sound themes, ubuntu, linux, lucid lynx, karmic koala]
categories: [linux]
---

I recently installed Ubuntu 10.04 Lucid Lynx and was impressed with the work done by its developers. But the default system sounds were still the same and I didn't  like them. So, I started searching for a way to change these sounds and make my own sound theme.

It turns out that it was very easy to do this in versions of Ubuntu prior to 9.10. There, you just had to go to `System>Preferences>Sounds` and change the sounds associated with each event manually. But, those options are not there in the Sound Preferences window anymore. Now, I know that someone is going to make a new tool soon to change these sounds, but till then, you can follow the steps below to make your own custom Ubuntu sound theme.

Step 1: Open the folder `/usr/share/sounds` as root. To do this, you can press Alt+F2, and type gksudo nautilus in the run window. Enter your password, and browse to the folder.

Step 2: Create a new folder and name it as the name you want to call your theme. For now, I'll call it `mytheme`.

Step 3: Inside this folder, create a new file and call it `index.theme`. Then, open it using your favorite text editor and enter the following in the file:

***
	[Sound Theme]
	Name=mytheme
	Directories=stereo
	
	[stereo]
	OutputProfile=stereo
***
In this, replace `mytheme` with your theme name.

Step 4: Create a directory called `stereo` inside your theme directory. This is the directory which will contain all the sound files for your new theme.

Step 5: This is when you actually select which sounds you want to keep for which events. Some common events and their sound's filenames required are given below. For a complete list (as complete as I could find), goto [Sound Naming Specifications](http://blogs.anayalabs.com/srijan/2010/sound-naming-specifications/).

***
### Alerts:
	dialog-error
	battery-low

	Notifications:
	message-new-instant
	message-new-email
	phone-incoming-call
	system-bootup
	system-ready
	system-shutdown
	desktop-login
	desktop-logout
	service-login
	service-logout
	battery-caution
	dialog-warning
	dialog-information
	dialog-question

### Actions:
	phone-outgoing-calling
	message-sent-instant
	message-sent-email
	bell
	trash-empty
	item-deleted
	file-trash

### Input Feedback:
	window-close
	window-slide
	dialog-ok
	dialog-cancel
	button-pressed
	button-released
	menu-click
	button-toggle-on
	button-toggle-off
	item-selected
***
Step 4: After you have selected some of these sound files, you have to convert it to `.ogg`, `.oga`, or `.wav` format (these are the formats that I was able to test successfully, but the default Ubuntu sounds are in `.ogg`, so, you may want to convert to that). To convert to `.ogg` or `.oga` formats, you can use a software called `Sound Converter`, available through the software center or the package manager. Or you can just [click here to install it](apt://soundconverter).

Step 5: Now, just put these files in the stereo directory you created above.

Step 6: This is the easiest step. Goto `Syetem > Preferences > Sound`. In the drop-down menu, you should be able to see the name of the new theme you created. Select that, close and reboot.
software-update-urgent 
