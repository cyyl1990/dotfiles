# Quick Start

Get PowerKit running with a minimal configuration.

## Requirements

- **tmux** 3.0+
- **Bash** 5.0+ (5.1+ recommended)
- **Nerd Font** for icons

> **macOS users:** macOS ships with Bash 3.x. Install Bash 5+ with `brew install bash`.

## Basic Setup

Add to your `~/.tmux.conf`:

```bash
# PowerKit plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Enable desired plugins (comma-separated)
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname,git"

# Choose a theme (catppuccin/mocha is the default)
set -g @powerkit_theme "catppuccin"
set -g @powerkit_theme_variant "mocha"
```

Reload tmux: `tmux source ~/.tmux.conf`

> **Example Configuration:** See the [author's tmux.conf](https://github.com/fabioluciano/dot/blob/main/private_dot_config/tmux/tmux.conf) for an advanced real-world configuration.

## Available Plugins

PowerKit provides 43 plugins organized by category:

### System Monitoring
```bash
set -g @powerkit_plugins "battery,cpu,memory,swap,disk,loadavg,uptime,temperature"
```

### Network Information
```bash
set -g @powerkit_plugins "netspeed,wifi,vpn,ping,external_ip"
```

### Development Tools
```bash
set -g @powerkit_plugins "git,github,kubernetes,terraform"
```

### Productivity
```bash
set -g @powerkit_plugins "datetime,pomodoro,bitwarden"
```

## Theme Selection

PowerKit includes 32 themes with 56 variants:

```bash
# Dark themes
set -g @powerkit_theme "catppuccin"
set -g @powerkit_theme_variant "mocha"

# Light themes
set -g @powerkit_theme "github"
set -g @powerkit_theme_variant "light"
```

Popular themes: `tokyo-night`, `catppuccin`, `dracula`, `nord`, `gruvbox`

## Separator Styles

Customize the separators between segments:

```bash
set -g @powerkit_separator_style "rounded"  # normal, rounded, flame, pixel, honeycomb, none
```

## Plugin Options

Each plugin has configurable options:

```bash
# Battery thresholds
set -g @powerkit_plugin_battery_warning_threshold "30"
set -g @powerkit_plugin_battery_critical_threshold "15"

# Custom icons
set -g @powerkit_plugin_cpu_icon ""

# Cache duration (seconds)
set -g @powerkit_plugin_weather_cache_ttl "3600"
```

## Keybindings

PowerKit registers several keybindings:

| Key | Action |
|-----|--------|
| `prefix + C-e` | Options viewer |
| `prefix + C-y` | Keybindings viewer |
| `prefix + C-r` | Theme selector |
| `prefix + C-d` | Clear cache |

## Next Steps

- [Configuration](Configuration) - All configuration options
- [Themes](Themes) - Theme gallery and customization
- [Keybindings](Keybindings) - Keybinding system details
