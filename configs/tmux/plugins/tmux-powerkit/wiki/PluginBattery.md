# Plugin: battery

Display battery percentage with charge state indicator and multi-platform support.

## Screenshot

```
 85%    # Normal - green/ok
 32%    # Warning - yellow
 12%    # Critical - red
 100%   # Charging - blue/info
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, WSL, BSD, Termux |
| **Dependencies** | `pmset` (macOS), `upower`/`acpi` (Linux), `apm` (BSD) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS - pmset is built-in

# Linux (Debian/Ubuntu)
sudo apt install upower

# Linux (Fedora)
sudo dnf install upower

# Linux (Arch)
sudo pacman -S upower
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "battery"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "battery"

# Thresholds
set -g @powerkit_plugin_battery_warning_threshold "30"
set -g @powerkit_plugin_battery_critical_threshold "15"

# Display mode: percentage (default) or time
set -g @powerkit_plugin_battery_display_mode "percentage"

# Hide when fully charged and on AC power
set -g @powerkit_plugin_battery_hide_when_full_and_charging "false"

# Icons
set -g @powerkit_plugin_battery_icon ""
set -g @powerkit_plugin_battery_icon_charging ""
set -g @powerkit_plugin_battery_icon_low ""
set -g @powerkit_plugin_battery_icon_critical ""

# Cache duration (seconds)
set -g @powerkit_plugin_battery_cache_ttl "30"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_battery_display_mode` | string | `percentage` | Display mode: `percentage` or `time` |
| `@powerkit_plugin_battery_hide_when_full_and_charging` | bool | `false` | Hide when 100% and on AC power |
| `@powerkit_plugin_battery_warning_threshold` | number | `30` | Warning threshold percentage |
| `@powerkit_plugin_battery_critical_threshold` | number | `15` | Critical threshold percentage |
| `@powerkit_plugin_battery_icon` | icon | `` | Default battery icon (full) |
| `@powerkit_plugin_battery_icon_charging` | icon | `` | Charging/AC power icon |
| `@powerkit_plugin_battery_icon_low` | icon | `` | Low battery icon |
| `@powerkit_plugin_battery_icon_critical` | icon | `` | Critical battery icon |
| `@powerkit_plugin_battery_cache_ttl` | number | `30` | Cache duration in seconds |
| `@powerkit_plugin_battery_show_only_on_threshold` | bool | `false` | Only show when below warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Battery detected and readable | Visible |
| `inactive` | No battery (desktop, VM) | Hidden |
| `degraded` | Battery detected but health is poor | Visible |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Above warning threshold | Green |
| `warning` | Below warning, above critical | Yellow |
| `error` | Below critical threshold | Red |
| `info` | Charging or fully charged | Blue |

## Context Values

| Context | Description |
|---------|-------------|
| `charging` | Battery is actively charging |
| `discharging` | Battery is discharging (on battery power) |
| `charged` | Battery is fully charged (100%) |
| `ac_power` | Connected to AC but not charging (maintenance mode) |

## Display Modes

### Percentage Mode (default)

Shows battery level as percentage:

```
 85%
```

### Time Mode

Shows remaining time (only when discharging):

```
 2:45
```

Falls back to percentage when charging or time unavailable.

## Platform Support

| Platform | Method | Notes |
|----------|--------|-------|
| macOS | `pmset -g batt` | Built-in, most reliable |
| Linux (systemd) | `upower` | Recommended |
| Linux (legacy) | `acpi` | Fallback |
| Linux (sysfs) | `/sys/class/power_supply` | Last resort fallback |
| WSL | `/sys/class/power_supply` | Reads host battery |
| BSD | `apm -l` | FreeBSD/OpenBSD |
| Termux | `termux-battery-status` | Android |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "battery"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "battery"
set -g @powerkit_plugin_battery_warning_threshold "25"
set -g @powerkit_plugin_battery_critical_threshold "10"
```

### Time Display Mode

```bash
set -g @powerkit_plugins "battery"
set -g @powerkit_plugin_battery_display_mode "time"
```

### Hide When Full

```bash
set -g @powerkit_plugins "battery"
set -g @powerkit_plugin_battery_hide_when_full_and_charging "true"
```

### Only Show When Low

```bash
set -g @powerkit_plugins "battery"
set -g @powerkit_plugin_battery_show_only_on_threshold "true"
set -g @powerkit_plugin_battery_warning_threshold "20"
```

## Troubleshooting

### Battery Not Detected

1. Check if battery exists:
   ```bash
   # macOS
   pmset -g batt

   # Linux
   upower -e
   ls /sys/class/power_supply/
   ```

2. Verify dependencies are installed:
   ```bash
   which upower  # Linux
   which pmset   # macOS (should always exist)
   ```

### Wrong Percentage

- Some systems report inaccurate values. Try different detection methods by installing alternative tools (`acpi`, `upower`).

### Time Not Showing

- Time remaining is only available when discharging
- Some systems don't provide time estimates

## Related Plugins

- [PluginCpu](PluginCpu) - CPU usage monitoring
- [PluginMemory](PluginMemory) - Memory usage monitoring
- [PluginTemperature](PluginTemperature) - CPU temperature
