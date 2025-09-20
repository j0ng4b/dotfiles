#!/usr/bin/env sh

## Load common functions
. ./scripts/_common

real_user=${SUDO_USER:-$USER}

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
        ln -s "/etc/sv/$svc" "/var/service/$svc"
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
        rm -f "/var/service/$svc"
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
    echo 'repository=https://j0ng4b.github.io/void-repo/current' > /etc/xbps.d/99-j0ng4b-repo.conf

    info 'Updating xbps...'
    xbps-install -Syu xbps

    info 'Updating system...'
    xbps-install -Syu

    info 'Installing others repositories...'
    xbps-install -Sy void-repo-nonfree void-repo-multilib

    info 'Installing base packages...'
    xbps-install -Sy j0ng4b-base

    info 'Installing development packages...'
    xbps-install -Sy j0ng4b-dev

    info 'Installing office packages...'
    xbps-install -Sy \
        libreoffice-calc \
        libreoffice-gnome \
        libreoffice-i18n-pt-BR \
        libreoffice-impress \
        libreoffice-writer

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

    info 'Adding user to necessary groups...'
    usermod -aG _seatd $real_user
    usermod -aG bluetooth $real_user
    usermod -aG docker $real_user

    warn '=== Please reboot the system ==='
}


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

