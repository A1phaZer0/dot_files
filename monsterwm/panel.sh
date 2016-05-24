#!/bin/bash

#enum { RESIZE, MOVE };
#enum { TILE, MONOCLE, BSTACK, GRID, FIBONACCI, DUALSTACK, EQUAL, MODES };


# monitorid:monitorfocused:desktopid:clientcount:layoutmode:desktopfocused:urgent
#*   the monitor id
#*   monitor focused or not
#*   the desktop id
#*   the desktop's client count
#*   the desktop's tiling layout mode/id
#*   whether the desktop is the current focused (1) or not (0)
#*   whether any client in that desktop has received an urgent hint
 
icon_mpc="  "
icon_vol="  "
icon_date="  "
icon_title="  "
icon_lt="" # left triangle
icon_ra="" # right arrow
icon_la="" # left arrow

curtag="FF823232" # background color of current tag
acttag="FF917154" # background color of active tag
nemptag="FF663366" # background color of not empty tag
ugtag="FFFF0000" # background color of urgent tag
deftag="FFCC6600" # background color of default tag
titlecolor="FF000000" # main color of title bar

names=( "term" "web" "img" "misc" "alpha" )
moncnt=2 # number of monitors

function lineout()
{
	awk -W interactive '$0 != l { print; l = $0; system(); }' "$@"
}



{
        while :; do
 		echo "volume_ $(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*\)%\].*/\1/')"
 		sleep 1 || break
 	done > >(lineout) &


	while :; do
		date +'date_ %H:%M'
		sleep 1 || break
	done > >(lineout) &


	while :; do
		read  -r info
		if [[ -n "$info" && "$info" != "$prev" && "$info" =~ ^([0-9]+:){5} ]]; then
			prev="$info"
		fi
		read -ra desktops <<< "$prev"
		# number of desktops will be different since using multihead
		for i in $(seq 0 $[${#names[@]}*$moncnt-1]); do
			mid=${desktops[$i]:0:1}
			mfocused=${desktops[$i]:2:1}
			id=${desktops[$i]:4:1}
			count=${desktops[$i]:6:1}
			layout=${desktops[$i]:8:1}
			focused=${desktops[$i]:10:1}
			urgent=${desktops[$i]:12:1}
			if [ "$focused" -ne 0 ]; then
				fg[$i]="%{F-}"
				bg[$i]="%{B-}"
				ul[$i]="%{U#$curtag}" #underline color
				ub[$i]="%{+u}"
				ue[$i]="%{-u}"
			elif [ "$urgent" -ne 0 ]; then
				fg[$i]="%{F-}"
				bg[$i]="%{B-}"
				ul[$i]="%{U#$ugtag}"
				ub[$i]="%{+u}"
				ue[$i]="%{-u}"
			elif [ "$count" -ne 0 ]; then
				fg[$i]="%{F-}"
                                bg[$i]="%{B-}"
                                ul[$i]="%{U#$nemptag}"
                                ub[$i]="%{+u}"
                                ue[$i]="%{-u}"
			else
				fg[$i]="%{F-}"
				bg[$i]="%{B-}"
				ul[$i]="%{U-}"
				ub[$i]="%{-u}"
				ue[$i]="%{-u}"
			fi
			if [ "$mfocused" -eq 1 ]; then
				focused_monitor=$mid
			fi
				
		done
		# set name foreground background underline color of monitor focused
		case $focused_monitor in
		0)	monfg="%{F-}"
			monbg="%{B-}"
			monul="%{U#$curtag}"
			monname=INFINITE
			;;
		1)	monfg="%{F-}"
			monbg="%{B-}"
			monul="%{U#$nemptag}"
			monname=WORLD
			;;
		esac
		for i in $(seq 0 $[$moncnt-1]); do # monitors
			for j in $(seq 0 ${#names[@]}); do
				index=$[$j+$i*${#names[@]}]
				m_status[i]+=" ${fg[$index]}${bg[$index]}${ul[$index]}${ub[$index]} ${names[$j]} ${ue[$index]}" 
			done
		done
		echo "${m_status[$focused_monitor]}"
	done

} 2> /dev/null | {
	while read line  || true; do
		cmd=( $line )
		case "${cmd[0]}" in
		"date_") 
			date=${cmd[1]}
			;;
		"volume_") 
			vol=${cmd[1]}
			;;
		*)  
			tags=$line
			;;
		esac
		if [[ -n "$tags" && -n "$vol" && -n "$date" ]]; then
			echo "%{l} $tags%{c}$monfg$monbg%{+u}$monname%{-u}%{B-}%{F-}%{r}%{F#$curtag}%{U#$curtag}%{+u}$icon_vol%{-u}%{B-}%{F-} $vol%% %{F#$nemptag}%{U#$nemptag}%{+u}$icon_date%{-u}%{B-}%{F-} $date "
		fi
	done
} 2> /dev/null | lemonbar -d -p -g 1600x22+1080 -u 4 -B '#99212121' -F '#FFA8A8A8' -f '-gohu-gohufont-medium-r-*-*-14-*-*-*-*-*-*-*'
#default panel foreground color shuould be A8A8A8
