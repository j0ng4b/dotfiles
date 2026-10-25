# Usage: awk -f palette.awk <raw palette> <alias file>
# Validates the palette (16 base16 keys, 6-digit hex), applies semantic aliases
# for keys that the palette doesn't define itself, and prints "key hex" lines.

function normalize_hex_color(color_value) {
    color_value = tolower(color_value)
    sub(/^#/, "", color_value)

    return (length(color_value) == 6 && color_value !~ /[^0-9a-f]/) \
        ? color_value : ""
}

function normalize_color_key(color_key) {
    if (color_key ~ /^[Bb][Aa][Ss][Ee][0-9A-Fa-f][0-9A-Fa-f]$/)
        return "base" toupper(substr(color_key, 5))

    return color_key
}

$1 ~ /^#/ || NF < 2 {
    next
}

FILENAME == ARGV[1] {
    normalized_color = normalize_hex_color($2)

    if (normalized_color != "")
        palette[normalize_color_key($1)] = normalized_color

    next
}

# Alias file: "<alias> <existing key>"; keys defined by the palette win.
FILENAME == ARGV[2] {
    alias_name = normalize_color_key($1)
    source_key = normalize_color_key($2)

    if (!(alias_name in palette) && (source_key in palette))
        palette[alias_name] = palette[source_key]
}

END {
    for (color_index = 0; color_index < 16; color_index++) {
        required_base_key = sprintf("base%02X", color_index)

        if (!(required_base_key in palette)) {
            printf "palette is missing %s\n", required_base_key > "/dev/stderr"
            has_missing_colors = 1
        }
    }

    if (has_missing_colors)
        exit 1

    for (color_key in palette)
        print color_key, palette[color_key]
}
