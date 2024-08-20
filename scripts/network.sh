#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

cache_dir_wifi=$cache_dir/wifi
cache_wifi_quality=$cache_dir_wifi/quality

cache_dir_bluetooth=$cache_dir/bluetooth
cache_bluetooth_power=$cache_dir_wifi/power

if [ -z "$cache_dir" ]; then
    exit 1
elif [ ! -d "$cache_dir" ]; then
    mkdir -p $cache_dir
    mkdir -p $cache_dir_wifi
    mkdir -p $cache_dir_bluetooth

    # WiFi
    touch $cache_wifi_quality

    for i in $(seq 1 5); do
        echo -50 >> $cache_wifi_quality
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

_net_get_info() {
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
        if [ -n "$(command -pv wpa_cli)" ]; then
            # Get WiFi name from wpa_supplicant
            name=$(wpa_cli status | tr '\n' ';' | cut -d';' -f4 | cut -d'=' -f2)
        else
            # Fallback when no wpa_supplicant is found
            name="No name"
        fi

        _net_check_connection
        if [ $? -gt 0 ]; then
            if [ -n "$(command -pv wpa_cli)" ]; then
                # Get WiFi quality from wpa_supplicant
                quality=$(wpa_cli signal_poll | tr '\n' ';' | cut -d';' -f8 | cut -d'=' -f2)
            else
                # Get WiFi quality from Linux
                quality=$(cat /proc/net/wireless | sed -ne 's/.*\(-[0-9]\{2,4\}\)\..*/\1/p')
            fi

            # Update WiFi quality file
            sed -if '1d' "$cache_wifi_quality"
            echo "$quality" >> $cache_wifi_quality

            # Calculate average WiFi quality
            sum=0
            count=0
            for value in $(cat $cache_wifi_quality); do
                sum=$(($sum + $value))
                count=$(( $count + 1 ))
            done
            quality=$(( $sum / $count ))

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

    printf '{'
    printf '"enable": %s,' $connected
    printf '"quality": "%s"' $quality
    if [ -n "$name" ]; then
        printf ','
        printf '"name": "%s"' "$name"
    fi
    printf '}\n'
}

_bl_get_info() {
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

    echo $enable > $cache_bluetooth_power
    echo "{ \"enable\": \"$enable\", \"status\": \"$status\"}"
}


case $1 in
    wifi)
        case $2 in
            info)
                _net_get_info wifi
                ;;
        esac
        ;;

    ethernet)
        case $2 in
            info)
                _net_get_info ethernet
                ;;
        esac
        ;;

    bluetooth)
        case $2 in
            info)
                _bl_get_info
                ;;

            on | off | toggle)
                cmd=$2
                if [ "$cmd" = "toggle" ]; then
                    enable=$(cat $cache_bluetooth_power)
                    if [ "$enable" -eq 1 ]; then
                        cmd="off"
                    else
                        cmd="on"
                    fi
                fi

                bluetoothctl power $cmd >/dev/null
                echo $cmd > $cache_bluetooth_power
                ;;
        esac
        ;;
esac

