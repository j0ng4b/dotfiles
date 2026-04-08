#!/usr/bin/env sh
# Setup user: create jonatha, add to groups.

setup_user() {
    _info "=== User Setup ==="

    local username="$REAL_USER"

    ensure_user "$username" "$username" "/bin/zsh"

    _info "Adding user to groups..."
    ensure_groups audio video input network storage wheel

    user_add_groups "$username" audio video input network storage wheel

    _info "Creating default user directories..."
    xbps_ensure_pkg xdg-user-dirs

    _info "Initializing XDG user directories for $username..."
    _run run_as_user "$username" xdg-user-dirs-update || \
        _warn "Failed to initialize XDG directories"

    _info "Removing xdg-user-dirs package..."
    _run xbps-remove -Ry xdg-user-dirs >/dev/null 2>&1 || \
        _warn "Failed to remove xdg-user-dirs"
}
