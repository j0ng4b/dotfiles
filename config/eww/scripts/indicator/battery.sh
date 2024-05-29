#!/usr/bin/env sh

capacity_file="/sys/class/power_supply/BAT0/capacity"
status_file="/sys/class/power_supply/BAT0/status"


status=$(cat "$status_file" | sed -e 's/.*/\L&/')
capacity=$(cat "$capacity_file")

echo "{ \"capacity\": \"$capacity\", \"status\": \"$status\" }"
