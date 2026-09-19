# Developing Themes

Guide to creating custom PowerKit themes.

## Theme Structure

Create a directory and variant file:

```
src/themes/
└── mytheme/
    ├── dark.sh
    └── light.sh
```

## Required Colors

Every theme must define these 22 colors:

```bash
#!/usr/bin/env bash
# =============================================================================
# Theme: MyTheme
# Variant: Dark
# Description: A custom dark theme
# =============================================================================

declare -gA THEME_COLORS=(
    # Status Bar
    [statusbar-bg]="#1a1b26"      # Main background
    [statusbar-fg]="#c0caf5"      # Main foreground

    # Session Indicator
    [session-bg]="#9ece6a"        # Normal session bg (green)
    [session-fg]="#1a1b26"        # Session text
    [session-prefix-bg]="#e0af68" # Prefix mode (yellow/orange)
    [session-copy-bg]="#7dcfff"   # Copy mode (cyan)

    # Windows
    [window-active-base]="#bb9af7"   # Active window
    [window-inactive-base]="#3b4261" # Inactive windows

    # Pane Borders
    [pane-border-active]="#7aa2f7"   # Active pane
    [pane-border-inactive]="#3b4261" # Inactive panes

    # Health States
    [ok-base]="#394b70"           # Normal state (neutral)
    [good-base]="#9ece6a"         # Success (green)
    [info-base]="#7dcfff"         # Info (cyan)
    [warning-base]="#e0af68"      # Warning (yellow)
    [error-base]="#f7768e"        # Error (red)
    [disabled-base]="#565f89"     # Disabled (gray)

    # Messages
    [message-bg]="#1a1b26"        # Message background
    [message-fg]="#c0caf5"        # Message text
)
```

## Color Guidelines

### Dark Themes

- Background: Dark colors (#1a1b26, #282c34)
- Foreground: Light colors (#c0caf5, #abb2bf)
- Session: Use green for normal, contrasting bg
- Health: Ensure good contrast with dark backgrounds

### Light Themes

- Background: Light colors (#fafafa, #f5f5f5)
- Foreground: Dark colors (#24292f, #3c3836)
- Session: Same colors work, but may need darker variants
- ok-base: Use darker neutral for light themes

## Color Selection Tips

### Session Colors

| Color | Purpose | Typical |
|-------|---------|---------|
| `session-bg` | Normal state | Green |
| `session-prefix-bg` | After prefix | Yellow/Orange |
| `session-copy-bg` | Copy mode | Cyan/Blue |

### Health Colors

| Color | Purpose | Typical |
|-------|---------|---------|
| `ok-base` | Plugin background | Neutral (matches statusbar) |
| `good-base` | Success indicators | Green |
| `info-base` | Informational | Cyan/Blue |
| `warning-base` | Warnings | Yellow/Orange |
| `error-base` | Errors | Red/Pink |
| `disabled-base` | Inactive | Gray |

## Auto-Generated Variants

PowerKit generates 6 variants for each base color:

```
warning-base: #e0af68
├── warning-base-light: slightly lighter
├── warning-base-lighter: medium lighter
├── warning-base-lightest: very light (for dark text)
├── warning-base-dark: slightly darker
├── warning-base-darker: medium darker (for icons)
└── warning-base-darkest: very dark (for light text)
```

## Testing Your Theme

```bash
# Apply theme
set -g @powerkit_theme "mytheme"
set -g @powerkit_theme_variant "dark"

# Validate
./tests/test_contracts.sh

# Check syntax
bash -n src/themes/mytheme/dark.sh
```

## Theme Validation

PowerKit validates themes on load:
- All 22 required colors present
- Valid hex format (#RRGGBB)
- No duplicate color names

## Example: Adapting from Existing

```bash
# Start with existing theme palette
# Nord: https://www.nordtheme.com/docs/colors-and-palettes

declare -gA THEME_COLORS=(
    # Map Nord colors to PowerKit semantics
    [statusbar-bg]="#3b4252"     # nord1
    [statusbar-fg]="#eceff4"     # nord6
    [session-bg]="#a3be8c"       # nord14 (green)
    [session-fg]="#2e3440"       # nord0
    [session-prefix-bg]="#ebcb8b" # nord13 (yellow)
    [session-copy-bg]="#81a1c1"  # nord9 (blue)
    # ... continue mapping
)
```

## Publishing Your Theme

1. Create PR to PowerKit repository
2. Include theme in `src/themes/yourtheme/`
3. Add to theme list in documentation
4. Provide preview screenshot

## Related

- [Theme Contract](ContractTheme) - Contract specification
- [Themes](Themes) - Available themes
- [Architecture](Architecture) - Color resolution
