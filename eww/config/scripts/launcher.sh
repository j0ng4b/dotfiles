#!/usr/bin/env sh

# Why this sleep? It's due this:
# https://github.com/elkowar/eww/issues/1022#issuecomment-1936989742
#
# The delay maybe should be increased, it's depends how fast rofi-wayland window
# opens.
sleep 0.15

rofi -show drun -terminal foot &

