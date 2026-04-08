#!/usr/bin/env sh
# Setup integrations.

setup_integrations() {
    _info "=== Integrations Setup ==="

    local username="$REAL_USER"

    _info "Finalizing user group memberships..."
    user_add_groups "$username" docker _seatd bluetooth

    _info "Setup integrations completed"
}
