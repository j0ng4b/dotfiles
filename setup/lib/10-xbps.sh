#!/usr/bin/env sh
# XBPS package manager helpers (Void Linux only).

# Update XBPS itself
xbps_update_self() {
    _info "Updating xbps..."
    _run xbps-install -Syu xbps >/dev/null 2>&1 || _die "Failed to update xbps"
}

# Update system
xbps_update_system() {
    _info "Updating system packages..."
    _run xbps-install -Syu >/dev/null 2>&1 || _die "Failed to update system"
}

# Install one or more packages
xbps_install() {
    [ $# -eq 0 ] && return 0

    _info "Installing: $*"
    _run xbps-install -Sy "$@" >/dev/null 2>&1 || _die "Failed to install: $*"
}

# Check if package is installed
xbps_pkg_installed() {
    xbps-query -S "$1" >/dev/null 2>&1
}

# Install if not already installed
xbps_ensure_pkg() {
    local pkg="$1"

    if xbps_pkg_installed "$pkg"; then
        _info "Package already installed: $pkg"
        return 0
    fi

    xbps_install "$pkg"
}

# Install multiple packages, skipping already installed
xbps_ensure_pkgs() {
    local to_install=""

    for pkg in "$@"; do
        if xbps_pkg_installed "$pkg"; then
            _info "Package already installed: $pkg"
        else
            to_install="$to_install $pkg"
        fi
    done

    to_install=$(echo "$to_install" | sed 's/^ *//;s/ *$//')
    [ -z "$to_install" ] && return 0

    xbps_install $to_install
}
