#!/bin/bash

capacity=$(cat /sys/class/power_supply/BATT/capacity)
status=$(cat /sys/class/power_supply/BATT/status)

getBatteryIcon() {
	if [ $1 -ge 90 ]; then
		echo "" # batteryIcon for 90% and above
	elif [ $1 -ge 75 ]; then
		echo "" # batteryIcon for 75% to 89%
	elif [ $1 -ge 50 ]; then
		echo "" # batteryIcon for 50% to 74%
	elif [ $1 -ge 25 ]; then
		echo "" # batteryIcon for 25% to 49%
	else
		echo ' ' # batteryIcon for 0% to 24%
	fi
}

getChargingIcon() {
	if [ "$status" = "Charging" ]; then
		echo ""
	else
		echo ""
	fi
}

getColor() {
	if [ $1 -lt 25 ]; then
		echo "#ed8796"
	else
		echo "#8bd5ca"
	fi
}

batteryIcon=$(getBatteryIcon $capacity)
chargingIcon=$(getChargingIcon $status)
color=$(getColor $capacity)

display() {
	echo "<span color='$color'>$chargingIcon $batteryIcon   $capacity %</span>"
}

display
