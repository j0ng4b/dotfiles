#!/usr/bin/env sh

root_dir=$(cd $(dirname $0); pwd)

## Start pipewire
pgrep -f pipewire || pipewire &

## Start D-Bus
dbus="dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus"
pgrep -fx "$dbus" || $dbus &

## Start mako notification server
pgrep -f mako || mako &

## Start battery notifier
pgrep -f battery_notifier.sh || $root_dir/battery_notifier.sh &

