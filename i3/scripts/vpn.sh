#!/bin/bash

vpnCheck() {
	status=$(expressvpn status)

	if [[ $status == *"Connected"* ]]; then
		echo '<span color="#a6da95">󰒄: On</span>'
	else
		echo "<span color='#ee99a0'>󰒄: Off</span>"
	fi
}

vpnCheck
