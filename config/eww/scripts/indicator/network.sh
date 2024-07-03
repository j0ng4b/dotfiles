#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/network

wifi_cache_dir=$cache_dir/wifi
wifi_quality=$wifi_cache_dir/quality

if [ ! -d "$cache_dir" ]; then
    mkdir -p $cache_dir
    mkdir -p $wifi_cache_dir

    for i in $(seq 1 5); do
        echo -50 >> $wifi_quality
    done
fi


_net_check_connection() {
    for url in google.com duckduckgo.com wikipedia.org; do
        ping -c 1 $url 1>/dev/null
        if [ $? -eq 0 ]; then
            return 1
        fi
    done

    return 0
}

net_get_info() {
    type=$1
    if [ "$type" = "wifi" ]; then
        interfaces=$(find /sys/class/net -name "wlan*" -or -name "wl*")
    elif [ "$type" = "ethernet" ]; then
        interfaces=$(find /sys/class/net -name "en*" -or -name "eth*")
    fi

    connected=0
    for net in $interfaces; do
        carrier=$(cat $net/carrier 2>/dev/null)
        operstate=$(cat $net/operstate)

        if [ -n "$carrier" ]; then
            connected=$carrier
        elif [ "$operstate" = "up" ]; then
            # Maybe this isn't needed, if interface is up carrier will never be
            # empty
            connected=1
        elif [ "$operstate" = "down" ]; then
            # This is when the interface is "soft" down, i.e., using ip link, in
            # this case the carrier will be empty
            connected=0
        elif [ "$operstate" = "unknown" ]; then
            # Maybe this isn't needed too, if interface operational state is
            # unknown carrier also will never be empty
            connected=$carrier
        fi

        # Stop at any connected interface
        if [ "$connected" = 1 ]; then
            break
        fi
    done

    # Immediately return if disconnected
    if [ "$connected" = 0 ]; then
        echo "{ \"enable\": \"$connected\", \"quality\": \"unknown\" }"
        return
    fi

    # Get connection quality
    if [ "$type" = "wifi" ]; then
        _net_check_connection
        if [ $? -gt 0 ]; then
            quality=$(cat /proc/net/wireless | sed -ne 's/.*\(-[0-9]\{2,4\}\)\..*/\1/p')

            # Update wifi quality file
            echo "$(tail -n 99 $wifi_quality)" > $wifi_quality
            echo "$quality" >> $wifi_quality

            # Calculate average WiFi quality
            sum=0
            for value in $(tail -n 100 $wifi_quality); do
                sum=$(($sum + $value))
            done
            quality=$(($sum / 100))

            if [ "$quality" -ge -50 ]; then
                quality=high
            elif [ "$quality" -ge -70 ]; then
                quality=good
            elif [ "$quality" -ge -89 ]; then
                quality=low
            else
                quality=bad
            fi
        else
            quality="noconnection"
        fi
    elif [ "$type" = "ethernet" ]; then
        _net_check_connection
        if [ $? -gt 0 ]; then
            quality="unkown"
        else
            quality="noconnection"
        fi
    fi

    echo "{ \"enable\": \"$connected\", \"quality\": \"$quality\" }"
}

bl_get_info() {
    info=$(bluetoothctl show)

    if [ "$(echo $info | sed -ne 's/.*Powered: \([a-z]\{2,3\}\).*/\1/p')" = "yes" ]; then
        enable=1

        if [ -n "$(bluetoothctl devices Connected)" ]; then
            status="connected"
        else
            status="disconnected"
        fi
    else
        enable=0
        status="unknown"
    fi

    echo "{ \"enable\": \"$enable\", \"status\": \"$status\"}"
}


case $1 in
    wifi)
        case $2 in
            info)
                net_get_info wifi
                ;;
        esac
        ;;

    ethernet)
        case $2 in
            info)
                net_get_info ethernet
                ;;
        esac
        ;;

    bluetooth)
        case $2 in
            info)
                bl_get_info
                ;;
        esac
        ;;
esac

