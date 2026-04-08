#!/usr/bin/env sh
# Setup repositories: add custom repo, nonfree, multilib.

setup_repository() {
    _info "=== Repository Setup ==="

    _info "Adding custom repository..."
    _run write_file_root /etc/xbps.d/99-j0ng4b-repo.conf 0644 root:root <<'EOF'
    repository=https://j0ng4b.github.io/void-repo/current
EOF

    _info "Updating xbps..."
    xbps_update_self

    _info "Updating system..."
    xbps_update_system

    _info "Installing nonfree and multilib repositories..."
    xbps_ensure_pkgs void-repo-nonfree void-repo-multilib

    _info "Syncing package database..."
    _run xbps-install -Sy >/dev/null 2>&1 || _warn "Failed to sync package database"
}
