#!/bin/bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then







    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then







    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
Clock() {
	DATETIME=$(date "+%a %b %d, %I:%M %p %Z")
	echo $DATETIME
}

Battery() {
	BATPERC=$(echo $[($(cat /sys/class/power_supply/BAT1/capacity) + $(cat /sys/class/power_supply/BAT0/capacity))/2])
        echo $BATPERC%
}

datausp() {
	datausp=$(echo $[$(cat /sys/class/net/w*/statistics/rx_bytes)/1024/1024])
        echo $datausp MB
}

ram() {
                ram=$(free -h | grep "Mem" | awk '{print $3}' )
                echo $ram
}

wifi() {
				wifi=`nmcli connection show --active | awk '{print $1}' | grep -v NAME`
        #wifi=$(connmanctl services | grep *AO | awk '{print $2}')
	[[ -z "$wifi" ]] && wifi="--------"
	echo $wifi
}

user() {
	echo $(whoami)
}

while :; do
        xsetroot -name "  $(Clock)                              @$(user) | $(datausp) | $(wifi) | $(ram) | $(Battery)"
        sleep 5;
done &


if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

wallpaper() {
	wall=$(find /misc/wallpapers -type f | shuf -n 1)
	wal -q -n -i $wall >/dev/null 
	(chmod +x /home/celestialbe-ing/.cache/wal/colors-tty.sh && source /home/celestialbe-ing/.cache/wal/colors-tty.sh && clear)
	sed -i 'N;$!P;D' $HOME/.cache/wal/colors-wal-dwm.h
	xwallpaper --zoom $wall
	(cd $HOME/.local/src/dwm-6.2 && make clean install) > /dev/null 2>&1
	(cd $HOME/.local/src/dmenu-5.0 && make clean install) > /dev/null 2>&1
	(cd $HOME/.local/src/st-0.8.4 && make clean install) > /dev/null 2>&1
}

#wallpaper
display -window root /home/consoletree/Downloads/wallhaven-y85ysd.jpg
exec dwm
dunst &
