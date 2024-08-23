#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

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


if [ $enable -eq 1 ]; then
    status=$(cat "$status_file" | sed -e 's/.*/\L&/')
    capacity=$(cat "$capacity_file")
else
    warn 'No battery!'
    exit 0
fi

_battery_capacity_icon() {
    case "$(($capacity / 10))" in
        10) echo '󰁹' ;;
         9) echo '󰂂' ;;
         8) echo '󰂁' ;;
         7) echo '󰂀' ;;
         6) echo '󰁿' ;;
         5) echo '󰁾' ;;
         4) echo '󰁽' ;;
         3) echo '󰁼' ;;
         2) echo '󰁻' ;;
         1) echo '󰁺' ;;
         *) echo '󰂎' ;;
    esac
}

_battery_charging_icon() {
    case "$(($capacity / 10))" in
        10) echo '󰂅' ;;
         9) echo '󰂋' ;;
         8) echo '󰂊' ;;
         7) echo '󰢞' ;;
         6) echo '󰂉' ;;
         5) echo '󰢝' ;;
         4) echo '󰂈' ;;
         3) echo '󰂇' ;;
         2) echo '󰂆' ;;
         1) echo '󰢜' ;;
         *) echo '󰢟' ;;
    esac
}

case $1 in
    status)
        echo "{ \"enable\": \"$enable\", \"capacity\": \"$capacity\", \"status\": \"$status\" }"
        ;;

    capacity)
        echo $capacity
        ;;

    icon)
        if [ "$status" = "charging"  ]; then
            echo $(_battery_charging_icon)
        elif [ "$status" = "discharging" ]; then
            echo $(_battery_capacity_icon)
        elif [ "$status" = "not charging" ]; then
            echo '󱈑'
        elif [ "$status" = "full" ]; then
            echo '󰂏'
        fi
        ;;
esac

