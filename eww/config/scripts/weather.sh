#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

# Load secret keys including OpenWeather key
. $root/secret_keys

## Cache
weather_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/weather
weather_lock=$weather_cache_dir/lock
weather_icon=$weather_cache_dir/icon
weather_city=$weather_cache_dir/city
weather_humidity=$weather_cache_dir/humidity
weather_wind_speed=$weather_cache_dir/wind_speed
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

get_location_data() {
    # Fetch coordinates from Mozilla Location Service
    location=$(curl --silent "https://location.services.mozilla.com/v1/geolocate?key=geoclue")

    LATITUDE=$(echo $location | jq '.location.lat')
    LONGITUDE=$(echo $location | jq '.location.lng')

    echo $LATITUDE > $location_latitude
    echo $LONGITUDE > $location_longitude
}

get_weather_data() {
    if [ -n $LANG ]; then
        LANGUAGE="&lang=$(echo $LANG | sed 's/\([a-zA-Z_]*\).*/\1/')"
    else
        LANGUAGE=""
    fi

    weather=$(curl --silent "https://api.openweathermap.org/data/2.5/weather?lat=$LATITUDE&lon=$LONGITUDE&appid=$WEATHER_API_KEY&units=metric$LANGUAGE")

    if [ -n "$weather" ]; then
        case $(echo $weather | jq -r '.weather[0].icon') in
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

        city=$(echo $weather | jq -r '.name')
        humidity=$(echo $weather | jq -r '.main.humidity')%
        wind_speed=$(echo $weather | jq -r '.wind.speed * 3.6')
        description=$(echo $weather | jq -r '.weather[0].description')
        temperature=$(echo $weather | jq '.main.temp' | cut -d'.' -f1)°C
    else
        icon=""
        city=""
        humidity=50%
        wind_speed=10
        description="Weather unavailable"
        temperature="--°C"

        # Unlock updates on failure
        echo "0" > $weather_lock
    fi

    echo $icon > $weather_icon
    echo $city > $weather_city
    echo $humidity > $weather_humidity
    echo $wind_speed | sed 's/\([0-9]*\.[0-9]\{0,2\}\).*/\1 km\/h/' > $weather_wind_speed
    echo $description | sed 's/^[a-z]/\U&/' > $weather_description
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

        fi
        ;;

    icon)
        cat $weather_icon
        ;;

    city)
        cat $weather_city
        ;;

    humidity)
        cat $weather_humidity
        ;;

    wind-speed)
        cat $weather_wind_speed
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

