#!/usr/bin/env sh
# Runit service management helpers (Void Linux).

# Check if service exists
runit_svc_exists() {
    local svc="$1"
    [ -d "/etc/sv/$svc" ]
}

# Check if service is enabled
runit_svc_enabled() {
    local svc="$1"
    [ -L "/var/service/$svc" ]
}

# Enable service
runit_svc_enable() {
    local svc="$1"

    if ! runit_svc_exists "$svc"; then
        _warn "Service not found: $svc (in /etc/sv/$svc)"
        return 1
    fi

    if runit_svc_enabled "$svc"; then
        _info "Service already enabled: $svc"
        return 0
    fi

    _info "Enabling service: $svc"
    _run ln -s "/etc/sv/$svc" "/var/service/$svc" || _die "Failed to enable service: $svc"
}

# Disable service
runit_svc_disable() {
    local svc="$1"

    if runit_svc_enabled "$svc"; then
        _info "Disabling service: $svc"
        _run rm -f "/var/service/$svc" || _warn "Failed to disable service: $svc"
    else
        _info "Service already disabled: $svc"
    fi
}

# Enable and start service (or just enable if not running)
runit_svc_enable_start() {
    local svc="$1"
    runit_svc_enable "$svc" || return 1

    # Runit starts automatically when symlinked, but we can wait a bit for safety
    if _dry "sv start $svc"; then
        return 0
    fi

    sleep 1
    if ! sv status "$svc" >/dev/null 2>&1; then
        _warn "Service $svc may not have started automatically"
    fi
}

# Restart service
runit_svc_restart() {
    local svc="$1"

    if ! runit_svc_enabled "$svc"; then
        _warn "Service not enabled, skipping restart: $svc"
        return 0
    fi

    _info "Restarting service: $svc"
    _run sv restart "$svc" >/dev/null 2>&1 || _warn "Failed to restart service: $svc"
}
