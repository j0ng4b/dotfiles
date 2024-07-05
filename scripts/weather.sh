#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

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
    LAT=$(sh $root/_runner location latitude)
    LON=$(sh $root/_runner location longitude)

    url="https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$WEATHER_API_KEY&units=metric"

    json=$(cat $SCRIPT_CACHE_DIR/json)
    if [ -z "$json" ]; then
        json=$(curl -s $url | tee $SCRIPT_CACHE_DIR/json)
    elif [ $(can_call_api $SCRIPT_CACHE_DIR/time) -eq 0 ]; then
        json=$(curl -s $url | tee $SCRIPT_CACHE_DIR/json)
    fi

    echo $json
}

case $1 in
    temperature)
        printf '%.0f\n' $(echo $(_get) | jq --raw-output '.main.temp')
        ;;
esac

