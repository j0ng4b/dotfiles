#!/usr/bin/env sh
# Setup base packages: essentials for development and daily use.

setup_base() {
    _info "=== Base Packages Setup ==="

    xbps_ensure_pkgs \
        git \
        curl \
        neovim \
        tmux \
        btop \
        fzf \
        unzip
}
