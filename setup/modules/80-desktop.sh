#!/usr/bin/env sh
# Setup desktop: window manager, quickshell, flatpak applications.

setup_desktop() {
    _info "=== Desktop Setup ==="

    _info "Installing required packages..."
    xbps_ensure_pkgs mesa-dri papirus-icon-theme

    _info "Installing window manager, shell, display manager, terminal..."
    xbps_ensure_pkgs niri mangowc quickshell greetd foot

    _info "Installing libreoffice..."
    xbps_ensure_pkgs libreoffice-calc libreoffice-impress libreoffice-writer libreoffice-i18n-pt-BR

    _info "Installing other useful programs..."
    xbps_ensure_pkgs obs stremio-shell xwayland-satellite

    _info "Installing desktop portals..."
    xbps_ensure_pkgs xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr

    _info "Installing flatpak applications..."

    if ! has_cmd flatpak; then
        _warn "Flatpak not available, skipping applications"
        return 0
    fi

    _run flatpak install -y --noninteractive flathub com.brave.Browser || \
        _warn "Failed to install Brave"

    _run flatpak install -y --noninteractive flathub com.valvesoftware.Steam || \
        _warn "Failed to install Steam"

    _run flatpak install -y --noninteractive flathub com.discordapp.Discord || \
        _warn "Failed to install Discord"

    _run flatpak install -y --noninteractive flathub org.telegram.desktop || \
        _warn "Failed to install Telegram"

    _run flatpak install -y --noninteractive flathub md.obsidian.Obsidian || \
        _warn "Failed to install Obsidian"
}
