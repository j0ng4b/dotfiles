#!/usr/bin/env sh

root_dir=$(cd $(dirname $0); pwd)

## Start pipewire
if [ $(pgrep -f pipewire) ]; then
    # With this PipeWire will automatic start pipewire-pulse and wireplumber
    # if the PipeWire configuration is installed
    pipewire &
fi

## Start D-Bus
#dbus="dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus"
#if [ $(pgrep -fx "$dbus") ]; then
#    $dbus &
#fi

## Start mako notification server
#if [ $(pgrep -f mako) ]; then
#    mako &
#fi

## Start battery notifier
if [ $(pgrep -f battery_notifier.sh) ]; then
    $root_dir/battery_notifier.sh &
fi

## Start swww daemon
if [ $(pgrep -f swww-daemon) ]; then
    swww-daemon &
fi

## Start eww
if [ $(pgrep -f eww) ]; then
    eww daemon
fi

eww open bar
eww open corner-left
eww open corner-right
eww reload # needed to adjusts the window corners

