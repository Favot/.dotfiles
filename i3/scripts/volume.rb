#!/usr/bin/env ruby

# Fetch the current volume and mute status
volume_output = `pactl list sinks`
volume_level = volume_output[/\d+%/, 0].to_i # Extract volume level
is_muted = volume_output.include?("Mute: yes")

geticon = if is_muted == true
            "<span color='#ee99a0'> </span>"
          elsif volume_level > 66
            "<span color='#f0c6c6'> </span>"
          elsif volume_level > 33
            "<span color='#f0c6c6'> </span>"
          else
            '<span color="#f0c6c6"> </span>'
          end
puts(geticon)

