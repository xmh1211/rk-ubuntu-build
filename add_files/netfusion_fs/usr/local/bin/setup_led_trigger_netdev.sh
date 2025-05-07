#!/bin/bash

if [ $# -ne 2 ];then
	echo "Usage: $0 led_name if_name"
	exit 1
fi

led_name=$1
if_name=$2

led_path="/sys/class/leds/${led_name}"
if_path="/sys/class/net/${if_name}"

if [ -d "${led_path}" ] && [ -d "${if_path}" ]; then
	echo netdev > "${led_path}/trigger"
	echo "$if_name" > "${led_path}/device_name"
	echo 1 > "${led_path}/rx"
	echo 1 > "${led_path}/tx"
fi
