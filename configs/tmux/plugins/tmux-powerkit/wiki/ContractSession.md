# Session Contract

The Session Contract defines how tmux sessions are represented in the status bar.

## Overview

Sessions in PowerKit have states (attached/detached) and modes (normal/prefix/copy/etc.) that affect their visual representation.

## Session States

| State | Description | Visual |
|-------|-------------|--------|
| `attached` | Session is attached to a client | Normal display |
| `detached` | Session has no attached clients | Dimmed display |

## Session Modes

Modes determine the session indicator color:

| Mode | Trigger | Color Key |
|------|---------|-----------|
| `normal` | Default state | `session-bg` |
| `prefix` | After prefix key pressed | `session-prefix-bg` |
| `copy` | In copy mode | `session-copy-bg` |
| `command` | In command prompt | `session-command-bg` |
| `search` | In search mode | `session-search-bg` |

## Mode Detection

PowerKit detects modes via tmux format variables:

```bash
# Prefix mode
#{?client_prefix,prefix,normal}

# Copy mode
#{?pane_in_mode,copy,normal}
```

## Color Application

```
Mode: prefix
    ↓
Color: session-prefix-bg (e.g., #e0af68)
    ↓
Session indicator displays with yellow background
```

## Session Indicator Content

The session indicator shows:
- Session name
- Optional: window count
- Optional: attached client count

## Configuration

```bash
# Session display format
set -g @powerkit_session_format "#{session_name}"

# Show window count
set -g @powerkit_session_show_window_count "true"
```

## Visual Example

```
Normal:     [main]     (green background)
Prefix:     [main]     (yellow background)
Copy:       [main]     (cyan background)
Detached:   [main]     (dimmed)
```

## Related

- [Window Contract](ContractWindow) - Window representation
- [Pane Contract](ContractPane) - Pane representation
- [Theme Contract](ContractTheme) - Color definitions
- [Configuration](Configuration) - Session options
