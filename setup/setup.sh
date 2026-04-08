#!/usr/bin/env sh
# Dotfiles bootstrap entrypoint (modular).
# Loads lib/ and modules/, then orchestrates setup in order.

set -eu

##
## CONFIG
##

DRY_RUN=false
REAL_USER="${SUDO_USER:-${USER:-}}"
VERBOSE=false

# Setup plan (order matters)
SETUP_PLAN="repository user base flatpak dotfiles shell pipewire dev desktop services integrations"

# Feature flags (--skip <feature> to disable)
SKIP_REPOSITORY=false
SKIP_USER=false
SKIP_BASE=false
SKIP_FLATPAK=false
SKIP_DOTFILES=false
SKIP_SHELL=false
SKIP_PIPEWIRE=false
SKIP_DEV=false
SKIP_DESKTOP=false
SKIP_SERVICES=false
SKIP_INTEGRATIONS=false

# Defaults
DOTFILES_REPO="https://github.com/j0ng4b/dotfiles.git"
DOTFILES_DIR="/home/${REAL_USER}/.dotfiles"

# Internal
_SHOULD_RUN_MAIN=true

##
## LOAD LIBS & MODULES
##

_load_files() {
    local dir="$1"
    local pattern="$2"

    for file in "$dir"/$pattern; do
        [ -f "$file" ] || continue
        . "$file" || _die "Failed to source: $file"
    done
}

SETUP_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

_load_files "$SETUP_ROOT/lib" "*.sh"
_load_files "$SETUP_ROOT/modules" "*.sh"

##
## MAIN LOGIC
##

_show_usage() {
    cat <<EOF
    Dotfiles Bootstrap Setup

    Usage: sudo $0 [options]

    Options:
    -n, --dry-run              Simulate without executing
    -v, --verbose              Verbose output
    --user <name>              Username to setup (default: $REAL_USER or jonatha)
    --only <module>            Run only specified module
    --skip <module[,...]>      Skip modules (comma-separated)
    --list                     List modules in execution order
    --dotfiles-repo <url>      Override dotfiles repository URL
    --dotfiles-dir <path>      Override dotfiles clone directory
    -h, --help                 Show this help

    Examples:
    sudo $0
    sudo $0 --dry-run
    sudo $0 --skip desktop,flatpak
    sudo $0 --only shell
    sudo $0 --list

EOF
}

_list_modules() {
    _info "Setup modules (in order):"
    for module in $SETUP_PLAN; do
        echo "  - $module"
    done
}

_parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;

            -v|--verbose)
                VERBOSE=true
                shift
                ;;

            --user)
                [ -z "${2:-}" ] && _die "--user requires an argument"
                REAL_USER="$2"
                shift 2
                ;;

            --only)
                [ -z "${2:-}" ] && _die "--only requires an argument"
                SETUP_PLAN="$2"
                shift 2
                ;;

            --skip)
                [ -z "${2:-}" ] && _die "--skip requires an argument"
                local skip_list="$2"

                # Convert comma-separated to space-separated for easier handling
                skip_list=$(echo "$skip_list" | sed 's/,/ /g')
                for skip_module in $skip_list; do
                    eval "SKIP_$(echo "$skip_module" | tr '[:lower:]' '[:upper:]')=true"
                done

                shift 2
                ;;

            --list)
                _list_modules
                _SHOULD_RUN_MAIN=false
                return 0
                ;;

            --dotfiles-repo)
                [ -z "${2:-}" ] && _die "--dotfiles-repo requires an argument"
                DOTFILES_REPO="$2"
                shift 2
                ;;

            --dotfiles-dir)
                [ -z "${2:-}" ] && _die "--dotfiles-dir requires an argument"
                DOTFILES_DIR="$2"
                shift 2
                ;;

            -h|--help)
                _show_usage
                _SHOULD_RUN_MAIN=false
                return 0
                ;;

            *)
                _error "Unknown option: $1"
                _show_usage
                return 1
                ;;
        esac
    done
}

_run_module() {
    local module="$1"
    local skip_var="SKIP_$(echo "$module" | tr '[:lower:]' '[:upper:]')"
    local skip_value
    skip_value=$(eval "echo \$$skip_var")

    if [ "$skip_value" = "true" ]; then
        _warn "Skipping module: $module"
        return 0
    fi

    local func="setup_$module"

    if ! type "$func" >/dev/null 2>&1; then
        _warn "Module not found: $module (function: $func)"
        return 1
    fi

    _info "=== Running: $module ==="
    "$func" || {
        local exit_code=$?
        _error "Module failed: $module (exit: $exit_code)"
        return $exit_code
    }
    _info "=== Completed: $module ==="
    echo ""
}

_main() {
    require_root

    _info "Dotfiles Bootstrap Setup"
    _info "Build SHA: ${SETUP_BUILD_SHA:-unknown}"
    _info "OS: Void Linux (Runit)"
    _info "Real user: $REAL_USER"
    _info "Dry-run: $DRY_RUN"
    echo ""

    if [ -z "$REAL_USER" ]; then
        REAL_USER="jonatha"
        _info "Real user not detected, using default: $REAL_USER"
    fi

    if [ "$DRY_RUN" = "true" ]; then
        _warn "DRY-RUN MODE: No changes will be made"
        echo ""
    fi

    for module in $SETUP_PLAN; do
        _run_module "$module" || {
            local exit_code=$?
            _error "Setup failed at module: $module"
            return $exit_code
        }
    done

    _info "=== Setup completed successfully! ==="
    if [ "$DRY_RUN" = "false" ]; then
        _warn "Please review changes and reboot if needed."
    fi
}

##
## ENTRY POINT
##

_parse_args "$@" || return $?

if [ "$_SHOULD_RUN_MAIN" = "true" ]; then
    _main
fi
