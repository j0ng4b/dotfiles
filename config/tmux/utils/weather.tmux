#!/bin/env sh

weather() {
    city=$(sh -c "scripter location city")

    temperature=$(sh -c "scripter weather temperature")
    description=$(sh -c "scripter weather description")

    echo " $city  $temperature°C $description "
}

weather

