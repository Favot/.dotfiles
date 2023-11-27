#!/usr/bin/env ruby

def display_volume
# Fetch the current volume and mute status
  volume_output = `pactl list sinks`
  volume_level = volume_output[/\d+%/, 0].to_i # Extract volume level
  is_muted = volume_output.include?("Mute: yes")
  is_bluetooth_connected = volume_output.include?("bluez_sink")

  icon = getVolumeIcon(volume_level, is_muted)
  bluetooth_icon = getBluetoothIcon(is_bluetooth_connected)

  puts "<span color='#ee99a0'>#{bluetooth_icon} #{icon} </span>"
end

def getVolumeIcon (volume_level, is_muted)
  if is_muted == true
    ' '
  elsif volume_level > 66
    ""
  elsif volume_level > 33
    ""
  else
    ''
  end
end

def getBluetoothIcon (is_bluetooth_connected)
  if is_bluetooth_connected == true
    '󰥰'
  else
    ''
  end
end

puts display_volume
