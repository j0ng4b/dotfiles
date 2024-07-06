#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

cache_time=$cache_dir/time
cache_json=$cache_dir/json

if [ -z "$cache_dir" ]; then
    exit 1
elif [ ! -d "$cache_dir" ]; then
    mkdir -p $cache_dir

    # Timestamp of last API call
    touch $cache_time

    # Last response API json
    touch $cache_json
fi

_get() {
    json=$(cat $cache_json)
    if [ -z "$json" ]; then
        json=$(curl -s http://ip-api.com/json | tee $cache_json)
    elif [ $(can_call_api $cache_time) -eq 0 ]; then
        json=$(curl -s http://ip-api.com/json | tee $cache_json)
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

