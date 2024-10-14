#!/bin/bash

export LC_ALL=en_US.UTF8
modprobe fb_st7789v
fbdev=/dev/fb1
if [ ! -c $fbdev ];then
	echo "$fbdev is not exists!"
	exit 1
fi

if ! dpkg -l imagemagick >/dev/null 2>&1;then
	echo "imagemagick not installed!"
	exit 1
fi

if ! dpkg -l fbi >/dev/null 2>&1;then
	echo "fbi not installed!"
	exit 1
fi

size=240x135
tty=6
while :;do
	img=$(mktemp --suffix='.png')
	convert -size $size \
        	xc:red \
        	-fill white \
        	-pointsize 36 \
        	-gravity NorthWest \
       		-draw 'text 20,24 "Hlink H88K"' \
        	-draw 'text 20,64 "Hello world!"' \
        	$img
	fbi -d $fbdev -t 1 -1 -T $tty $img >/dev/null 2>&1
	sleep 5
	rm -f $img

	img=$(mktemp --suffix='.png')
	day=$(date +%Y-%m-%d)
	time=$(date +"  %H:%M:%S  ")
	convert -size $size \
        	xc:blue \
        	-fill white \
        	-pointsize 36 \
        	-gravity NorthWest \
       		-draw "text 20,24 \"$day\"" \
        	-draw "text 20,64 \"$time\"" \
        	$img
	fbi -d $fbdev -t 1 -1 -T $tty $img >/dev/null 2>&1
	sleep 5
	rm -f $img

	for img in /usr/local/share/h88k/imgs/*;do
		this_size=$(identify -format "%wx%h" $img 2>/dev/null)
		if [ "$this_size" != "" ];then
			case $this_size in 
				$size) zoom=""
				       ;;
				    *) zoom="-autozoom"
				       ;;
			esac
			fbi -d $fbdev -t 1 -1 -T $tty $zoom $img >/dev/null 2>&1
			sleep 5
		fi
	done
done
