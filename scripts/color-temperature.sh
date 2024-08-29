#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

cache_pid=$cache_dir/pid
cache_mode=$cache_dir/mode

if [ ! -d "$cache_dir" ]; then
    mkdir -p "$cache_dir"

    echo "-" > $cache_pid
    echo "auto" > $cache_mode
fi

_get_status() {
    enable=0
    if [ -n "$(pgrep wlsunset)" ]; then
        enable=1
    fi

    mode=$(cat $cache_mode)
    if [ "$mode" = "auto" ]; then
        nerd=""
        phosphor=""
    elif [ "$mode" = "high" ]; then
        nerd=""
        phosphor=""
    else
        nerd=""
        phosphor=""
    fi

    printf '{'
    printf '"enable": %s,' $enable
    printf '"mode": "%s",' $mode
    printf '"icons": {'
    printf '"nerd": "%s",' $nerd
    printf '"phosphor": "%s"' $phosphor
    printf '}'
    printf '}\n'
}

_start_color_adjust() {
    wlsunset -l $1 -L $2 &

    # Set the previous mode
    mode=$(cat $cache_mode)
    if [ "$mode" = "auto" ]; then
        # does nothing
        :
    elif [ "$mode" = "high" ]; then
        pkill -USR1 wlsunset
    else
        # Go to high
        pkill -USR1 wlsunset

        # Finally go to low
        pkill -USR1 wlsunset
    fi
}

_update_mode_to() {
    # From - To
    auto_high=1
    auto_low=2

    high_auto=2
    high_low=1

    low_auto=1
    low_high=2

    # Current mode
    mode=$(cat $cache_mode)
    if [ "$mode" = "$1" ]; then
        return
    fi

    eval count=\$${mode}_${1}
    for i in $(seq 1 $count); do
        pkill -USR1 wlsunset
    done

    echo $1 > $cache_mode
}


cmd=$1
case $cmd in
    status)
        _get_status
        ;;

    run)
        if [ $# -gt 1 ]; then
            error "Too many arguments!"
            exit 1
        fi

        if [ -z "$(pgrep wlsunset)" ]; then
            lat=$(sh $root/_runner location latitude)
            lon=$(sh $root/_runner location longitude)

            _start_color_adjust $lat $lon
            while true; do
                # Restart wlsunset if stopped
                if [ -z "$(pgrep wlsunset)" ]; then
                    lat=$(sh $root/_runner location latitude)
                    lon=$(sh $root/_runner location longitude)

                    _start_color_adjust $lat $lon
                fi

                sleep 30

                # Check for location changes
                cur_lat=$(sh $root/_runner location latitude)
                cur_lon=$(sh $root/_runner location longitude)
                if [ "$cur_lat" != "$lat" -o "$cur_lon" != "$lon" ]; then
                    lat=$cur_lat
                    lon=$cur_lon

                    # Restart wlsunset with new location coordinates
                    pkill wlsunset
                    _start_color_adjust $lat $lon
                fi
            done
        fi
        ;;

    get-mode)
        if [ $# -gt 1 ]; then
            error "Too many arguments!"
            exit 1
        fi

        echo $(cat $cache_mode)
        ;;

    set-mode)
        if [ $# -eq 1 ]; then
            error "Expected <mode> given 0 arguments!"
            exit 1
        fi

        subcmd=$2
        case $subcmd in
            auto | high | low)
                if [ $# -gt 2 ]; then
                    error "Too many arguments!"
                    exit 1
                fi

                _update_mode_to $subcmd
                ;;

            *)
                error "Unknown mode '$subcmd'!"
                exit 1
                ;;
        esac
        ;;

    cycle-mode)
        if [ $# -gt 1 ]; then
            error "Too many arguments!"
            exit 1
        fi

        pkill -USR1 wlsunset

        mode=$(cat $cache_mode)
        if [ "$mode" = "auto" ]; then
            echo "high" > $cache_mode
        elif [ "$mode" = "high" ]; then
            echo "low" > $cache_mode
        else
            echo "auto" > $cache_mode
        fi
        ;;

    *)
        error "Unknown command '$cmd'!"
        exit 1
        ;;
esac

