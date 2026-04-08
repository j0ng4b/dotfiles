#!/usr/bin/env sh
# Setup PipeWire: audio server and configuration.

setup_pipewire() {
    _info "=== PipeWire Setup ==="

    xbps_ensure_pkgs pipewire wireplumber libspa-bluetooth

    _info "Creating PipeWire configuration..."
    _run write_file_root /etc/pipewire/pipewire.conf.d/99-custom.conf 0644 root:root <<'EOF'
context.exec = [
    { "path" = "pipewire" "args" = "-c pipewire-pulse.conf" }
    { "path" = "wireplumber" "args" = "" }
]

# See: https://forum.manjaro.org/t/howto-troubleshoot-crackling-in-pipewire/82442
context.properties = {
    "default.clock.quantum" = 1024
    "default.clock.min-quantum" = 1024
    "default.clock.max-quantum" = 8192
    "default.clock.rate" = 48000
    "default.clock.allowed-rates" = [ 44100, 48000, 96000 ]
}
EOF
}
