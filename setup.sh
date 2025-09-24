#!/usr/bin/env sh

## Load common functions
. ./scripts/_common

real_user=${SUDO_USER:-$USER}
dry_run=false

## Helpers
enable_service() {
    local svc="$1"
    if [ -z "$svc" ]; then
        error "enable_service: missing service name"
        return 1
    fi
    if [ ! -d "/etc/sv/$svc" ]; then
        error "Service $svc not found in /etc/sv"
        return 1
    fi
    if [ -L "/var/service/$svc" ]; then
        warn "Service $svc already enabled"
    else
        [ "$dry_run" = "true" ] || ln -s "/etc/sv/$svc" "/var/service/$svc"
        info "Service $svc enabled"
    fi
}

disable_service() {
    local svc="$1"
    if [ -z "$svc" ]; then
        error "disable_service: missing service name"
        return 1
    fi
    if [ -L "/var/service/$svc" ]; then
        [ "$dry_run" = "true" ] || rm -f "/var/service/$svc"
        info "Service $svc disabled"
    else
        warn "Service $svc already disabled"
    fi
}



setup_pipewire() {
    info '=== Setup Pipewire ==='

    info 'Creating pipewire configuration directory...'
    mkdir -p /etc/pipewire/pipewire.conf.d

    info 'Creating custom pipewire configuration file...'

    [ "$dry_run" = "true" ] || return 0
    cat <<EOF > /etc/pipewire/pipewire.conf.d/99-custom.conf
context.exec = [
    # Start pipewire-pulse
    {
        "path" = "pipewire"
        "args" = "-c pipewire-pulse.conf"
    }

    # Start wireplumber
    {
        "path" = "wireplumber"
        "args" = ""
    }
]

# See: https://forum.manjaro.org/t/howto-troubleshoot-crackling-in-pipewire/82442
context.properties = {
    # Default quantum size
    "default.clock.quantum" = 1024

    # Minimum quantum size
    "default.clock.min-quantum" = 1024

    # Maximum quantum size
    "default.clock.max-quantum" = 8192

    # Clock rate in Hz
    "default.clock.rate" = 48000

    # List of allowed sample rates
    "default.clock.allowed-rates" = [ 44100, 48000, 96000 ]
}
EOF
}

setup_void() {
    info '=== Setup Void Linux ==='
    info 'Installing my own custom repository...'
    [ "$dry_run" = "true" ] || \
        echo 'repository=https://j0ng4b.github.io/void-repo/current' > /etc/xbps.d/99-j0ng4b-repo.conf

    info 'Updating xbps...'
    [ "$dry_run" = "true" ] || xbps-install -Syu xbps >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to update xbps' && exit 1

    info 'Updating system...'
    [ "$dry_run" = "true" ] || xbps-install -Syu >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to update system' && exit 1

    info 'Installing others repositories...'
    [ "$dry_run" = "true" ] || xbps-install -Sy void-repo-nonfree void-repo-multilib >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to add others repositories' && exit 1

    info 'Installing base packages...'
    [ "$dry_run" = "true" ] || xbps-install -Sy j0ng4b-base >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to install base packages' && exit 1

    info 'Installing development packages...'
    [ "$dry_run" = "true" ] || xbps-install -Sy j0ng4b-dev >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to install development packages' && exit 1

    info 'Installing office packages...'
    [ "$dry_run" = "true" ] || xbps-install -Sy \
        libreoffice-calc \
        libreoffice-gnome \
        libreoffice-i18n-pt-BR \
        libreoffice-impress \
        libreoffice-writer >/dev/null 2>&1
    [ $? -ne 0 ] && error 'Failed to install office packages' && exit 1

    info 'Install steam...'
    echo 'TODO: Install steam...'

    setup_pipewire

    info 'Enable user to run zzz...'
    echo '# Enable user to run zzz...' >> /etc/rc.local
    echo "chown $real_user /sys/power/state" >> /etc/rc.local

    info 'Disabling services...'
    disable_service wpa_supplicant
    disable_service dhcpcd

    info 'Enabling services...'
    enable_service dbus
    enable_service NetworkManager
    enable_service seatd
    enable_service bluetoothd
    enable_service docker
    enable_service tlp

    for grp in bluetooth docker network _seatd; do
        if id -nG "$real_user" | grep -qw "$grp"; then
            warn "User $real_user already in $grp group"
        else
            info "Adding user $real_user to $grp group"
            [ "$dry_run" = "true" ] || usermod -aG $grp $real_user
        fi
    done

    warn '=== Please reboot the system ==='
}

## Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run | -n)
            dry_run=true
            shift
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

## Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error 'This script must be run as root. Please use sudo.'
    exit 1
fi

## Detect operating system
os=$(cat /etc/os-release | grep -w NAME | cut -d '=' -f2 | tr -d '"')
if [ "$os" = "Void" ]; then
    setup_void
else
    error "Unsupported OS: $os"
    exit 1
fi

