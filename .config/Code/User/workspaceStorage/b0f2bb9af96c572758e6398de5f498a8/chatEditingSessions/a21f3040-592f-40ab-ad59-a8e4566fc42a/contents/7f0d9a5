#!/bin/bash

output_css="$HOME/.config/omarchy/current/theme/hypr-dock.css"
theme_dir="$HOME/.config/hypr-dock/themes/omarchy/"
style_file="$theme_dir/style.css"
theme_conf="$theme_dir/theme.conf"
input_file="$HOME/.config/omarchy/current/theme/colors.toml"

if ! command -v hypr-dock >/dev/null 2>&1; then
  skipped "Hypr Dock"
fi

# Extract color value from colors.toml (flat key=value format)
extract_color() {
    local color_name="$1"
    awk -v color="$color_name" '
        $1 == color && /=/ {
            if (match($0, /#([0-9a-fA-F]{6})/)) {
                print substr($0, RSTART + 1, 6)
                exit
            }
        }
    ' "$input_file"
}

hex2rgb() {
    hex_input=$1
    r=$((16#${hex_input:0:2}))
    g=$((16#${hex_input:2:2}))
    b=$((16#${hex_input:4:2}))
    echo "$r, $g, $b"
}

# Extract colors
primary_background=$(extract_color "background")
bright_black=$(extract_color "color8")
normal_white=$(extract_color "color7")
bright_white=$(extract_color "color15")

rgb_bright_black=$(hex2rgb "$bright_black")

mkdir -p "$theme_dir"

# Generate style.css
mkdir -p "$(dirname "$output_css")"

cat >"$output_css" <<EOF
window {
  background: #$primary_background;
  border: 2px solid #$bright_black;
  border-radius: 12px;
}

button {
  color: #$normal_white;
  padding: 4px;
}

button:hover {
  background: rgba($rgb_bright_black,0.5);
}

icon {
  color: #$bright_white;
}
EOF

# Create theme.conf
cat >"$theme_conf" <<EOF
[theme]
name=omarchy
style=style.css
EOF

cp "$output_css" "$style_file"

success "Hypr Dock theme updated!"

# reload dock
killall hypr-dock 2>/dev/null
hypr-dock &

success "Hypr Dock theme updated!"
