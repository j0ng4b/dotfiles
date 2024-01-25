#!/usr/bin/env sh

## Cache
weather_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/weather
weather_icon=$weather_cache_dir/icon
weather_city=$weather_cache_dir/city
weather_description=$weather_cache_dir/description
weather_temperature=$weather_cache_dir/temperature

location_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/location
location_latitude=$location_cache_dir/latitude
location_longitude=$location_cache_dir/longitude

if [ ! -d "$weather_cache_dir" ]; then
    mkdir -p "$weather_cache_dir"
fi

if [ ! -d "$location_cache_dir" ]; then
    mkdir -p "$location_cache_dir"

    touch $location_latitude
    touch $location_longitude
fi

## Coordinates
LATITUDE=$(cat $location_latitude)
LONGITUDE=$(cat $location_longitude)

APIKEY=$(cat "$(cd $(dirname $0); pwd)/openweather_key")

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

case $1 in
    update)
        get_location_data
        get_weather_data
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
esac

