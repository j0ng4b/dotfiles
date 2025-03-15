#!/usr/bin/env sh

# Added notification to deleted notifications list, this is used to animate the
# notification dismissal
dismissed_notifications=$(eww get dismissed_notifications)
eww update dismissed_notifications="$(echo $dismissed_notifications | jq ". + [$1]")"

# Wait for the notification dismiss animation
sleep 2

# Dismiss notification
sh scripts/scripter notification dismiss $1
eww update notifications="$(scripts/scripter notification list)"

# Remove the notification from the dismissed notifications list
dismissed_notifications=$(eww get dismissed_notifications)
eww update dismissed_notifications="$(echo $dismissed_notifications | jq "map(select(. != $1))")"

