#!/usr/bin/env sh

## Load common functions
. ./scripts/_common


setup_void() {
    info '=== Setup Void Linux ==='
    info 'Installing my own custom repository...'
    echo 'repository=https://j0ng4b.github.io/void-repo/current' >> /etc/xbps.d/99-j0ng4b-repo.conf

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
        libreoffice-writer \
        libspa-bluetooth

    info 'Install steam...'
    echo 'TODO: Install steam...'

    info 'Enable user to run zzz...'
    echo '# Enable user to run zzz...' >> /etc/rc.local
    echo "chown $USER /sys/power/state" >> /etc/rc.local

    info 'Disable wpa_supplicant and enable iwd...'
    rm -f /var/service/wpa_supplicant
    ln -s /etc/sv/iwd /var/service/

    info 'Enable seat service and management...'
    ln -s /etc/sv/seatd /var/service/
    usermod -aG _seatd $USER

    info 'Enable bluetooth service and management...'
    ln -s /etc/sv/bluetoothd /var/service/
    usermod -aG bluetooth $USER

    info 'Enable docker service and management...'
    ln -s /etc/sv/docker /var/service/
    usermod -aG docker $USER

    info 'Enable other services...'
    ln -s /etc/sv/dbus /var/service/
    ln -s /etc/sv/tlp /var/service/

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

