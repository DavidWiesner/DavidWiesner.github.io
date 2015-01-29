---
title: 'Using VLC as UPnP renderer with rygel'
date: '2015-01-28'
description:
tags: []
---
I have a NAS, a smartphone and my local Computer. What todo with all this thinks? My NAS has a lot of multimedia files and my computer has a large monitor i thought why not connect all this thinks. 

So here is my setup:

1. my NAS as UPnP media server with all my movies
2. my Smartphone with an UPnP control point app like [BubbleUPnP](https://play.google.com/store/apps/details?id=com.bubblesoft.android.bubbleupnp)
3. and my linux machine

So now to the interessting part. [rygel](https://wiki.gnome.org/Projects/Rygel) is a UPnP AV MediaServer. But rygel can also as as an player to recieve media files and play this. This is called a UPnP media renderer. Rygel provides a standalone Media Renderer based on GStreamer playbin. This play video and audio files, but thats´s it. You can´t even play a video in fullscreeen mode. 

So here comes VLC in play with another protocoll called [MPRIS](http://specifications.freedesktop.org/mpris-spec/latest/). So i don´t get in to details here so MPRIS works and its connect VLC with our media renderer rygel. 

 So here is an example configuration for rygel. I have disabled all the stuff that isn´t necessary to just play our videos.
 
`~/.config/rygel.conf`

	[general]
	upnp-enabled=true
	enable-transcoding=false

	[Tracker]
	enabled=false

	[MediaExport]
	enabled=false

	[Playbin]
	enabled=false

	[GstLaunch]
	enabled=false

	[MPRIS]
	enabled=true

	[External]
	enabled=false


Rygel itself needs to know about all clients speaking MPRIS when it´s starts. So we need to start VLC before rygel. VLC should just stay in background until a video is played. So just start vlc with a dummy interface. And yes also the fullscreen mode. And a last command line option to disable that VLC display the stream path at the begining of a new track. 

`vlc --intf dummy --fullscreen --no-osd`

After that you can run rygel. But wouldn't it be nice to have a startup script to run all that staff for you.  

	#!/bin/bash

	vlcCall="vlc --intf dummy --fullscreen --no-osd"

	function cleanup(){
		for pid in $(pgrep -f "$vlcCall"); do
			kill -9 $pid 
		done
		killall rygel
	}

	function waitCpuDecrease(){
		pid=$1
		lastCpu="0.0"
		while true; do
			cpu=$(ps S -p $pid -o pcpu=)
			sleep 0.2
			[ $(bc <<< "$cpu < $lastCpu") == 1 ] && break
			lastCpu=$cpu
		done
	}

	# killall rygel and vlc
	cleanup

	# launch vlc in background
	$vlcCall &

	# wait until vlc has done most stuff
	waitCpuDecrease $!

	# start rygel
	rygel 

