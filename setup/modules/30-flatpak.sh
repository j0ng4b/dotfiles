#!/usr/bin/env sh
# Setup flatpak: install and configure.

setup_flatpak() {
    _info "=== Flatpak Setup ==="

    xbps_ensure_pkg flatpak

    _info "Adding flathub repository..."
    _run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || \
    _warn "Flathub repository may already be added"
}
