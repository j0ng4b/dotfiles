#!/usr/bin/env sh
# Common helpers: logging, dry-run, error handling.

# Logging functions
_info()  { printf '\033[32m[Info]\033[0m %s\n'    "$*"; }
_warn()  { printf '\033[33m[Warning]\033[0m %s\n' "$*" >&2; }
_error() { printf '\033[31m[Error]\033[0m %s\n'   "$*" >&2; }
_die()   { _error "$*"; exit 1; }

# Dry-run helper
_dry() {
    if [ "$DRY_RUN" = "true" ]; then
        _info "[dry-run] $*"
        return 0
    fi
    return 1
}

# Dry-run or execute
_run() {
    _dry "$@" && return 0
    "$@"
}

# Check if command exists
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Require root
require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        _die "This script must run as root. Use: sudo $0"
    fi
}

# Get real user (when run via sudo)
get_real_user() {
    echo "${SUDO_USER:-${USER:-nobody}}"
}

# Require command
require_cmd() {
    local cmd="$1"
    local msg="${2:-}"

    if ! has_cmd "$cmd"; then
        if [ -n "$msg" ]; then
            _die "Required command not found: $cmd ($msg)"
        else
            _die "Required command not found: $cmd"
        fi
    fi
}
