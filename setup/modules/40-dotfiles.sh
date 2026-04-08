#!/usr/bin/env sh
# Setup dotfiles: clone repository.

setup_dotfiles() {
    _info "=== Dotfiles Setup ==="

    local username="$REAL_USER"
    local home="/home/$username"

    if [ ! -d "$home" ]; then
        _warn "Home directory does not exist: $home"
        return 1
    fi

    git_ensure_clone "$DOTFILES_REPO" "$DOTFILES_DIR" "main"

    _info "Setting dotfiles directory permissions..."
    _run chown -R "$username:$username" "$DOTFILES_DIR"

    _info "Now you can install configurations!"
}
