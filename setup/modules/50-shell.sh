#!/usr/bin/env sh
# Setup shell: zsh + starship configuration.

setup_shell() {
    _info "=== Shell Setup ==="

    local username="jonatha"

    xbps_ensure_pkgs zsh starship

    _info "Setting shell to zsh for $username..."
    user_set_shell "$username" "/bin/zsh"

    _info "Installing dotfiles configuration (shell)..."
    if [ -x "$DOTFILES_DIR/dotfile" ]; then
        _run run_as_user "$username" "$DOTFILES_DIR/dotfile" install zsh starship || \
        _warn "Failed to run dotfile install for shell"
    else
        _warn "Dotfile script not found: $DOTFILES_DIR/dotfile"
    fi
}
