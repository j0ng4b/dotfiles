#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
systray_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/systray
systray_count=$systray_cache_dir/count

if [ ! -d "$systray_cache_dir" ]; then
    mkdir -p "$systray_cache_dir"
    echo "0" > $systray_count
fi

# On system reboot reset the counter
system_uptime=$(date -d "$(uptime -s)" +%s)
current_time=$(date +%s)
if [ $(( ($current_time - $system_uptime) / 60 )) -le 5 ]; then
    echo "0" > $systray_count
fi

export count=$(cat $systray_count)
dbus-monitor --session "interface='org.kde.StatusNotifierWatcher'" |
    while read -r signal; do
        new_count=""
        case "$signal" in
            *"StatusNotifierItemRegistered"*)
                new_count=$(( $count + 1 ))
                ;;

            *"StatusNotifierItemUnregistered"*)
                new_count=$(( $count - 1 ))
                ;;
        esac

        if [ -n "$new_count" ]; then
            if [ -z "$new_count" -o "$new_count" -lt 0 ]; then
                count=0
            else
                count=$new_count
            fi

            echo "$count" | tee $systray_count
        else
            echo "$count"
        fi
    done

