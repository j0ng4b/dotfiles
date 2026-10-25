# Usage: awk -v palette_file=<palette file> -f render.awk <template>
# Replaces {key}, {key:#} and {key:rgb} placeholders with palette values.

function hex_to_decimal(hex_value,   char_index, decimal_value) {
    decimal_value = 0

    for (char_index = 1; char_index <= length(hex_value); char_index++)
        decimal_value = decimal_value * 16 + index("0123456789abcdef", substr(hex_value, char_index, 1)) - 1

    return decimal_value
}

function format_color(color_value, format_type) {
    if (format_type == "")
        return color_value

    if (format_type == "#")
        return "#" color_value

    if (format_type == "rgb")
        return hex_to_decimal(substr(color_value, 1, 2)) "," \
               hex_to_decimal(substr(color_value, 3, 2)) "," \
               hex_to_decimal(substr(color_value, 5, 2))

    return ""
}

BEGIN {
    while ((getline palette_line < palette_file) > 0) {
        split(palette_line, palette_fields, " ")
        colors[palette_fields[1]] = palette_fields[2]
    }

    close(palette_file)
}

{
    remaining_text = $0
    output_text = ""

    while (match(remaining_text, /\{[A-Za-z0-9_]+(:(#|rgb))?\}/)) {
        placeholder = substr(remaining_text, RSTART + 1, RLENGTH - 2)

        output_text = output_text substr(remaining_text, 1, RSTART - 1)
        remaining_text = substr(remaining_text, RSTART + RLENGTH)

        split(placeholder, placeholder_parts, ":")

        color_name = placeholder_parts[1]
        format_type = placeholder_parts[2]

        if ((color_name in colors) &&
            (formatted_color = format_color(colors[color_name], format_type)) != "") {
            output_text = output_text formatted_color
        } else {
            output_text = output_text "{" placeholder "}"
            unknown_placeholders[placeholder] = 1
        }
    }

    print output_text remaining_text
}

END {
    for (placeholder in unknown_placeholders)
        printf "color-reloader: unknown placeholder {%s}\n", placeholder > "/dev/stderr"
}
