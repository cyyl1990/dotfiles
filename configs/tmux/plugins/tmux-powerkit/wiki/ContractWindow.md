# Window Contract

The Window Contract defines how tmux windows are represented in the status bar.

## Overview

Windows have states (active/inactive/etc.) and can display dynamic icons based on the running command.

## Window States

| State | Description | Color Key |
|-------|-------------|-----------|
| `active` | Currently focused window | `window-active-base` |
| `inactive` | Not focused | `window-inactive-base` |
| `activity` | Has unseen activity | `window-active-base` + indicator |
| `bell` | Bell rang in window | `error-base` |
| `zoomed` | Pane is zoomed | Special indicator |
| `last` | Previously focused | Subtle highlight |
| `marked` | Has marked pane | Special indicator |

## Window Icon System

PowerKit maps running commands to icons:

| Command Pattern | Icon | Description |
|-----------------|------|-------------|
| `vim`, `nvim` | `` | Vim/Neovim editor |
| `code` | `󰨞` | VS Code |
| `git` | `` | Git operations |
| `docker` | `` | Docker |
| `node`, `npm` | `` | Node.js |
| `python` | `` | Python |
| `ruby` | `` | Ruby |
| `go` | `` | Go |
| `rust`, `cargo` | `` | Rust |
| `ssh` | `` | SSH session |
| `htop`, `top` | `` | Process viewer |
| `man` | `` | Manual pages |
| Default | `` | Terminal |

## Icon Resolution

```
Current command: "nvim src/main.rs"
    ↓
Match pattern: "nvim"
    ↓
Icon:
    ↓
Window displays:  main.rs
```

## Window Format

Default window format:

```
{icon} {window_name}:{pane_index}
```

Example: ` src:1`

## Configuration

```bash
# Window format
set -g @powerkit_window_format "#{window_index}:#{window_name}"

# Show window flags
set -g @powerkit_window_show_flags "true"

# Icon for current directory
set -g @powerkit_window_directory_icon ""

# Window index display style
set -g @powerkit_window_index_style "numeric"
```

## Window Index Styles

The `@powerkit_window_index_style` option controls how window indices are displayed:

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

### Numeric Style Icons (0-9)

| Index | Icon | Unicode | Nerd Font |
|-------|------|---------|-----------|
| 0 | 󰬹 | U+F0B39 | nf-md-numeric_0 |
| 1 | 󰬺 | U+F0B3A | nf-md-numeric_1 |
| 2 | 󰬻 | U+F0B3B | nf-md-numeric_2 |
| 3 | 󰬼 | U+F0B3C | nf-md-numeric_3 |
| 4 | 󰬽 | U+F0B3D | nf-md-numeric_4 |
| 5 | 󰬾 | U+F0B3E | nf-md-numeric_5 |
| 6 | 󰬿 | U+F0B3F | nf-md-numeric_6 |
| 7 | 󰭀 | U+F0B40 | nf-md-numeric_7 |
| 8 | 󰭁 | U+F0B41 | nf-md-numeric_8 |
| 9 | 󰭂 | U+F0B42 | nf-md-numeric_9 |

For indices 10+, composite icons are generated dynamically (e.g., 10 = 󰬺󰬹, 11 = 󰬺󰬺).

For text style with indices >= 100, the numeric value is displayed as-is.

## State Indicators

| Indicator | Meaning |
|-----------|---------|
| `*` | Current window |
| `-` | Last window |
| `#` | Activity in window |
| `!` | Bell in window |
| `Z` | Zoomed pane |
| `M` | Marked pane |

## Visual Example

```
Active:     1:vim      (purple background)
Inactive:   2:shell    (gray background)
Activity:   3:build #  (gray + indicator)
Zoomed:     4:logs Z   (with zoom indicator)
```

## Custom Icon Mapping

Add custom mappings via options:

```bash
set -g @powerkit_window_icon_myapp ""
```

## Related

- [Session Contract](ContractSession) - Session representation
- [Pane Contract](ContractPane) - Pane representation
- [Theme Contract](ContractTheme) - Color definitions
- [Configuration](Configuration) - Window options
