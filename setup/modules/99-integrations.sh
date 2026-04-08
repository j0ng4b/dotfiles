#!/usr/bin/env sh
# Setup integrations.

setup_integrations() {
    _info "=== Integrations Setup ==="

    local username="$REAL_USER"

    _info "Finalizing user group memberships..."
    user_add_groups "$username" docker _seatd bluetooth

    _info "Setting up udev rules for backlight and LEDs..."
    _run write_file_root /etc/udev/rules.d/99-backlight-leds.rules 0644 root:root <<'EOF'
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chgrp input /sys/class/leds/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chmod g+w /sys/class/leds/%k/brightness"
EOF

    _info "Reloading udev rules..."
    _run udevadm control --reload-rules >/dev/null 2>&1 || \
        _warn "Failed to reload udev rules"

    _info "Setup integrations completed"
}
