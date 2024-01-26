#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
weather_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/weather
weather_lock=$weather_cache_dir/lock
weather_icon=$weather_cache_dir/icon
weather_city=$weather_cache_dir/city
weather_description=$weather_cache_dir/description
weather_temperature=$weather_cache_dir/temperature

weather_window_lock=$weather_cache_dir/window_lock

location_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/location
location_latitude=$location_cache_dir/latitude
location_longitude=$location_cache_dir/longitude

if [ ! -d "$weather_cache_dir" ]; then
    mkdir -p "$weather_cache_dir"

    echo "0" > $weather_lock

    echo "unlocked" > $weather_window_lock
fi

if [ ! -d "$location_cache_dir" ]; then
    mkdir -p "$location_cache_dir"

    touch $location_latitude
    touch $location_longitude
fi

## Coordinates
LATITUDE=$(cat $location_latitude)
LONGITUDE=$(cat $location_longitude)

APIKEY=$(cat "$root/openweather_key")

get_location_data() {
    # Fetch coordinates from Mozilla Location Service
    location=$(curl --silent "https://location.services.mozilla.com/v1/geolocate?key=geoclue")

    LATITUDE=$(echo $location | sed 's/.*"lat": \(-\?[0-9.]*\).*/\1/')
    LONGITUDE=$(echo $location | sed 's/.*"lng": \(-\?[0-9.]*\).*/\1/')

    echo $LATITUDE  > $location_latitude
    echo $LONGITUDE > $location_longitude
}

get_weather_data() {
    weather=$(curl --silent "https://api.openweathermap.org/data/2.5/weather?lat=$LATITUDE&lon=$LONGITUDE&appid=$APIKEY&units=metric")

    if [ -n "$weather" ]; then
        icon=$(echo $weather | sed -n 's/.*"icon":"\([0-9]\{2\}[d|n]\)".*/\1/p')

        case $icon in
            01d) icon="" ;;
            01n) icon="" ;;

            02d) icon="" ;;
            02n) icon="" ;;

            03d) icon="" ;;
            03n) icon="" ;;

            04d) icon="" ;;
            04n) icon="" ;;

            09d) icon="" ;;
            09n) icon="" ;;

            10d) icon="" ;;
            10n) icon="" ;;

            11d) icon="" ;;
            11n) icon="" ;;

            13d) icon="" ;;
            13n) icon="" ;;

            50d) icon="" ;;
            50n) icon="" ;;
        esac

        city="$(echo $weather | sed -n 's/.*"name":"\([a-zA-Z]*\)".*/\1/p')"
        description="$(echo $weather | sed -n 's/.*"description":"\([a-zA-Z| ]*\)".*/\1/p')"
        temperature="$(echo $weather | sed -n 's/.*"temp":\([0-9]*\).*/\1/p')°C"
    else
        icon=""
        city=""
        description="Weather unavailable"
        temperature="--°C"
    fi

    echo $icon > $weather_icon
    echo $city > $weather_city
    echo $description  | sed 's/^[a-z]/\U&/' > $weather_description
    echo $temperature > $weather_temperature
}

_locked_update() {
    diff=$(( $(date +%s) - $(cat $weather_lock) ))

    # Updates are locked for 10 minutes
    if [ $diff -ge 553 ]; then
        # Unlock updates
        echo "0" > $weather_lock
        return 0
    fi

    return 1
}

case $1 in
    update)
        _locked_update
        if [ $? -eq 0 ]; then
            # Lock updates
            echo $(date +%s) > $weather_lock

            get_location_data
            get_weather_data

            echo "weather updated"
        else
            echo "weather updates locked"
        fi
        ;;

    icon)
        cat $weather_icon
        ;;

    city)
        cat $weather_city
        ;;

    description)
        cat $weather_description
        ;;

    temperature)
        cat $weather_temperature
        ;;

    locked)
        _locked_update
        if [ $? -eq 0 ]; then
            echo "unlocked"
        else
            echo "locked"
        fi
        ;;

    close-window)
        if [ "$(cat $weather_window_lock)" = "locked" ]; then
            echo "unlocked" > $weather_window_lock
            eww close weather
        fi
        ;;

    toggle-window)
        if [ "$(cat $weather_window_lock)" = "unlocked" ]; then
            echo "locked" > $weather_window_lock
            eww open weather

            # Close others windows
            sh -c "$root/calendar.sh close"
        else
            echo "unlocked" > $weather_window_lock
            eww close weather
        fi
        ;;
esac

