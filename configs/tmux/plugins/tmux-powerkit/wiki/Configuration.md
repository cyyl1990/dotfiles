# Configuration

Complete reference for all PowerKit configuration options.

## Reference Configuration File

A complete configuration file with **all available options** and their default values is maintained at:

```
wiki/assets/powerkit-options.conf
```

**Direct link:** [`powerkit-options.conf`](assets/powerkit-options.conf)

This file is organized into sections and fully documented with descriptions, valid values, and examples. Use it as a reference or copy the options you need to your `~/.tmux.conf`.

**Real-world example:** See the [author's tmux.conf](https://github.com/fabioluciano/dot/blob/main/private_dot_config/tmux/tmux.conf) for an advanced configuration used in daily development.

## Table of Contents

- [Global Options](#global-options)
  - [Plugin Selection](#plugin-selection)
  - [External Plugins](#external-plugins)
  - [Plugin Groups](#plugin-groups)
  - [Theme Configuration](#theme-configuration)
  - [Status Bar](#status-bar)
  - [Separators](#separators)
  - [Keybindings](#keybindings)
  - [Cache Management](#cache-management)
  - [Advanced Options](#advanced-options)
- [Session Options](#session-options)
- [Window Options](#window-options)
- [Pane Options](#pane-options)
- [Popup & Menu Options](#popup--menu-options)
- [Environment Variables](#environment-variables)

---

# Global Options

These options affect the overall PowerKit behavior and appearance.

---

## Plugin Selection

```bash
# Comma-separated list of plugins to enable
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname,git"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugins` | string | `"datetime,battery,cpu,memory,hostname,git"` | Comma-separated list of plugins to display |

See [available plugins](Home#available-plugins) for the complete list.

## External Plugins

You can add custom content to the status bar using external plugins. External plugins allow you to display output from shell commands with custom icons and colors.

```bash
# Format: external("icon"|"content"|"accent"|"accent_icon"|"ttl")
set -g @powerkit_plugins "cpu,memory,external(\"󰊠\"|\"$(uptime -p)\"|\"info-base\"|\"info-base-lighter\"|\"60\")"
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `icon` | Icon to display | `"󰊠"`, `""` |
| `content` | Text or command | `"Static text"`, `"$(hostname)"`, `"#(date +%H:%M)"` |
| `accent` | Content background color | `"info-base"`, `"ok-base"`, `"#7aa2f7"` |
| `accent_icon` | Icon background color | `"info-base-lighter"`, `"ok-base-lighter"` |
| `ttl` | Cache duration in seconds | `"60"`, `"300"` |

### Content Types

- **Static text**: `"Hello World"` - displays as-is
- **Command substitution**: `"$(command)"` - executed and cached
- **tmux format**: `"#(command)"` - executed by tmux (converted internally)

### Examples

```bash
# Show current user
external(""|"$(whoami)"|"ok-base"|"ok-base-lighter"|"3600")

# Show uptime
external("󰔟"|"$(uptime -p | sed 's/up //')"|"info-base"|"info-base-lighter"|"60")

# Show custom message
external("󰍡"|"Custom Status"|"window-active-base"|"window-active-base-lighter"|"0")

# Show git branch (if not using git plugin)
external(""|"$(git branch --show-current 2>/dev/null || echo 'N/A')"|"warning-base"|"warning-base-lighter"|"30")
```

### Color Options

You can use any theme color or hex value:

- Theme colors: `ok-base`, `info-base`, `warning-base`, `error-base`, `window-active-base`
- Color variants: `ok-base-lighter`, `info-base-darker`, etc.
- Hex colors: `"#7aa2f7"`, `"#bb9af7"`

---

## Plugin Groups

You can visually group related plugins together using the `group(...)` syntax. Plugins in the same group share a colored background, creating a visual separation between different categories.

```bash
# Group related plugins together
set -g @powerkit_plugins "group(cpu,memory,loadavg),group(git,github),datetime,battery"
```

### How Groups Work

- Plugins inside `group(...)` are rendered with a shared background color
- Each group gets a different color from the group color palette
- Groups create visual boundaries between plugin categories
- Ungrouped plugins display with the default status bar background

### Examples

```bash
# Group system metrics and development plugins
set -g @powerkit_plugins "group(cpu,memory,disk),group(git,github,gitlab),datetime"

# Group network and media plugins
set -g @powerkit_plugins "datetime,group(wifi,vpn,ping),group(nowplaying,volume),battery"

# Mix grouped and ungrouped plugins
set -g @powerkit_plugins "group(cpu,memory),git,datetime,group(wifi,vpn)"
```

### Visual Result

```
┌─────────────────┐ ┌─────────────────┐ ┌──────────┐
│  CPU 45%  MEM 62% │ │  main  +3  │ │ 14:32 │
│   (blue group)    │ │ (purple group) │ │ (default)│
└─────────────────┘ └─────────────────┘ └──────────┘
```

### Group Color Palette

Groups are assigned colors in order from the `@powerkit_plugin_group_colors` palette.

```bash
# Default palette (theme colors)
set -g @powerkit_plugin_group_colors "info-base-darker,window-active-base-darker,ok-base-darker,warning-base-darker,error-base-darker,disabled-base"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_group_colors` | string | `"info-base-darker,window-active-base-darker,..."` | Comma-separated list of colors for groups |

**Color assignment:**
- Group 1: `info-base-darker` (blue tones)
- Group 2: `window-active-base-darker` (purple tones)
- Group 3: `ok-base-darker` (green tones)
- Group 4: `warning-base-darker` (yellow tones)
- Group 5: `error-base-darker` (red tones)
- Group 6: `disabled-base` (gray tones)
- Groups 7+: cycles back to the beginning of the palette

### Custom Group Colors

You can customize the group color palette using theme colors or hex values:

```bash
# Use custom colors
set -g @powerkit_plugin_group_colors "#1e3a5f,#3d2b5a,#2d4a3e"

# Mix theme colors and hex values
set -g @powerkit_plugin_group_colors "window-active-base-darker,#2d4a3e,warning-base-darker"
```

---

## Theme Configuration

```bash
set -g @powerkit_theme "catppuccin"
set -g @powerkit_theme_variant "mocha"
set -g @powerkit_transparent "false"
set -g @powerkit_custom_theme_path ""
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_theme` | string | `"catppuccin"` | Theme name |
| `@powerkit_theme_variant` | string | `"mocha"` | Theme variant (depends on theme) |
| `@powerkit_transparent` | bool | `"false"` | Use transparent backgrounds |
| `@powerkit_custom_theme_path` | path | `""` | Path to custom theme file |

### Available Themes (32 themes, 56 variants)

| Theme | Variants |
|-------|----------|
| `atom` | `dark` |
| `ayu` | `dark`, `mirage`, `light` |
| `catppuccin` | `mocha`, `macchiato`, `frappe`, `latte` |
| `cobalt2` | `default` |
| `darcula` | `default` |
| `dracula` | `dark` |
| `everforest` | `dark`, `light` |
| `flexoki` | `dark`, `light` |
| `github` | `dark`, `light` |
| `gruvbox` | `dark`, `light` |
| `horizon` | `default` |
| `iceberg` | `dark`, `light` |
| `kanagawa` | `dragon`, `lotus` |
| `kiribyte` | `dark`, `light` |
| `material` | `default`, `ocean`, `palenight`, `lighter` |
| `molokai` | `dark` |
| `monokai` | `dark`, `light` |
| `moonlight` | `default` |
| `night-owl` | `default`, `light` |
| `nord` | `dark` |
| `oceanic-next` | `default`, `darker` |
| `onedark` | `dark` |
| `pastel` | `dark`, `light` |
| `poimandres` | `default` |
| `rose-pine` | `main`, `moon`, `dawn` |
| `slack` | `dark` |
| `snazzy` | `default` |
| `solarized` | `dark`, `light` |
| `spacegray` | `dark` |
| `synthwave` | `84` |
| `tokyo-night` | `night`, `storm`, `day` |
| `vesper` | `default` |

See [Themes](Themes) for detailed theme documentation.

---

## Status Bar

```bash
set -g @powerkit_status_interval "5"
set -g @powerkit_status_position "top"
set -g @powerkit_status_justify "left"
set -g @powerkit_bar_layout "single"
set -g @powerkit_status_order "session,plugins"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_status_interval` | number | `"5"` | Status bar refresh interval (seconds) |
| `@powerkit_status_position` | enum | `"top"` | Status bar position: `top`, `bottom` |
| `@powerkit_status_justify` | enum | `"left"` | Window list alignment: `left`, `centre`, `right` |
| `@powerkit_bar_layout` | enum | `"single"` | Status bar layout: `single`, `double` |
| `@powerkit_status_order` | string | `"session,plugins"` | Element order in status bar |

### Bar Layout

| Value | Description |
|-------|-------------|
| `single` | Traditional single status line with session, windows, and plugins |
| `double` | Two status lines: Line 0 = Session + Windows, Line 1 = Plugins |

### Status Order

Controls the order and layout of elements in the status bar.

**2-element orders** (auto-expanded with windows):

| Value | Description |
|-------|-------------|
| `session,plugins` | Session+windows on left, plugins on right (default) |
| `plugins,session` | Plugins on left, windows+session on right |

**3-element orders** enable **CENTERED layout**:

| Value | Description |
|-------|-------------|
| `session,windows,plugins` | Session LEFT, windows CENTER, plugins RIGHT |
| `plugins,windows,session` | Plugins LEFT, windows CENTER, session RIGHT |
| `session,plugins,windows` | Session LEFT, plugins CENTER, windows RIGHT |

Any element in the middle position will be automatically centered in the status bar

---

## Separators

```bash
set -g @powerkit_separator_style "normal"
set -g @powerkit_edge_separator_style "rounded:all"
set -g @powerkit_initial_separator_style ""
set -g @powerkit_elements_spacing "false"
set -g @powerkit_icon_padding "1"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_separator_style` | enum | `"normal"` | Main separator style |
| `@powerkit_edge_separator_style` | string | `"rounded:all"` | Edge separator style (with optional `:all` suffix) |
| `@powerkit_initial_separator_style` | enum | `""` | Initial separator style (empty = use edge style) |
| `@powerkit_elements_spacing` | enum | `"false"` | Add gaps between elements |
| `@powerkit_icon_padding` | number | `"1"` | Padding around plugin icons (1-3) |

### Separator Styles

| Style | Right Glyph | Left Glyph | Description |
|-------|-------------|------------|-------------|
| `normal` | `` | `` | Solid powerline arrows |
| `rounded` | `` | `` | Rounded powerline |
| `slant` | `` | `` | Slanted diagonal |
| `slantup` | `` | `` | Upward slant |
| `trapezoid` | `` | `` | Trapezoid shape |
| `flame` | `` | `` | Flame/fire style |
| `pixel` | `` | `` | Pixelated blocks |
| `honeycomb` | `` | `` | Hexagonal pattern |
| `none` | (none) | (none) | No separators |

### Edge Separator Style

The `@powerkit_edge_separator_style` option controls the separator style for external edges (start/end of status bar sections). It supports an optional `:all` suffix.

**Format:** `style` or `style:all`

| Value | Standard Edges | All External Edges |
|-------|----------------|-------------------|
| `"same"` | ❌ | ❌ |
| `"rounded"` | ✅ | ❌ |
| `"rounded:all"` | ✅ | ✅ |
| `"flame:all"` | ✅ | ✅ |

**Standard edge points:**
- Session entry/exit
- First/last window boundaries

**All external edges** (with `:all` suffix):
- All of the above, plus
- Session start (leftmost edge)
- Windows start/end (where they meet other elements)
- Plugins start/end (where they meet other elements)

**Examples:**

```bash
# Use rounded separators at standard edge points only
set -g @powerkit_edge_separator_style "rounded"

# Use rounded separators at ALL external edges
set -g @powerkit_edge_separator_style "rounded:all"

# Use flame separators at ALL external edges
set -g @powerkit_edge_separator_style "flame:all"

# Use the same style as @powerkit_separator_style
set -g @powerkit_edge_separator_style "same"
```

### Elements Spacing

| Value | Description |
|-------|-------------|
| `"false"` | No spacing (connected segments) |
| `"true"` | Spacing everywhere |
| `"both"` | Same as `true` |
| `"windows"` | Spacing only between windows |
| `"plugins"` | Spacing only between plugins |

### Icon Padding

```bash
set -g @powerkit_icon_padding "1"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_icon_padding` | number | `"1"` | Padding around plugin icons (1-3) |

Controls spacing around plugin icons to normalize visual appearance for icons with different widths. PowerKit uses dynamic padding based on icon width detection:

- **1-wide icons** (ASCII, Powerline separators): get more padding
- **2-wide icons** (Nerd Font icons, emoji): get less padding

This ensures icons appear consistently spaced regardless of their actual character width.

| Value | Description |
|-------|-------------|
| `1` | Minimal padding (1 space each side) - compact look |
| `2` | Standard padding (2 spaces each side) - balanced spacing |
| `3` | Wide padding (3 spaces each side) - generous spacing |

**Tip:** If icons appear inconsistently spaced in your terminal, try increasing this value.

---

## Keybindings

### Helper Keybindings

```bash
set -g @powerkit_show_options_key "C-e"
set -g @powerkit_show_options_width "80%"
set -g @powerkit_show_options_height "80%"

set -g @powerkit_show_keybindings_key "C-y"
set -g @powerkit_show_keybindings_width "80%"
set -g @powerkit_show_keybindings_height "80%"

set -g @powerkit_theme_selector_key "C-r"

set -g @powerkit_cache_clear_key "M-x"

set -g @powerkit_log_viewer_key "M-l"
set -g @powerkit_log_viewer_width "90%"
set -g @powerkit_log_viewer_height "80%"

set -g @powerkit_reload_config_key "r"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_show_options_key` | key | `"C-e"` | Options viewer (prefix + key) |
| `@powerkit_show_options_width` | string | `"80%"` | Options popup width |
| `@powerkit_show_options_height` | string | `"80%"` | Options popup height |
| `@powerkit_show_keybindings_key` | key | `"C-y"` | Keybindings viewer (prefix + key) |
| `@powerkit_show_keybindings_width` | string | `"80%"` | Keybindings popup width |
| `@powerkit_show_keybindings_height` | string | `"80%"` | Keybindings popup height |
| `@powerkit_theme_selector_key` | key | `"C-r"` | Theme selector (prefix + key) |
| `@powerkit_cache_clear_key` | key | `"M-x"` | Clear cache (prefix + key) |
| `@powerkit_log_viewer_key` | key | `"M-l"` | Log viewer (prefix + key) |
| `@powerkit_log_viewer_width` | string | `"90%"` | Log viewer popup width |
| `@powerkit_log_viewer_height` | string | `"80%"` | Log viewer popup height |
| `@powerkit_reload_config_key` | key | `"r"` | Reload tmux config (prefix + key) |

### Key Notation

| Notation | Meaning |
|----------|---------|
| `C-x` | Ctrl + x |
| `M-x` | Alt/Meta + x |
| `S-x` | Shift + x |

### Conflict Handling

```bash
set -g @powerkit_keybinding_conflict_action "warn"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_keybinding_conflict_action` | enum | `"warn"` | Action when keybinding conflicts |

| Value | Behavior |
|-------|----------|
| `warn` | Show notification, still bind |
| `skip` | Don't bind if conflict exists |
| `ignore` | Don't check for conflicts |

See [Keybindings](Keybindings) for complete keybinding reference.

---

## Cache Management

PowerKit caches plugin data to improve performance.

### Lazy Loading (Stale-While-Revalidate)

PowerKit uses a Stale-While-Revalidate strategy to ensure the status bar never blocks on slow operations.

```bash
# Enable/disable lazy loading (default: true)
set -g @powerkit_lazy_loading "true"

# Stale multiplier - how long stale data can be shown (default: 3)
# With TTL=300s and multiplier=3, data up to 900s old can be returned
set -g @powerkit_stale_multiplier "3"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_lazy_loading` | bool | `"true"` | Enable stale-while-revalidate for plugin data |
| `@powerkit_stale_multiplier` | number | `"3"` | Maximum staleness as multiple of TTL |

**How it works:**
- **FRESH** (age <= TTL): Return cached data immediately (normal colors)
- **STALE** (TTL < age <= TTL x 3): Return stale data + refresh in background (darker colors)
- **VERY OLD** (age > TTL x 3): Synchronous refresh (blocking)

**Visual Stale Indication:**

When displaying stale data, plugins show slightly darker background colors to provide visual feedback. The color variant is configurable:

```bash
# In your tmux.conf
set -g @powerkit_stale_color_variant "-darkest"  # Options: -darker, -darkest, -lighter, -lightest
```

### Clear Cache

```bash
# Via keybinding (default: prefix + Alt+x)
prefix + M-x

# Or manually via shell
rm -rf ~/.cache/tmux-powerkit/
```

### Cache TTL

Each plugin can configure its cache duration:

```bash
set -g @powerkit_plugin_<name>_cache_ttl "60"  # seconds
```

Common TTL values:
- Short: `60` (1 minute) - fast-changing data
- Medium: `300` (5 minutes) - moderate updates
- Long: `3600` (1 hour) - slow-changing data
- Day: `86400` (24 hours) - rarely changing data

See [Caching](Caching) for detailed caching documentation.

---

## Advanced Options

These options are for advanced users and debugging.

```bash
set -g @powerkit_debug "false"
set -g @powerkit_ui_backend "auto"
set -g @powerkit_segment_template ""
set -g @powerkit_clock_style "24"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_debug` | bool | `"false"` | Enable debug logging to `~/.cache/tmux-powerkit/powerkit.log` |
| `@powerkit_ui_backend` | enum | `"auto"` | Force UI backend: `auto`, `gum`, `fzf`, `basic` |
| `@powerkit_segment_template` | string | `""` | Override global segment template |
| `@powerkit_clock_style` | enum | `"24"` | Clock format: `12` or `24` |

### UI Backend

PowerKit auto-detects available UI tools for interactive helpers:

| Value | Description |
|-------|-------------|
| `auto` | Auto-detect: gum -> fzf -> basic (default) |
| `gum` | Force [gum](https://github.com/charmbracelet/gum) |
| `fzf` | Force [fzf](https://github.com/junegunn/fzf) |
| `basic` | Use basic shell prompts (no dependencies) |

### Segment Template

Custom template for plugin segments. Variables available:

| Variable | Description |
|----------|-------------|
| `{icon}` | Plugin icon |
| `{content}` | Plugin text content |
| `{sep_left}` | Left separator |
| `{sep_right}` | Right separator |

Per-plugin templates: `@powerkit_plugin_<name>_template`

---

# Session Options

Options for the session segment (left side of status bar).

```bash
set -g @powerkit_session_icon "auto"
set -g @powerkit_session_prefix_icon ""
set -g @powerkit_session_copy_icon ""
set -g @powerkit_session_command_icon ""
set -g @powerkit_session_search_icon ""
set -g @powerkit_session_normal_color "session-bg"
set -g @powerkit_session_prefix_color "session-prefix-bg"
set -g @powerkit_session_copy_mode_color "session-copy-bg"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_session_icon` | string | `"auto"` | Session icon (`auto` = OS icon) |
| `@powerkit_session_prefix_icon` | icon | `` | Icon when prefix is pressed |
| `@powerkit_session_copy_icon` | icon | `` | Icon in copy mode |
| `@powerkit_session_command_icon` | icon | `` | Icon in command prompt mode |
| `@powerkit_session_search_icon` | icon | `` | Icon in search mode |
| `@powerkit_session_normal_color` | color | `"session-bg"` | Normal state background |
| `@powerkit_session_prefix_color` | color | `"session-prefix-bg"` | Prefix mode background |
| `@powerkit_session_copy_mode_color` | color | `"session-copy-bg"` | Copy mode background |
| `@powerkit_session_show_mode` | bool | `"false"` | Display session mode indicator |

## Session Mode Display

When `@powerkit_session_show_mode` is enabled, PowerKit displays the current session mode in the session segment:

```bash
set -g @powerkit_session_show_mode "true"
```

### Mode Indicators

When active, the session segment shows one of these mode indicators:

| Mode | Display | Description |
|------|---------|-------------|
| Prefix | `(prefix)` | Prefix key has been pressed |
| Copy | `(copy)` | Copy mode is active |
| Search | `(search)` | Search is active in copy mode |
| Command | `(command)` | Command prompt is active |
| Normal | (no indicator) | Normal mode |

### Mode Priority

Modes are checked in this order (highest to lowest priority):

1. **Prefix mode** - Highest priority (prefix key pressed)
2. **Search mode** - Active search in copy mode
3. **Copy mode** - Copy/selection mode
4. **Command mode** - Command prompt
5. **Normal** - No special mode (no indicator shown)

### Examples

```bash
# Enable mode display
set -g @powerkit_session_show_mode "true"

# Session segment will show:
# [  main (copy) ]   <- in copy mode
# [  main (prefix) ] <- after pressing prefix key
# [  main ]          <- normal mode (no indicator)
```

See [Session Contract](ContractSession) for more details.

---

# Window Options

Options for window segments in the status bar.

## Window Icons

```bash
set -g @powerkit_active_window_icon ""
set -g @powerkit_inactive_window_icon ""
set -g @powerkit_zoomed_window_icon ""
set -g @powerkit_pane_synchronized_icon ""
set -g @powerkit_window_default_icon ""
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_active_window_icon` | icon | `` | Active window icon |
| `@powerkit_inactive_window_icon` | icon | `` | Inactive window icon |
| `@powerkit_zoomed_window_icon` | icon | `` | Zoomed pane indicator |
| `@powerkit_pane_synchronized_icon` | icon | `` | Synchronized panes indicator |
| `@powerkit_window_default_icon` | icon | `` | Default icon when no command match |

## Window Title

```bash
set -g @powerkit_active_window_title "#W"
set -g @powerkit_inactive_window_title "#W"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_active_window_title` | string | `"#W"` | Active window title format |
| `@powerkit_inactive_window_title` | string | `"#W"` | Inactive window title format |

Title format supports tmux variables like `#W` (window name), `#I` (index), `#F` (flags).

## Window Index Style

```bash
set -g @powerkit_window_index_style "text"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_window_index_style` | enum | `"text"` | Window index display style |
| `@powerkit_active_window_show_index` | bool | `"true"` | Show index for active window |
| `@powerkit_inactive_window_show_index` | bool | `"true"` | Show index for inactive windows |

### Available Styles

| Style | Description | Example (0-3) |
|-------|-------------|---------------|
| `text` | Plain numbers | 0, 1, 2, 3 |
| `numeric` | Nerd Font numeric icons | 󰬹, 󰬺, 󰬻, 󰬼 |
| `box` | Numbers in filled boxes | 󰎡, 󰎤, 󰎧, 󰎪 |
| `box_outline` | Numbers in outlined boxes | 󰎣, 󰎦, 󰎩, 󰎬 |
| `box_multiple` | Multiple filled boxes | 󰼎, 󰼏, 󰼐, 󰼑 |
| `box_multiple_outline` | Multiple outlined boxes | 󰎢, 󰎥, 󰎨, 󰎫 |
| `circle` | Numbers in filled circles | 󰲞, 󰲠, 󰲢, 󰲤 |
| `circle_outline` | Numbers in outlined circles | 󰲟, 󰲡, 󰲣, 󰲥 |

> **Note:** Multi-digit indices (10+) are built by combining single digit icons.

## Window Index Visibility

You can hide the window index for active and/or inactive windows:

```bash
# Hide index for inactive windows only
set -g @powerkit_inactive_window_show_index "false"

# Hide index for all windows
set -g @powerkit_active_window_show_index "false"
set -g @powerkit_inactive_window_show_index "false"
```

### Index Display Options

| Active | Inactive | Result |
|--------|----------|--------|
| `true` | `true` | Index shown on all windows (default) |
| `true` | `false` | Index shown only on active window |
| `false` | `true` | Index shown only on inactive windows |
| `false` | `false` | No index shown anywhere |

### Examples

```bash
# Show index only on active window (clean look for inactive)
set -g @powerkit_active_window_show_index "true"
set -g @powerkit_inactive_window_show_index "false"

# Minimal display: hide all indices
set -g @powerkit_active_window_show_index "false"
set -g @powerkit_inactive_window_show_index "false"
```

### Visual Effect

When index is hidden, the separator colors automatically adjust to use the content background color instead of the index background color, creating a seamless appearance.

See [Window Contract](ContractWindow) for more details.

---

# Pane Options

Options for pane borders and pane-related display.

## Pane Border Style

```bash
set -g @powerkit_pane_border_lines "single"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_border_lines` | enum | `"single"` | Border style: `single`, `double`, `heavy`, `simple`, `number` |

## Pane Border Colors

```bash
# Separate colors for active/inactive panes (default)
set -g @powerkit_active_pane_border_color "pane-border-active"
set -g @powerkit_inactive_pane_border_color "pane-border-inactive"

# OR use unified color for all panes
set -g @powerkit_pane_border_unified "true"
set -g @powerkit_pane_border_color "pane-border-active"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_border_unified` | bool | `"false"` | Use single color for all pane borders |
| `@powerkit_pane_border_color` | color | `"pane-border-active"` | Unified pane border color (when unified=true) |
| `@powerkit_active_pane_border_color` | color | `"pane-border-active"` | Active pane border color |
| `@powerkit_inactive_pane_border_color` | color | `"pane-border-inactive"` | Inactive pane border color |

### Unified Pane Border

To use a single color for all pane borders (removing the two-color effect when panes meet):

```bash
set -g @powerkit_pane_border_unified "true"
set -g @powerkit_pane_border_color "pane-border-active"
```

Available theme colors for pane borders:
- `pane-border-active` - Theme's active pane color
- `pane-border-inactive` - Theme's inactive pane color
- `background` - Terminal background (nearly invisible)
- `statusbar-bg` - Status bar background
- `ok-base`, `info-base`, etc. - Health state colors
- Any hex color like `"#3b4261"`

## Pane Border Status

```bash
set -g @powerkit_pane_border_status "off"
set -g @powerkit_pane_border_status_bg "none"
set -g @powerkit_pane_border_format "{index}: {title}"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_border_status` | enum | `"off"` | Show pane status: `off`, `top`, `bottom` |
| `@powerkit_pane_border_status_bg` | color | `"none"` | Background color for the status line |
| `@powerkit_pane_border_format` | string | `"{index}: {title}"` | Pane status format |

### Pane Status Background Color

The `@powerkit_pane_border_status_bg` option allows you to set a distinct background color for the pane status line (the top or bottom bar), while keeping the border lines themselves with the default transparent background.

**Values:**
- `"none"` - Transparent background (default)
- Theme color name: `"info-base"`, `"statusbar-bg"`, `"window-active-base"`, etc.
- Hex color: `"#3b4261"`, `"#7aa2f7"`, etc.

**Example:**

```bash
# Highlight the status line with info color
set -g @powerkit_pane_border_status "top"
set -g @powerkit_pane_border_status_bg "info-base"
set -g @powerkit_pane_border_format "{active} {command}"
```

### Pane Border Format Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{index}` | Pane index number |
| `{title}` | Pane title |
| `{command}` | Current command |
| `{path}` | Full current path |
| `{basename}` | Basename of current path |
| `{active}` | Shows `▶` only on active pane (useful with unified border) |

> **Note:** Active pane text is displayed in **bold**, inactive panes use normal weight.

**Examples:**

```bash
# Default format
set -g @powerkit_pane_border_format "{index}: {title}"

# Show basename with active indicator
set -g @powerkit_pane_border_format "{active} {basename}"

# Show current command
set -g @powerkit_pane_border_format "{active} {command}"
```

## Pane Flash Effect

Visual feedback when selecting or clicking on a pane. The pane background briefly flashes a color to indicate selection.

```bash
set -g @powerkit_pane_flash_enabled "false"
set -g @powerkit_pane_flash_color "statusbar-bg"
set -g @powerkit_pane_flash_duration "100"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_flash_enabled` | bool | `"false"` | Enable pane flash on selection |
| `@powerkit_pane_flash_color` | color | `"statusbar-bg"` | Flash background color (theme color or hex) |
| `@powerkit_pane_flash_duration` | number | `"100"` | Flash duration in milliseconds |

### Flash Color Options

You can use any theme color or hex value:

- **Theme colors**: `statusbar-bg` (status bar background), `info-base` (blue), `ok-base` (green), `warning-base` (yellow)
- **Color variants**: `info-base-lighter`, `ok-base-darker`, etc.
- **Hex colors**: `"#7aa2f7"`, `"#bb9af7"`

### Example Configurations

```bash
# Status bar background flash (default)
set -g @powerkit_pane_flash_enabled "true"
set -g @powerkit_pane_flash_color "statusbar-bg"
set -g @powerkit_pane_flash_duration "100"

# Quick green flash
set -g @powerkit_pane_flash_enabled "true"
set -g @powerkit_pane_flash_color "ok-base"
set -g @powerkit_pane_flash_duration "50"

# Longer yellow flash for visibility
set -g @powerkit_pane_flash_enabled "true"
set -g @powerkit_pane_flash_color "warning-base"
set -g @powerkit_pane_flash_duration "200"
```

> **Note:** The flash effect uses the `after-select-pane` tmux hook to trigger automatically when switching panes.

See [Pane Contract](ContractPane) for implementation details.

---

# Popup & Menu Options

Popup and menu styles are automatically derived from the active theme's colors. These options allow customization of the border line style.

## Configuration

```bash
set -g @powerkit_popup_border_lines "rounded"
set -g @powerkit_menu_border_lines "rounded"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_popup_border_lines` | enum | `"rounded"` | Popup border line style |
| `@powerkit_menu_border_lines` | enum | `"rounded"` | Menu border line style |

## Border Line Styles

| Value | Description |
|-------|-------------|
| `single` | Single line border |
| `rounded` | Rounded corners (default) |
| `heavy` | Heavy/thick lines |
| `double` | Double line border |
| `simple` | Simple ASCII border |
| `padded` | Padded border |
| `none` | No border |

## Theme Colors

Popup and menu colors are automatically set from the theme. Each theme defines:

| Color | Usage |
|-------|-------|
| `popup-bg` | Popup background |
| `popup-fg` | Popup text color |
| `popup-border` | Popup border color |
| `menu-bg` | Menu background |
| `menu-fg` | Menu text color |
| `menu-selected-bg` | Selected item background |
| `menu-selected-fg` | Selected item text color |
| `menu-border` | Menu border color |

These colors are applied automatically when the theme is loaded, ensuring consistent styling across all popups and menus (theme selector, keybindings viewer, options viewer, plugin popups, etc.).

---

# Environment Variables

```bash
export POWERKIT_DEBUG=true              # Enable debug logging
export POWERKIT_ROOT=/path/to/powerkit  # Override installation path
```

| Variable | Description |
|----------|-------------|
| `POWERKIT_DEBUG` | Enable verbose debug logging |
| `POWERKIT_ROOT` | Override PowerKit installation directory |

---

## Option Types Reference

| Type | Description | Example |
|------|-------------|---------|
| `string` | Text value | `"value"` |
| `number` | Numeric value | `"30"` |
| `bool` | Boolean | `"true"` or `"false"` |
| `color` | Color name or hex | `"primary"` or `"#ff0000"` |
| `icon` | Nerd Font icon | `` |
| `key` | Keybinding | `"C-e"` |
| `path` | File system path | `"/path/to/file"` |
| `enum` | Predefined values | `"warn"` |

---

## Complete Example

```bash
# ~/.tmux.conf

# ============================================================================
# GLOBAL OPTIONS
# ============================================================================

# Theme
set -g @powerkit_theme "catppuccin"
set -g @powerkit_theme_variant "mocha"
set -g @powerkit_transparent "false"

# Plugins
set -g @powerkit_plugins "git,kubernetes,cpu,memory,datetime"

# Separators
set -g @powerkit_separator_style "rounded"
set -g @powerkit_edge_separator_style "rounded"
set -g @powerkit_elements_spacing "false"

# Status bar
set -g @powerkit_status_interval "5"
set -g @powerkit_status_position "top"
set -g @powerkit_bar_layout "single"

# Keybindings
set -g @powerkit_show_options_key "C-e"
set -g @powerkit_theme_selector_key "C-r"
set -g @powerkit_keybinding_conflict_action "warn"

# ============================================================================
# SESSION OPTIONS
# ============================================================================

set -g @powerkit_session_icon "auto"

# ============================================================================
# WINDOW OPTIONS
# ============================================================================

set -g @powerkit_window_index_style "box"

# ============================================================================
# PANE OPTIONS
# ============================================================================

# Use unified pane border color
set -g @powerkit_pane_border_unified "true"
set -g @powerkit_pane_border_color "pane-border-active"

# Show pane status (top border) with info-base background
set -g @powerkit_pane_border_status "top"
set -g @powerkit_pane_border_status_bg "info-base"
set -g @powerkit_pane_border_format "{active} {basename}"

# Initialize PowerKit (keep this at the end)
run-shell ~/.tmux/plugins/tmux-powerkit/tmux-powerkit.tmux
```

---

## Related

- [Quick Start](Quick-Start) - Basic setup guide
- [Themes](Themes) - Theme configuration
- [Keybindings](Keybindings) - Keybinding reference
- [Helpers](Helpers) - Helper utilities
- [Architecture](Architecture) - System architecture
