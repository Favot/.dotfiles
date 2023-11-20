#!/bin/bash

vpnCheck() {
	status=$(expressvpn status)

	if [[ $status == *"Connected"* ]]; then
		echo '<span color="#00FF00">󰒄: On</span>'
	else
		echo "<span color='#ffa500'>󰒄: Off</span>"
	fi
}

vpnCheck
