#!/bin/env sh

# batteries list
batteries=''

has_battery() {
    batteries=$(find /sys/class/power_supply/ -name "BAT*")
    if [ $(echo $batteries | wc -l) -gt 0 ]; then
        return 0
    fi

    return 1
}

status_battery() {
    if ! has_battery; then
        return
    fi

    icon=''
    for bat in $batteries; do
        capacity="$(cat "$bat/capacity")"
        status="$(cat "$bat/status" | sed -e 's/.*/\L&/')"

        if [ "$status" = "charging"  ]; then
            case "$(($capacity / 10))" in
                10) icon='󰂅' ;;
                 9) icon='󰂋' ;;
                 8) icon='󰂊' ;;
                 7) icon='󰢞' ;;
                 6) icon='󰂉' ;;
                 5) icon='󰢝' ;;
                 4) icon='󰂈' ;;
                 3) icon='󰂇' ;;
                 2) icon='󰂆' ;;
                 1) icon='󰢜' ;;
                 *) icon='󰢟' ;;
            esac
        elif [ "$status" = "discharging" ]; then
            case "$(($capacity / 10))" in
                10) icon='󰁹' ;;
                 9) icon='󰂂' ;;
                 8) icon='󰂁' ;;
                 7) icon='󰂀' ;;
                 6) icon='󰁿' ;;
                 5) icon='󰁾' ;;
                 4) icon='󰁽' ;;
                 3) icon='󰁼' ;;
                 2) icon='󰁻' ;;
                 1) icon='󰁺' ;;
                 *) icon='󰂎' ;;
            esac
        elif [ "$status" = "not charging" ]; then
            icon='󱈑'
        elif [ "$status" = "full" ]; then
            icon='󰂏'
        fi

        break
    done

    echo "$capacity% $icon "
}

status_battery

