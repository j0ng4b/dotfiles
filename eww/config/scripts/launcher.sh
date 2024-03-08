#!/usr/bin/env sh

# Why this sleep? It's due this:
# https://github.com/elkowar/eww/issues/1022#issuecomment-1936989742
#
# The delay maybe should be increased, it's depends how fast rofi-wayland window
# opens.
sleep 0.15

# On some cases its needed to set current work directory to home directory
# otherwise applications current work directory will be the eww configuration
# directory (e.g. GVim).
cd $HOME

rofi -show drun -terminal foot &

