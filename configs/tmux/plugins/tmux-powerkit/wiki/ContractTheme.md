# Theme Contract

The Theme Contract defines how themes provide color definitions for PowerKit.

## Overview

Themes are responsible for defining colors only. They contain no logic, no functions, and no formatting. The color generator automatically creates lighter/darker variants from base colors.

## Purpose

Centralize color definitions and enable:
- Easy theme switching
- Automatic color variant generation
- Consistent color semantics across plugins

## Responsibilities

Themes MUST:
- Define 22 required base colors
- Use hexadecimal format (#RRGGBB)
- Export `THEME_COLORS` associative array

Themes MUST NOT:
- Contain functions or logic
- Define variants (auto-generated)
- Define icons or formatting
- Override system behavior

## Required Colors (22)

```bash
declare -gA THEME_COLORS=(
    # Status Bar
    [statusbar-bg]="#..."        # Status bar background
    [statusbar-fg]="#..."        # Status bar foreground

    # Session
    [session-bg]="#..."          # Session indicator background
    [session-fg]="#..."          # Session indicator foreground
    [session-prefix-bg]="#..."   # Prefix mode background
    [session-copy-bg]="#..."     # Copy mode background

    # Windows
    [window-active-base]="#..."  # Active window base color
    [window-inactive-base]="#..."# Inactive window base color

    # Pane Borders
    [pane-border-active]="#..."  # Active pane border
    [pane-border-inactive]="#..."# Inactive pane border

    # Health States
    [ok-base]="#..."             # Normal/OK state
    [good-base]="#..."           # Good/success state (green)
    [info-base]="#..."           # Informational state (blue)
    [warning-base]="#..."        # Warning state (yellow)
    [error-base]="#..."          # Error state (red)
    [disabled-base]="#..."       # Disabled state (gray)

    # Messages
    [message-bg]="#..."          # Message background
    [message-fg]="#..."          # Message foreground
)
```

## Optional Colors (8)

These colors are optional but recommended for consistent popup/menu styling:

```bash
    # Popup & Menu (optional - defaults to message colors if not set)
    [popup-bg]="#..."            # Popup background
    [popup-fg]="#..."            # Popup foreground
    [popup-border]="#..."        # Popup border color
    [menu-bg]="#..."             # Menu background
    [menu-fg]="#..."             # Menu foreground
    [menu-selected-bg]="#..."    # Selected item background
    [menu-selected-fg]="#..."    # Selected item foreground
    [menu-border]="#..."         # Menu border color
```

| Color | Suggested Default | Description |
|-------|-------------------|-------------|
| `popup-bg` | Same as `message-bg` | Popup window background |
| `popup-fg` | Same as `message-fg` | Popup text color |
| `popup-border` | Same as `pane-border-active` | Popup border color |
| `menu-bg` | Same as `message-bg` | Menu background |
| `menu-fg` | Same as `message-fg` | Menu text color |
| `menu-selected-bg` | Same as `session-bg` | Selected item background (highlight) |
| `menu-selected-fg` | Same as `session-fg` | Selected item text color |
| `menu-border` | Same as `pane-border-active` | Menu border color |

## Auto-Generated Variants

The color generator creates 6 variants for each base color:

| Variant | Direction | Amount | Purpose |
|---------|-----------|--------|---------|
| `-light` | Toward white | +10% | Subtle lightening |
| `-lighter` | Toward white | +20% | Medium lightening |
| `-lightest` | Toward white | +80% | Strong lightening |
| `-dark` | Toward black | -10% | Subtle darkening |
| `-darker` | Toward black | -20% | Medium darkening |
| `-darkest` | Toward black | -55% | Strong darkening |

### Colors with Auto-Variants

- `window-active-base`, `window-inactive-base`
- `ok-base`, `good-base`, `info-base`, `warning-base`, `error-base`, `disabled-base`

### Usage in Renderer

```bash
# Base color
resolve_color "warning-base"      # #e0af68

# Auto-generated variants
resolve_color "warning-base-lighter"   # Lighter yellow
resolve_color "warning-base-darkest"   # Very dark yellow (for text)
```

## Example Theme

```bash
#!/usr/bin/env bash
# =============================================================================
# Theme: Example
# Variant: Dark
# Description: Example theme for documentation
# =============================================================================

declare -gA THEME_COLORS=(
    # Status Bar
    [statusbar-bg]="#1a1b26"
    [statusbar-fg]="#c0caf5"

    # Session
    [session-bg]="#9ece6a"
    [session-fg]="#1a1b26"
    [session-prefix-bg]="#e0af68"
    [session-copy-bg]="#7dcfff"

    # Windows
    [window-active-base]="#bb9af7"
    [window-inactive-base]="#3b4261"

    # Pane Borders
    [pane-border-active]="#7aa2f7"
    [pane-border-inactive]="#3b4261"

    # Health States
    [ok-base]="#394b70"
    [good-base]="#9ece6a"
    [info-base]="#7dcfff"
    [warning-base]="#e0af68"
    [error-base]="#f7768e"
    [disabled-base]="#565f89"

    # Messages
    [message-bg]="#1a1b26"
    [message-fg]="#c0caf5"

    # Popup & Menu (optional)
    [popup-bg]="#1a1b26"
    [popup-fg]="#c0caf5"
    [popup-border]="#7aa2f7"
    [menu-bg]="#1a1b26"
    [menu-fg]="#c0caf5"
    [menu-selected-bg]="#9ece6a"
    [menu-selected-fg]="#1a1b26"
    [menu-border]="#7aa2f7"
)
```

## Theme Validation

Themes are validated at load time:
- All 22 required colors must be present
- Colors must be valid hex format (#RRGGBB)
- Missing required colors cause theme load failure
- Optional colors (popup/menu) fallback to defaults if not defined

## Related

- [Themes](Themes) - Available themes
- [Developing Themes](DevelopingThemes) - Create themes
- [Architecture](Architecture) - Color resolution flow
