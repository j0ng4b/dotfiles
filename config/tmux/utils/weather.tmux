#!/bin/env sh

root=$(cd $(dirname $0); pwd)

weather() {
    runner="$root/../scripts/script-runner"

    city=$(sh -c "$runner location city")

    icon=$(sh -c "$runner weather icon")
    temperature=$(sh -c "$runner weather temperature")
    description=$(sh -c "$runner weather description")

    echo " $city $icon  $temperature°C $description "
}

weather

