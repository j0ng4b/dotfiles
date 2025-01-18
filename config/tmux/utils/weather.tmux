#!/bin/env sh

root=$(cd $(dirname $0); pwd)

weather() {
    runner="$root/../scripts/scripter"

    city=$(sh -c "$runner location city")

    temperature=$(sh -c "$runner weather temperature")
    description=$(sh -c "$runner weather description")

    echo " $city  $temperature°C $description "
}

weather

