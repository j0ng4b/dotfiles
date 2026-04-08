#!/usr/bin/env sh
# User and group management helpers.

# Check if user exists
user_exists() {
    local user="$1"
    getent passwd "$user" >/dev/null 2>&1
}

# Check if group exists
group_exists() {
    local group="$1"
    getent group "$group" >/dev/null 2>&1
}

# Create group if not exists
ensure_group() {
    local group="$1"

    if group_exists "$group"; then
        _info "Group already exists: $group"
        return 0
    fi

    _info "Creating group: $group"
    _run groupadd "$group" || _warn "Failed to create group: $group"
}

# Create user if not exists
ensure_user() {
    local user="$1"
    local gecos="${2:-$user}"
    local shell="${3:-/bin/sh}"
    local home="/home/$user"

    if user_exists "$user"; then
        _info "User already exists: $user"
        return 0
    fi

    _info "Creating user: $user"
    _run useradd -m -s "$shell" -c "$gecos" "$user" || _die "Failed to create user: $user"
}

# Add user to group
user_add_group() {
    local user="$1"
    local group="$2"

    if ! user_exists "$user"; then
        _warn "User does not exist: $user"
        return 1
    fi

    if ! group_exists "$group"; then
        _warn "Group does not exist: $group (skipping)"
        return 0
    fi

    if id -nG "$user" 2>/dev/null | grep -qw "$group"; then
        _info "User already in group: $user -> $group"
        return 0
    fi

    _info "Adding user to group: $user -> $group"
    _run usermod -aG "$group" "$user" || _warn "Failed to add user to group: $user -> $group"
}

# Ensure multiple groups exist
ensure_groups() {
    for group in "$@"; do
        ensure_group "$group"
    done
}

# Add user to multiple groups
user_add_groups() {
    local user="$1"
    shift

    for group in "$@"; do
        user_add_group "$user" "$group"
    done
}

# Set user shell
user_set_shell() {
    local user="$1"
    local shell="$2"

    if ! user_exists "$user"; then
        _warn "User does not exist: $user"
        return 1
    fi

    local current_shell
    current_shell=$(getent passwd "$user" | cut -d: -f7)

    if [ "$current_shell" = "$shell" ]; then
        _info "User shell already set: $user -> $shell"
        return 0
    fi

    _info "Setting user shell: $user -> $shell"
    _run usermod -s "$shell" "$user" || _warn "Failed to set user shell: $user -> $shell"
}
