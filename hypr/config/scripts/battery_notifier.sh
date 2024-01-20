#!/usr/bin/env sh

# This make debug less hard
capacity_file="/sys/class/power_supply/BAT0/capacity"
status_file="/sys/class/power_supply/BAT0/status"

# Battery status
status=$(cat "$status_file")

# First low level of battery to notify
default_low=10
default_timeout=3000

# The lowest battery level, when the battery is less than or equal this value
# the notification will be continue
lowest=5
lowest_timeout=1000

# Control text colors
color_normal=""
color_lowest=""

# When the battery goes less than or equal this value send a notification.
# Should start at `default_low`.
notify_low="$default_low"
timeout="$default_timeout"

# Return the battery icon given a capacity
battery_capacity_icon() {
    case "$(($1 / 10))" in
        10) echo "󰁹" ;;
         9) echo "󰂂" ;;
         8) echo "󰂁" ;;
         7) echo "󰂀" ;;
         6) echo "󰁿" ;;
         5) echo "󰁾" ;;
         4) echo "󰁽" ;;
         3) echo "󰁼" ;;
         2) echo "󰁻" ;;
         1) echo "󰁺" ;;
         *) echo "󰂎" ;;
    esac
}

battery_charging_icon() {
    case "$(($1 / 10))" in
        10) echo "󰂅" ;;
         9) echo "󰂋" ;;
         8) echo "󰂊" ;;
         7) echo "󰢞" ;;
         6) echo "󰂉" ;;
         5) echo "󰢝" ;;
         4) echo "󰂈" ;;
         3) echo "󰂇" ;;
         2) echo "󰂆" ;;
         1) echo "󰢜" ;;
         *) echo "󰢟" ;;
    esac
}

while true; do
    # Get new battery status
    new_status=$(cat "$status_file")
    # Fetch battery capacity, for some reason the capacity reported by the
    # capacity file is one unit less than the real capacity
    capacity=$(cat "$capacity_file")

    if [ "$new_status" != "$status" ]; then
        # When the battery get fully charged
        if [ "$new_status" = "Full"  ]; then
            if [ "$status" = "Discharging" ]; then
                notify-send -u normal -t $default_timeout -w "Full Battery" "<b><span color='#3e8fb0' size='30pt' baseline_shift='-5pt'>$(battery_charging_icon "$capacity")</span> Charging Full Battery</b>"
            else
                notify-send -u normal -t $default_timeout -w "Full Battery" "<b><span color='#3e8fb0' size='18pt'>󰂄</span> Full Battery</b>"
            fi
        # Notify when charger is connected
        elif [ "$new_status" = "Charging"  ]; then
            notify-send -u normal -t $default_timeout -w "Charging Battery" "<b><span color='#3e8fb0' size='30pt' baseline_shift='-5pt'>$(battery_charging_icon "$capacity")</span> Charging Battery</b>"

            # Reset notification of low battery
            if [ "$capacity" -gt "$default_low" ]; then
                notify_low="$default_low"
                timeout="$default_timeout"
            elif [ "$capacity" -gt "$lowest" ]; then
                notify_low="$lowest"
                timeout="$lowest_timeout"
            fi
        # Notify when charger is disconnected
        elif [ "$new_status" = "Discharging" ]; then
            notify-send -u normal -t $default_timeout -w "Discharging Battery" "<b><span color='#3e8fb0' size='18pt'>$(battery_capacity_icon "$capacity")</span> Charger disconnected</b>\n<span color='#3e8fb0' size='16pt'>$capacity%</span>"

            # Reset notification of low battery
            if [ "$capacity" -gt "$default_low" ]; then
                notify_low="$default_low"
                timeout="$default_timeout"
            elif [ "$capacity" -gt "$lowest" ]; then
                notify_low="$lowest"
                timeout="$lowest_timeout"
            fi
        # Any non valid status is ignored
        else
            sleep 1
            continue
        fi

        # Update the current battery status
        status="$new_status"
    fi

    if [ "$status" = "Discharging" ]; then
        if [ "$capacity" -le "$notify_low" ]; then
            notify-send -u critical -t $timeout -w "Low Battery" "<b><span color='#f6c177' size='18pt'>󰂃</span> Low Battery</b>\n<span color='#eb6f92' size='16pt'>$capacity%</span>"

            # Update the battery level threshold
            case "$notify_low" in
                "$default_low")
                    notify_low="$lowest"
                    timeout="$lowest_timeout"
                    ;;
            esac
        fi
    fi

    sleep 1
done

