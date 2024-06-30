#!/usr/bin/env sh

root_dir=$(cd $(dirname $0); pwd)

## Start dbus user session
dbus="dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS"
if [ -z "$(pgrep -f "$dbus")" ]; then
    $dbus &
fi

## Start pipewire
if [ -z "$(pgrep -f pipewire)" ]; then
    # With this PipeWire will automatic start pipewire-pulse and wireplumber
    # if the PipeWire configuration is installed
    pipewire &
fi

## Start dunst notification server
if [ -z "$(pgrep -f dunst)" ]; then
    dunst &
fi

## Start battery notifier
if [ -z "$(pgrep -f battery_notifier.sh)" ]; then
    echo $root_dir
    $root_dir/battery_notifier.sh &
fi

## Start swww daemon
if [ -z "$(pgrep -f swww-daemon)" ]; then
    swww-daemon &
fi

## Start eww
if [ -z "$(pgrep -f eww)" ]; then
    eww daemon
fi

eww open bar
eww open corner-left
eww open corner-right
eww reload # needed to adjusts the window corners

