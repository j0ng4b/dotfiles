#!/usr/bin/env sh

batteries=$(find /sys/class/power_supply/ -name "BAT*")
if [ $(echo $batteries | wc -l) -gt 0 ]; then
    enable=1

    for bat in $batteries; do
        capacity_file="$bat/capacity"
        status_file="$bat/status"

        break
    done
else
    enable=0
fi


status=$(cat "$status_file" | sed -e 's/.*/\L&/')
capacity=$(cat "$capacity_file")

echo "{ \"enable\": \"$enable\", \"capacity\": \"$capacity\", \"status\": \"$status\" }"
