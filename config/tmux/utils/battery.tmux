#!/bin/env sh

battery() {
    capacity=$(sh -c "scripter battery status" | jq --raw-output '.capacity')
    echo "$capacity%"
}

battery

