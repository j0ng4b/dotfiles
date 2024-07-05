#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

# Source Commons & Keys
. $root/_common
. $root/_keys


# Cache
if [ -z "$SCRIPT_CACHE_DIR" ]; then
    exit 1
elif [ ! -d "$SCRIPT_CACHE_DIR" ]; then
    mkdir -p $SCRIPT_CACHE_DIR

    # Timestamp of last API call
    touch $SCRIPT_CACHE_DIR/time

    # Last response API json
    touch $SCRIPT_CACHE_DIR/json
fi

_get() {
    json=$(cat $SCRIPT_CACHE_DIR/json)
    if [ -z "$json" ]; then
        json=$(curl -s http://ip-api.com/json | tee $SCRIPT_CACHE_DIR/json)
    elif [ $(can_call_api $SCRIPT_CACHE_DIR/time) -eq 0 ]; then
        json=$(curl -s http://ip-api.com/json | tee $SCRIPT_CACHE_DIR/json)
    fi

    echo $json
}

case $1 in
    city)
        echo $(_get) | jq --raw-output '.city'
        ;;

    latitude)
        echo $(_get) | jq --raw-output '.lat'
        ;;

    longitude)
        echo $(_get) | jq --raw-output '.lon'
        ;;

    coord)
        json=$(_get)

        printf '['
        echo $json | jq --raw-output0 '.lat'
        printf ','
        echo $json | jq --raw-output0 '.lon'
        printf ']\n'
        ;;
esac

