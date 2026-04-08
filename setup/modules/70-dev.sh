#!/usr/bin/env sh
# Setup dev: development tools and runtimes.

setup_dev() {
    _info "=== Development Setup ==="

    _info "Installing Python..."
    xbps_ensure_pkgs python3 python3-pip

    _info "Installing Node.js..."
    xbps_ensure_pkgs nodejs

    _info "Installing Docker..."
    xbps_ensure_pkgs docker docker-buildx docker-compose
}
