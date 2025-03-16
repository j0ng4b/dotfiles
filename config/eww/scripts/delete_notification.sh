#!/usr/bin/env sh

# Added notification to deleted notifications list, this is used to animate the
# notification dismissal
eww update dismissed_notification="$1"

# Wait for the notification dismiss animation
sleep 0.5

# Dismiss notification
sh scripts/scripter notification dismiss $1
eww update notifications="$(scripts/scripter notification list)"

# Remove the notification from the dismissed notifications list
eww update dismissed_notification=""

