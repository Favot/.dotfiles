#!/bin/bash

vpnCheck() {
	status=$(expressvpn status)
	echo $status
	if [[ $status == *"Connected"* ]]; then
		echo '<span color="#00FF00">󰒄: On</span>'
	elif [[ $status == *"Not connected"* ]]; then
		echo "<span color='#ffa500'>󰒄: Off</span>"
	else
		echo "Unknown"
	fi
}

vpnCheck
