#!/bin/bash

capacity=$(cat /sys/class/power_supply/BATT/capacity)
status=$(cat /sys/class/power_supply/BATT/status)

batteryCapacityIcon() {
	if [ $1 -ge 90 ]; then
		echo "" # Icon for 90% and above
	elif [ $1 -ge 75 ]; then
		echo "" # Icon for 75% to 89%
	elif [ $1 -ge 50 ]; then
		echo "" # Icon for 50% to 74%
	elif [ $1 -ge 25 ]; then
		echo "" # Icon for 25% to 49%
	else
		echo ' ' # Icon for 0% to 24%
	fi
}

icon=$(batteryCapacityIcon $capacity)

if [ "$status" = "Charging" ]; then
	echo " $icon   $capacity %"
else
	echo "$icon   $capacity %" ,
fi
