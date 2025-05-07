#!/usr/bin/bash

################################################################################
# mystartup.sh
#
# This shell program is for testing a startup like rc.local using systemd.
# By David Both
# Licensed under GPL V2
#
################################################################################

# This program should be placed in /usr/local/bin

################################################################################
# This is a test entry
getty_tty1_enabled=$(systemctl is-enabled getty@tty1.service)
if [ "${getty_tty1_enabled}" == "enabled" ];then
	systemctl stop getty@tty1.service
	systemctl disable getty@tty1.service
fi

/usr/local/bin/setup_led_trigger_netdev.sh "yellow:lan" "eth0"
/usr/local/bin/setup_led_trigger_netdev.sh "yellow:wan" "eth1"
echo `date +%F" "%T` "Startup worked" >> /var/log/mystartup.log
