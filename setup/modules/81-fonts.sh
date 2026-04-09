#!/usr/bin/env sh
# Setup fonts: install system fonts and configure fontconfig.
#
# Configuration variables (optional):
#   NERD_FONTS_VERSION    - Version of Nerd Fonts (default: v3.4.0)

NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-v3.4.0}"

setup_fonts() {
    _info "=== Fonts Setup ==="

    _info "Installing minimal font packages..."
    xbps_ensure_pkgs \
        liberation-fonts-ttf \
        noto-fonts-ttf \
        noto-fonts-cjk \
        noto-fonts-emoji

    _info "Installing Nerd Fonts..."
    _install_nerd_font "FiraCode"
    _install_nerd_font "FantasqueSansMono"

    _info "Installing Material Symbols..."
    _install_material_symbols

    _info "Configuring fontconfig..."
    _configure_fontconfig

    _info "Rebuilding fontconfig cache..."
    _run fc-cache --really-force
}

_install_nerd_font() {
    font_name="$1"
    font_dir="/usr/share/fonts/nerd-fonts/$font_name"
    version="$NERD_FONTS_VERSION"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/$version/$font_name.zip"

    if [ -d "$font_dir" ]; then
        _warn "Font $font_name already installed"
        return 0
    fi

    _info "Downloading $font_name ($version)..."
    ensure_dir "$font_dir" 0755 root:root

    temp_zip="/tmp/${font_name}.zip"
    _run curl -fsSL "$download_url" -o "$temp_zip" || {
        _error "Failed to download $font_name"
        rm -f "$temp_zip"
        return 1
    }

    _run unzip -q "$temp_zip" -d "$font_dir" || {
        _error "Failed to extract $font_name"
        rm -f "$temp_zip"
        return 1
    }

    # Clean up unnecessary files (keep only font files)
    _run find "$font_dir" -type f ! \( -name "*.ttf" -o -name "*.otf" \) -delete

    rm -f "$temp_zip"
}

_install_material_symbols() {
    font_dir="/usr/share/fonts/MaterialSymbols"
    github_repo="google/material-design-icons"
    github_ref="master"
    base_url="https://raw.githubusercontent.com/$github_repo/$github_ref/variablefont"

    if [ -d "$font_dir" ]; then
        _warn "Material Symbols already installed"
        return 0
    fi

    _info "Installing Material Symbols from $github_repo..."
    ensure_dir "$font_dir" 0755 root:root

    for style in "Outlined" "Rounded" "Sharp"; do
        font_file="MaterialSymbols${style}%5BFILL,GRAD,opsz,wght%5D.ttf"
        download_url="$base_url/$font_file"
        output_file="$font_dir/MaterialSymbols${style}.ttf"

        _info "Downloading MaterialSymbols${style}..."
        _run curl -fsSL "$download_url" -o "$output_file" || {
            _warn "Failed to download MaterialSymbols${style}, skipping..."
            rm -f "$output_file"
            continue
        }
    done
}

_configure_fontconfig() {
    write_file_root "/etc/fonts/conf.d/75-noto-emoji.conf" "0644" "root:root" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <!-- Adds a generic family 'emoji' -->
  <match target="pattern">
    <test qual="any" name="family">
      <string>emoji</string>
    </test>
    <edit name="family" mode="assign" binding="same">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <!--
    Adds Noto Color Emoji as a final fallback font for the default font families
    to be selected if and only if no other font can provide a given symbol.
  -->
  <match target="pattern">
    <test name="family">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="append">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="family">
      <string>serif</string>
    </test>
    <edit name="family" mode="append">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="family">
      <string>monospace</string>
    </test>
    <edit name="family" mode="append">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <!-- Remove emoji glyphs from other fonts to avoid black-and-white rendering -->
  <match target="scan">
    <test name="family" compare="contains">
      <string>DejaVu</string>
    </test>
    <edit name="charset" mode="assign" binding="same">
      <minus>
        <name>charset</name>
        <charset>
          <!-- Core emoji blocks -->
          <range><int>0x1F300</int><int>0x1F5FF</int></range>
          <range><int>0x1F600</int><int>0x1F64F</int></range>
          <range><int>0x1F900</int><int>0x1F9FF</int></range>

          <!-- Extended -->
          <range><int>0x1FA00</int><int>0x1FAFF</int></range>

          <!-- Symbols -->
          <range><int>0x2600</int><int>0x26FF</int></range>
          <range><int>0x2700</int><int>0x27BF</int></range>

          <!-- Variation selector (forces emoji style) -->
          <int>0xFE0F</int>
        </charset>
      </minus>
    </edit>
  </match>

  <!-- Aliases -->
  <match target="pattern">
    <test qual="any" name="family">
      <string>NotoColorEmoji</string>
    </test>
    <edit name="family" mode="assign">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family">
      <string>Apple Color Emoji</string>
    </test>
    <edit name="family" mode="assign">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family">
      <string>Segoe UI Emoji</string>
    </test>
    <edit name="family" mode="assign">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

</fontconfig>
EOF
}
