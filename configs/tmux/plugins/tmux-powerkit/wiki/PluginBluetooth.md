# Plugin: bluetooth

Display Bluetooth status and connected devices with battery information.

## Screenshot

```
󰂯 ON                           # Bluetooth on, no devices
󰂱 AirPods Pro (67%)            # Single device with battery
󰂱 AirPods Pro (L:68% / R:67%)  # TWS with individual batteries
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | macOS: `blueutil` (optional), `system_profiler`; Linux: `bluetoothctl` (optional), `hcitool` |
| Content Type | dynamic |
| Presence | conditional |

## Installation

```bash
# macOS (recommended for better device info)
brew install blueutil

# Linux (usually pre-installed)
# bluetoothctl is part of bluez package
sudo apt install bluez  # Debian/Ubuntu
sudo pacman -S bluez    # Arch
```

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "bluetooth"
```

## Configuration Example

```bash
set -g @powerkit_plugins "bluetooth"

# Display options
set -g @powerkit_plugin_bluetooth_show_device "true"
set -g @powerkit_plugin_bluetooth_show_battery "true"
set -g @powerkit_plugin_bluetooth_battery_type "min"
set -g @powerkit_plugin_bluetooth_format "all"
set -g @powerkit_plugin_bluetooth_max_length "50"

# Icons
set -g @powerkit_plugin_bluetooth_icon "󰂯"
set -g @powerkit_plugin_bluetooth_icon_off "󰂲"
set -g @powerkit_plugin_bluetooth_icon_connected "󰂱"

# Battery warning threshold
set -g @powerkit_plugin_bluetooth_battery_warning_threshold "20"

# Cache duration
set -g @powerkit_plugin_bluetooth_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_bluetooth_show_device` | bool | `true` | Show connected device name |
| `@powerkit_plugin_bluetooth_show_battery` | bool | `true` | Show device battery level |
| `@powerkit_plugin_bluetooth_battery_type` | string | `min` | Battery display: `min`, `left`, `right`, `case`, `all` |
| `@powerkit_plugin_bluetooth_format` | string | `all` | Device format: `first`, `count`, `all` |
| `@powerkit_plugin_bluetooth_max_length` | number | `50` | Maximum display length |
| `@powerkit_plugin_bluetooth_icon` | icon | `󰂯` | Icon when Bluetooth is on |
| `@powerkit_plugin_bluetooth_icon_off` | icon | `󰂲` | Icon when Bluetooth is off |
| `@powerkit_plugin_bluetooth_icon_connected` | icon | `󰂱` | Icon when device is connected |
| `@powerkit_plugin_bluetooth_battery_warning_threshold` | number | `20` | Low battery warning threshold (%) |
| `@powerkit_plugin_bluetooth_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_bluetooth_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Battery Type Options

| Value | Description | Example Output |
|-------|-------------|----------------|
| `min` | Minimum of L/R (default for TWS) | `67%` |
| `left` | Left earbud only | `L:68%` |
| `right` | Right earbud only | `R:67%` |
| `case` | Case battery only | `C:60%` |
| `all` | All batteries | `L:68% / R:67% / C:60%` |

## Format Options

| Value | Description | Example Output |
|-------|-------------|----------------|
| `first` | Show first connected device | `AirPods Pro (67%)` |
| `count` | Show device count | `2 devices` |
| `all` | Show all devices | `AirPods Pro \| Magic Mouse` |

## States

| State | Condition |
|-------|-----------|
| `active` | Bluetooth is on (with or without connected devices) |
| `inactive` | Bluetooth is off (plugin hidden) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `good` | Devices connected with good battery |
| `info` | Bluetooth on but no devices connected |
| `warning` | Connected device has low battery (< threshold) |

## Context Values

| Context | Condition |
|---------|-----------|
| `off` | Bluetooth is disabled |
| `on` | Bluetooth enabled, no connections |
| `connected` | One or more devices connected |

## Display Examples

**Bluetooth on, no devices:**
```
󰂯 ON
```

**Single device with battery:**
```
󰂱 AirPods Pro (67%)
```

**TWS with all batteries:**
```
󰂱 AirPods Pro (L:68% / R:67% / C:60%)
```

**Multiple devices:**
```
󰂱 AirPods Pro (67%) | Magic Mouse (85%)
```

**Device count format:**
```
󰂱 2 devices
```

## macOS Battery Detection

The plugin supports various battery reporting methods:
- **blueutil**: Direct battery query for most devices
- **system_profiler**: AirPods Left/Right/Case battery levels

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No devices shown | Ensure Bluetooth is on and devices are connected |
| No battery info | Some devices don't report battery; try `blueutil` on macOS |
| Wrong device name | Device name comes from system; check Bluetooth settings |
| Plugin hidden | Bluetooth is off; state becomes `inactive` |

## Related Plugins

- [PluginAudiodevices](PluginAudiodevices) - Audio output device selection
- [PluginVolume](PluginVolume) - System volume control
