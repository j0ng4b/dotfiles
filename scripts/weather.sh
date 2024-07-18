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
    # NOTE: location script will block until can fetch location data
    LAT=$(sh $root/_runner location latitude)
    LON=$(sh $root/_runner location longitude)

    url="https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$WEATHER_API_KEY&units=metric"

    json=$(cat $cache_json)
    if [ -z "$json" ]; then
        json=$(curl -s $url | tee $cache_json)
    elif [ $(can_call_api $cache_time) -eq 0 ]; then
        json=$(curl -s $url | tee $cache_json)
    fi

    echo $json
}

case $1 in
    temperature)
        printf '%.0f\n' $(echo $(_get) | jq --raw-output '.main.temp')
        ;;

    icon)
        case $(echo $(_get) | jq --raw-output '.weather[0].icon') in
            # Clear sky
            01d) icon='󰖨' ;;
            01n) icon='' ;;

            # Few clouds
            02d) icon='' ;;
            02n) icon='' ;;

            # Scattered clouds
            03d) icon='' ;;
            03n) icon='' ;;

            # Broken clouds
            04d) icon='' ;;
            04n) icon='' ;;

            # Shower rain
            09d) icon='' ;;
            09n) icon='' ;;

            # Rain
            10d) icon='' ;;
            10n) icon='' ;;

            # Thunderstorm
            11d) icon='' ;;
            11n) icon='' ;;

            # Snow
            13d) icon='' ;;
            13n) icon='' ;;

            # Mist
            50d) icon='' ;;
            50n) icon='' ;;
        esac

        echo $icon
esac

