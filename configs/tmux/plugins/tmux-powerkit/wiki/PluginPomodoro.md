# Plugin: pomodoro

Pomodoro timer for productivity with configurable work/break intervals and session tracking.

## Screenshots

```
󰔟 25:00 #1
󰒲 05:00 #1
󰜌 Stopped
󰔟 05:23 #3
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux, FreeBSD |
| Dependencies | None |
| Content Type | dynamic |
| Presence | conditional (hidden when stopped) |

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "pomodoro"

# Set keybinding to toggle timer
set -g @powerkit_plugin_pomodoro_keybinding_toggle "C-p"

# Reload tmux configuration
tmux source-file ~/.tmux.conf

# Start timer with: prefix + C-p
```

## Configuration Example

```bash
set -g @powerkit_plugins "pomodoro"

# Timer durations (minutes)
set -g @powerkit_plugin_pomodoro_work_duration "25"
set -g @powerkit_plugin_pomodoro_short_break "5"
set -g @powerkit_plugin_pomodoro_long_break "15"
set -g @powerkit_plugin_pomodoro_sessions_before_long "4"

# Display options
set -g @powerkit_plugin_pomodoro_show_remaining "true"
set -g @powerkit_plugin_pomodoro_show_sessions "true"

# Icons
set -g @powerkit_plugin_pomodoro_icon "󰔟"
set -g @powerkit_plugin_pomodoro_icon_work "󰔟"
set -g @powerkit_plugin_pomodoro_icon_break "󰒲"
set -g @powerkit_plugin_pomodoro_icon_stopped "󰜌"

# Keybindings
set -g @powerkit_plugin_pomodoro_keybinding_toggle "C-p"
set -g @powerkit_plugin_pomodoro_keybinding_start ""
set -g @powerkit_plugin_pomodoro_keybinding_stop ""
set -g @powerkit_plugin_pomodoro_keybinding_skip ""

# Cache
set -g @powerkit_plugin_pomodoro_cache_ttl "1"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_pomodoro_work_duration` | number | `25` | Work session duration in minutes |
| `@powerkit_plugin_pomodoro_short_break` | number | `5` | Short break duration in minutes |
| `@powerkit_plugin_pomodoro_long_break` | number | `15` | Long break duration in minutes |
| `@powerkit_plugin_pomodoro_sessions_before_long` | number | `4` | Work sessions before long break |
| `@powerkit_plugin_pomodoro_show_remaining` | bool | `true` | Show remaining time |
| `@powerkit_plugin_pomodoro_show_sessions` | bool | `true` | Show completed session count |
| `@powerkit_plugin_pomodoro_icon` | icon | `󰔟` | Default icon |
| `@powerkit_plugin_pomodoro_icon_work` | icon | `󰔟` | Work session icon |
| `@powerkit_plugin_pomodoro_icon_break` | icon | `󰒲` | Break session icon |
| `@powerkit_plugin_pomodoro_icon_stopped` | icon | `󰜌` | Stopped icon |
| `@powerkit_plugin_pomodoro_keybinding_toggle` | key | `C-p` | Toggle timer (start/stop) |
| `@powerkit_plugin_pomodoro_keybinding_start` | key | `` | Start work session |
| `@powerkit_plugin_pomodoro_keybinding_stop` | key | `` | Stop timer |
| `@powerkit_plugin_pomodoro_keybinding_skip` | key | `` | Skip to next phase |
| `@powerkit_plugin_pomodoro_cache_ttl` | number | `1` | Cache duration in seconds |

## States

| State | Condition |
|-------|-----------|
| `inactive` | Timer is stopped (plugin hidden) |
| `active` | Work session in progress |
| `degraded` | Break session in progress |

## Health Levels

| Level | Condition |
|-------|-----------|
| `info` | Work session with >5 minutes remaining |
| `warning` | Work session with <5 minutes remaining or break session active |
| `ok` | Timer is stopped |

## Context Values

| Context | Description |
|---------|-------------|
| `stopped` | Timer is not running |
| `working` | Work session active |
| `short_break` | Short break active |
| `long_break` | Long break active |

## Examples

### Standard 25/5 Pomodoro

```bash
set -g @powerkit_plugins "pomodoro"
set -g @powerkit_plugin_pomodoro_work_duration "25"
set -g @powerkit_plugin_pomodoro_short_break "5"
set -g @powerkit_plugin_pomodoro_keybinding_toggle "C-p"
```

### Extended Work Sessions

```bash
set -g @powerkit_plugins "pomodoro"
set -g @powerkit_plugin_pomodoro_work_duration "50"
set -g @powerkit_plugin_pomodoro_short_break "10"
set -g @powerkit_plugin_pomodoro_long_break "30"
```

### Minimal Display (No Session Count)

```bash
set -g @powerkit_plugins "pomodoro"
set -g @powerkit_plugin_pomodoro_show_sessions "false"
```

### Quick Action Keybindings

```bash
set -g @powerkit_plugins "pomodoro"
set -g @powerkit_plugin_pomodoro_keybinding_toggle "C-p"
set -g @powerkit_plugin_pomodoro_keybinding_start "C-s"
set -g @powerkit_plugin_pomodoro_keybinding_stop "C-x"
set -g @powerkit_plugin_pomodoro_keybinding_skip "C-n"
```

## Pomodoro Workflow

1. **Start Timer**: Press `prefix + C-p` (or configured keybinding)
2. **Work Phase**: Timer shows remaining time (e.g., `25:00`)
3. **Auto-Transition**: After work completes, automatically switches to break
4. **Break Phase**: Short break (5 min) or long break (15 min after 4 sessions)
5. **Session Tracking**: Displays completed session count (e.g., `#3`)
6. **Auto-Stop**: After break, timer stops and waits for next start

## Keybindings

| Action | Default Key | Description |
|--------|------------|-------------|
| Toggle | `prefix + C-p` | Start/stop timer |
| Start | (not bound) | Start work session |
| Stop | (not bound) | Stop timer completely |
| Skip | (not bound) | Skip to next phase |

## State Persistence

Timer state is stored in `$POWERKIT_CACHE_DIR/pomodoro_state` and persists across:
- tmux restarts
- tmux server restarts
- System reboots (if cache directory is preserved)

State file format: `phase start_time sessions`

## Troubleshooting

### Timer Not Showing

1. Check if plugin is enabled:
   ```bash
   tmux show-options -g | grep powerkit_plugins
   ```

2. Timer is conditional - it only shows when running. Start it with your keybinding.

3. Verify state file:
   ```bash
   cat ~/.cache/tmux-powerkit/data/pomodoro_state
   ```

### Timer Not Updating

The timer updates every second based on `cache_ttl`. If it's not updating:

1. Check tmux status-interval:
   ```bash
   tmux show-options -g status-interval
   ```

2. Ensure it's set to 1 second:
   ```bash
   set -g status-interval 1
   ```

### Keybinding Not Working

1. Verify keybinding is set:
   ```bash
   tmux show-options -g | grep pomodoro_keybinding
   ```

2. Check for conflicts:
   ```bash
   tmux list-keys | grep "C-p"
   ```

3. Use the keybinding conflict viewer:
   ```bash
   prefix + C-y  # View all keybindings
   ```

### Reset Timer State

If timer is stuck or behaving incorrectly:

```bash
rm ~/.cache/tmux-powerkit/data/pomodoro_state
tmux refresh-client
```

## Helper Script

The plugin uses `src/helpers/pomodoro_timer.sh` for timer control:

```bash
# Manual control (for debugging)
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/pomodoro_timer.sh toggle
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/pomodoro_timer.sh start
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/pomodoro_timer.sh stop
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/pomodoro_timer.sh skip
```

## Related Plugins

- [PluginDatetime](PluginDatetime) - Display current time
- [PluginSmartkey](PluginSmartkey) - Display custom environment variables
