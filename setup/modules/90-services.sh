#!/usr/bin/env sh
# Setup services: enable/disable system services.

setup_services() {
    _info "=== Services Setup ==="

    _info "Installing service packages..."
    xbps_ensure_pkgs dbus iwd seatd bluez tlp polkit

    _info "Disabling conflicting services..."
    runit_svc_disable wpa_supplicant || true

    _info "Enabling services..."
    runit_svc_enable_start dbus || true
    runit_svc_enable_start iwd || true
    runit_svc_enable_start dhcpcd || true
    runit_svc_enable_start seatd || true
    runit_svc_enable_start bluetoothd || true
    runit_svc_enable_start polkitd || true
    runit_svc_enable_start tlp || true

    _info "Enabling user suspend (zzz)..."
    if ! grep -q "chown $REAL_USER /sys/power/state" /etc/rc.local 2>/dev/null; then
        _run sh -c "echo '# Enable user to run zzz' >> /etc/rc.local"
        _run sh -c "echo 'chown $REAL_USER /sys/power/state' >> /etc/rc.local"
    else
        _info "User suspend already configured in /etc/rc.local"
    fi
}
