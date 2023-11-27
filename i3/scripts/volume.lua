#!/usr/bin/env lua

local function displayVolume()
	-- Fetch the current volume and mute status
	local handle = io.popen("pactl list sinks")
	if handle == nil then
		return print("Error when getting IO list")
	end

	local volume_output = handle:read("*a")

	handle:close()

	local volume_level = tonumber(string.match(volume_output, "(%d+)%%")) -- Extract volume level
	local is_muted = string.find(volume_output, "Mute: yes") ~= nil
	local is_bluetooth_connected = string.find(volume_output, "bluez_sink") ~= nil

	local icon = GetVolumeIcon(volume_level, is_muted)
	local bluetooth_icon = GetBluetoothIcon(is_bluetooth_connected)

	print("<span color='#ee99a0'>" .. bluetooth_icon .. " " .. icon .. " </span>")
end

function GetVolumeIcon(volume_level, is_muted)
	if is_muted then
		return " "
	elseif volume_level > 66 then
		return ""
	elseif volume_level > 33 then
		return ""
	else
		return ""
	end
end

function GetBluetoothIcon(is_bluetooth_connected)
	if is_bluetooth_connected then
		return "󰥰"
	else
		return ""
	end
end

displayVolume()
