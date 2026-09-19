# Pane Contract

The Pane Contract defines the interface for ALL pane-related functionality in tmux, including visual effects, styling, and state management.

## Overview

Panes in PowerKit have states (active/inactive/zoomed), configurable border styling, optional status display, and visual flash effects for selection feedback.

## Pane States

| State | Description | Detection |
|-------|-------------|-----------|
| `active` | Currently focused pane | `#{pane_active} == 1` |
| `inactive` | Not focused | `#{pane_active} == 0` |
| `zoomed` | Pane is zoomed to fill window | `#{window_zoomed_flag} == 1` |

## Flash Effect

Visual feedback when selecting or clicking on a pane. The pane background briefly flashes a color to indicate selection.

### Configuration

```bash
set -g @powerkit_pane_flash_enabled "false"
set -g @powerkit_pane_flash_color "statusbar-bg"
set -g @powerkit_pane_flash_duration "100"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_flash_enabled` | bool | `"false"` | Enable pane flash on selection |
| `@powerkit_pane_flash_color` | color | `"statusbar-bg"` | Flash background color |
| `@powerkit_pane_flash_duration` | number | `"100"` | Flash duration in milliseconds |

### How It Works

```
User switches pane (click or keybind)
    ↓
tmux triggers after-select-pane hook
    ↓
Hook sets window-active-style "bg=COLOR"
    ↓
Sleep for duration_ms
    ↓
Hook resets window-active-style ""
```

### API

| Function | Description |
|----------|-------------|
| `pane_flash_enable()` | Enable pane flash effect |
| `pane_flash_disable()` | Disable pane flash effect |
| `pane_flash_is_enabled()` | Check if flash is enabled |
| `pane_flash_trigger()` | Manually trigger flash effect |
| `pane_flash_setup()` | Setup flash hook (called by bootstrap) |

## Pane Information

### Single Value Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `pane_get_id()` | `%0` | Current pane ID |
| `pane_get_index()` | `0` | Pane index in window |
| `pane_get_title()` | `zsh` | Pane title |
| `pane_get_command()` | `nvim` | Current command |
| `pane_get_path()` | `/home/user/project` | Current working directory |
| `pane_get_state()` | `active` | Pane state |
| `pane_is_active()` | 0/1 | Check if pane is active |
| `pane_is_zoomed()` | 0/1 | Check if pane is zoomed |

### Batch Function (Efficient)

```bash
# Get all pane info in single tmux call
eval "$(pane_get_all)"

# Variables set:
echo "$PANE_ID"       # %0
echo "$PANE_INDEX"    # 0
echo "$PANE_TITLE"    # zsh
echo "$PANE_COMMAND"  # nvim
echo "$PANE_PATH"     # /home/user/project
echo "$PANE_STATE"    # active
```

## Border Styling

### Configuration

```bash
# Border line style
set -g @powerkit_pane_border_lines "single"

# Separate colors (default)
set -g @powerkit_pane_border_unified "false"
set -g @powerkit_active_pane_border_color "pane-border-active"
set -g @powerkit_inactive_pane_border_color "pane-border-inactive"

# OR unified color (removes two-color effect when panes meet)
set -g @powerkit_pane_border_unified "true"
set -g @powerkit_pane_border_color "pane-border-active"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_border_lines` | enum | `"single"` | Border style: `single`, `double`, `heavy`, `simple`, `number` |
| `@powerkit_pane_border_unified` | bool | `"false"` | Use single color for all borders |
| `@powerkit_pane_border_color` | color | `"pane-border-active"` | Unified border color |
| `@powerkit_active_pane_border_color` | color | `"pane-border-active"` | Active pane border |
| `@powerkit_inactive_pane_border_color` | color | `"pane-border-inactive"` | Inactive pane border |

### API

| Function | Returns | Description |
|----------|---------|-------------|
| `pane_border_color("active")` | `#7aa2f7` | Get border color for type |
| `pane_border_style("active")` | `fg=#7aa2f7` | Get border style string |

## Border Status

Display information in the pane border (top or bottom).

### Configuration

```bash
set -g @powerkit_pane_border_status "off"
set -g @powerkit_pane_border_status_bg "none"
set -g @powerkit_pane_border_format "{index}: {title}"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_border_status` | enum | `"off"` | Position: `off`, `top`, `bottom` |
| `@powerkit_pane_border_status_bg` | color | `"none"` | Background color (none = transparent) |
| `@powerkit_pane_border_format` | string | `"{index}: {title}"` | Format string with placeholders |

### Format Placeholders

| Placeholder | Resolved To | Example |
|-------------|-------------|---------|
| `{index}` | `#{pane_index}` | `0` |
| `{title}` | `#{pane_title}` | `zsh` |
| `{command}` | `#{pane_current_command}` | `nvim` |
| `{path}` | `#{pane_current_path}` | `/home/user` |
| `{basename}` | `#{b:pane_current_path}` | `user` |
| `{active}` | `#{?pane_active,▶,}` | `▶` or empty |

### API

| Function | Returns | Description |
|----------|---------|-------------|
| `pane_resolve_format_placeholders(fmt)` | tmux format | Convert placeholders to tmux format |
| `pane_build_border_format()` | complete format | Build format with colors |

### Examples

```bash
# Show pane index and title (default)
set -g @powerkit_pane_border_format "{index}: {title}"
# Result: "0: zsh"

# Show active indicator and command
set -g @powerkit_pane_border_format "{active} {command}"
# Result: "▶ nvim" (active) or "zsh" (inactive)

# Show basename of current directory
set -g @powerkit_pane_border_format "{active} {basename}"
# Result: "▶ tmux-powerkit"
```

## Synchronized Panes

When panes are synchronized (same input to all panes), an indicator is shown.

### Configuration

```bash
set -g @powerkit_pane_synchronized_icon "✵"
```

### API

| Function | Returns | Description |
|----------|---------|-------------|
| `pane_get_sync_icon()` | `✵` | Get synchronized icon |
| `pane_sync_format()` | `#{?pane_synchronized,✵,}` | Get tmux format for indicator |

## Scrollbars (tmux 3.4+)

Character-based scrollbars that appear on the side of panes.

### Configuration

```bash
# Enable scrollbars (off, modal, on)
set -g @powerkit_pane_scrollbars "modal"

# Position (left, right)
set -g @powerkit_pane_scrollbars_position "right"

# Slider color (visible portion)
set -g @powerkit_pane_scrollbars_style_fg "pane-border-active"

# Track color (background)
set -g @powerkit_pane_scrollbars_style_bg "pane-border-inactive"

# Width and padding
set -g @powerkit_pane_scrollbars_width "1"
set -g @powerkit_pane_scrollbars_pad "0"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_pane_scrollbars` | enum | `"off"` | Scrollbar mode: `off`, `modal`, `on` |
| `@powerkit_pane_scrollbars_position` | enum | `"right"` | Position: `left`, `right` |
| `@powerkit_pane_scrollbars_style_fg` | color | `"pane-border-active"` | Slider (foreground) color |
| `@powerkit_pane_scrollbars_style_bg` | color | `"pane-border-inactive"` | Track (background) color |
| `@powerkit_pane_scrollbars_width` | number | `"1"` | Width in characters |
| `@powerkit_pane_scrollbars_pad` | number | `"0"` | Padding between scrollbar and pane |

### Modes

- **off**: No scrollbars (default)
- **modal**: Scrollbars only appear in copy mode or view mode
- **on**: Scrollbars always visible

### API

| Function | Returns | Description |
|----------|---------|-------------|
| `pane_scrollbars_style()` | `fg=...,bg=...,width=...,pad=...` | Build complete style string |

## Complete Configuration

Apply all pane settings to tmux with a single call:

```bash
pane_configure()
```

This function is called by the renderer and applies:
- Border styles (active/inactive colors)
- Border line style
- Border status position
- Border format (when status enabled)
- Scrollbars (when enabled, tmux 3.4+)

## Color Options

All color options accept:

- **Theme colors**: `pane-border-active`, `info-base`, `ok-base`, `warning-base`
- **Color variants**: `info-base-lighter`, `ok-base-darker`
- **Hex colors**: `"#7aa2f7"`, `"#3b4261"`

## Visual Example

```
Default (separate colors):
┌──────────────┐┌──────────────┐
│   Active     ││   Inactive   │
│   (purple)   ││   (gray)     │
└──────────────┘└──────────────┘

Unified (single color):
┌──────────────┐┌──────────────┐
│   Pane 1     ││   Pane 2     │
│   (purple)   ││   (purple)   │
└──────────────┘└──────────────┘

With border status (top):
 0: zsh          1: nvim
┌──────────────┐┌──────────────┐
│              ││              │
│              ││              │
└──────────────┘└──────────────┘
```

## Implementation File

- **Contract**: [`src/contract/pane_contract.sh`](../src/contract/pane_contract.sh)

## Related

- [Session Contract](ContractSession) - Session representation
- [Window Contract](ContractWindow) - Window representation
- [Configuration](Configuration#pane-options) - Pane configuration options
- [Architecture](Architecture) - System architecture
