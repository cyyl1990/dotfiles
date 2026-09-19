# Plugin: fan

Display fan speed (RPM) for system cooling fans.

## Screenshot

```
󰈐 2.5k RPM                     # Single fan (icon_k format, default)
󰈐 2.5k | 󰈐 3.0k RPM           # Multiple fans (icon_k format)
󰈑 4.5k RPM                     # Fast fan speed (warning threshold)
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | macOS: `osx-cpu-temp`/`smctemp`/`istats` (optional); Linux: hwmon/sysfs (built-in) or `sensors` |
| Content Type | dynamic |
| Presence | conditional |

## Installation

```bash
# macOS
brew install osx-cpu-temp
# or
brew install smctemp
# or
gem install iStats

# Linux - usually no installation needed (uses sysfs)
# Optional: install lm-sensors for more features
sudo apt install lm-sensors  # Debian/Ubuntu
sudo pacman -S lm_sensors    # Arch
```

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "fan"
```

## Configuration Example

```bash
set -g @powerkit_plugins "fan"

# Display options
set -g @powerkit_plugin_fan_source "auto"
set -g @powerkit_plugin_fan_format "icon_k"
set -g @powerkit_plugin_fan_selection "active"
set -g @powerkit_plugin_fan_separator " | "

# Icons
set -g @powerkit_plugin_fan_icon "󰈐"
set -g @powerkit_plugin_fan_icon_fast "󰈑"

# Thresholds (RPM)
set -g @powerkit_plugin_fan_warning_threshold "4000"
set -g @powerkit_plugin_fan_critical_threshold "6000"

# Cache duration
set -g @powerkit_plugin_fan_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_fan_source` | string | `auto` | Fan source: `auto`, `dell`, `thinkpad`, `hwmon` |
| `@powerkit_plugin_fan_format` | string | `icon_k` | Display format: `rpm`, `krpm`, `number`, `icon`, `icon_k` |
| `@powerkit_plugin_fan_selection` | string | `active` | Fan selection: `active` (RPM > 0) or `all` (include idle) |
| `@powerkit_plugin_fan_separator` | string | ` \| ` | Separator between multiple fans |
| `@powerkit_plugin_fan_icon` | icon | `󰈐` | Normal fan icon |
| `@powerkit_plugin_fan_icon_fast` | icon | `󰈑` | Fast fan icon (above warning) |
| `@powerkit_plugin_fan_warning_threshold` | number | `4000` | Warning threshold in RPM |
| `@powerkit_plugin_fan_critical_threshold` | number | `6000` | Critical threshold in RPM |
| `@powerkit_plugin_fan_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_fan_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Selection Modes

| Value | Description |
|-------|-------------|
| `active` | Show all fans with RPM > 0 (default) |
| `all` | Show all fans including idle (RPM = 0) |

## Source Options

| Value | Description |
|-------|-------------|
| `auto` | Auto-detect best source |
| `dell` | Dell SMM driver (`dell_smm` hwmon) |
| `thinkpad` | ThinkPad fan (`/proc/acpi/ibm/fan`) |
| `hwmon` | Generic hwmon/sysfs |

## Format Options

| Value | Example Output (single fan) | Example Output (multiple fans) |
|-------|-----------------------------|---------------------------------|
| `icon_k` | `󰈐 2.5k RPM` (default) | `󰈐 2.5k \| 󰈐 3.0k RPM` |
| `icon` | `󰈐 2500 RPM` | `󰈐 2500 \| 󰈐 3000 RPM` |
| `rpm` | `2500 RPM` | `2500 \| 3000 RPM` |
| `krpm` | `2.5k RPM` | `2.5k \| 3.0k RPM` |
| `number` | `2500 RPM` | `2500 \| 3000 RPM` |

**Note:** The "RPM" suffix appears only once at the end of the output.

## States

| State | Condition |
|-------|-----------|
| `active` | Fan speed > 0 RPM |
| `inactive` | Fan not detected or 0 RPM |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Fan speed below warning threshold |
| `warning` | Fan speed >= warning threshold |
| `error` | Fan speed >= critical threshold |

## Context Values

| Context | RPM Range |
|---------|-----------|
| `silent` | 0 RPM |
| `quiet` | < 2000 RPM |
| `normal` | 2000-3999 RPM |
| `loud` | 4000-5499 RPM |
| `max` | >= 5500 RPM |

## Display Examples

**Single fan (icon_k format - default):**
```
󰈐 2.5k RPM
```

**Single fan (icon format):**
```
󰈐 2500 RPM
```

**Single fan (rpm format):**
```
2500 RPM
```

**Fast fan (above warning threshold):**
```
󰈑 4.5k RPM
```

**Multiple fans (icon_k format):**
```
󰈐 1.2k | 󰈐 1.9k | 󰈐 4.0k RPM
```

**Multiple fans (icon format):**
```
󰈐 1187 | 󰈐 1885 | 󰈐 4005 RPM
```

**Multiple fans (rpm format):**
```
1187 | 1885 | 4005 RPM
```

## Linux Fan Sources

### Dell Laptops
Uses `dell_smm` hwmon driver:
```
/sys/class/hwmon/hwmonX/name = "dell_smm"
/sys/class/hwmon/hwmonX/fan1_input
```

### ThinkPad Laptops
Uses ACPI interface:
```
/proc/acpi/ibm/fan
```

### Generic hwmon
Scans all hwmon devices:
```
/sys/class/hwmon/hwmon*/fan*_input
```

## macOS Fan Detection

Checks tools in order:
1. `osx-cpu-temp -f` - Most common
2. `smctemp -f` - Alternative
3. `istats fan speed` - Ruby-based

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No fan speed shown | Install `osx-cpu-temp` on macOS or check hwmon on Linux |
| Only one fan shown | Default `selection=active` shows all active fans; use `selection=all` to include idle |
| Fan shows 0 RPM | Fan may be idle; use `selection=all` to see idle fans |
| Dell fan not detected | Ensure `dell-smm-hwmon` kernel module is loaded |
| ThinkPad fan not detected | Enable `thinkpad_acpi` with `fan_control=1` |

## Related Plugins

- [PluginTemperature](PluginTemperature) - CPU temperature
- [PluginCpu](PluginCpu) - CPU usage
- [PluginGpu](PluginGpu) - GPU usage
