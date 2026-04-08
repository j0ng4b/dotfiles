#!/usr/bin/env sh
# Execution helpers: run commands, run as user, etc.

# Run command as specific user
run_as_user() {
    local user="$1"
    shift

    if ! user_exists "$user"; then
        _die "User does not exist: $user"
    fi

    if [ "$DRY_RUN" = "true" ]; then
        _info "[dry-run] sudo -u $user $*"
        return 0
    fi

    _info "Running as $user: $*"
    sudo -u "$user" "$@" || _die "Failed to run as $user: $*"
}

# Run command or fail silently (for optional installs)
run_ignore_fail() {
    _dry "$@" && return 0
    "$@" || true
}

# Git clone or pull
git_ensure_clone() {
    local repo="$1"
    local dir="$2"
    local branch="${3:-main}"

    if [ -d "$dir/.git" ]; then
        _info "Git repo already cloned: $dir"

        _info "Pulling updates..."
        _run git -C "$dir" pull --rebase origin "$branch" >/dev/null 2>&1 || \

        _warn "Failed to pull updates in $dir"
        return 0
    fi

    _info "Cloning repository: $repo"
    _run git clone --recurse-submodules --shallow-submodules -b "$branch" "$repo" "$dir" || \
        _die "Failed to clone: $repo"
}

# Check if command output contains string
cmd_contains() {
    local needle="$1"
    shift

    "$@" 2>/dev/null | grep -q "$needle"
}
