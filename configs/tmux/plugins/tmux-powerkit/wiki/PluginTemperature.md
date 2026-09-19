# Plugin: temperature

Display CPU/system temperature with multi-source support and threshold-based warnings.

## Screenshots

```
 45°C
 72°C
󱃂 88°C
 158°F
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | macOS: `osx-cpu-temp` or `smctemp` (optional), Linux: `sensors` (optional, can use sysfs) |
| Content Type | dynamic |
| Presence | conditional (hidden when sensor unavailable) |

## macOS Native Binary

This plugin uses a native macOS binary for efficient temperature reading via SMC (System Management Controller).

| Property | Value |
|----------|-------|
| **Binary** | `bin/powerkit-temperature` |
| **Source** | `src/native/macos/powerkit-temperature.m` |
| **Frameworks** | Foundation, IOKit |

### Automatic Download

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

### Manual Compilation

```bash
cd src/native/macos && make powerkit-temperature
cp powerkit-temperature ../../bin/
```

### Fallback

If the binary is not available and you decline the download, the plugin falls back to `osx-cpu-temp` or `smctemp`.

### Binary Features

The native binary provides:
- Direct SMC sensor reading (no shell overhead)
- Support for both Intel and Apple Silicon Macs
- List all available temperature sensors (`-l`)
- Query specific SMC key (`-s KEY`)
- Query all sensors (`-a`)

### macOS Temperature Sources

With the native binary, you can specify SMC keys directly:

| Source | Description | Common Keys |
|--------|-------------|-------------|
| `auto` | Highest CPU temperature | Auto-detected |
| `cpu-cluster` or `cpu` | CPU cluster temp | `Tp0f` (M-series), `TC0P` (Intel) |
| `gpu` | GPU temperature | `Tg0j` (M-series), `TG0D` (Intel) |
| `soc` | SoC temperature (Apple Silicon) | `Ts0S` |
| `battery` | Battery temperature | `TB0T` |
| `wifi` | WiFi module | `TW0P` |
| `Tp0f`, `TC0P`, etc. | Specific SMC key | Direct key access |

List available sensors:
```bash
./bin/powerkit-temperature -l
```

## Installation

### macOS

```bash
# Using Homebrew
brew install osx-cpu-temp

# Alternative: smctemp
brew install smctemp
```

### Linux

```bash
# Ubuntu/Debian
sudo apt install lm-sensors
sudo sensors-detect

# Fedora
sudo dnf install lm_sensors
sudo sensors-detect

# Arch
sudo pacman -S lm_sensors
sudo sensors-detect
```

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "temperature"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "temperature"

# Display options
set -g @powerkit_plugin_temperature_source "auto"
set -g @powerkit_plugin_temperature_unit "C"
set -g @powerkit_plugin_temperature_show_unit "true"
set -g @powerkit_plugin_temperature_hide_below_threshold ""

# Icons
set -g @powerkit_plugin_temperature_icon ""
set -g @powerkit_plugin_temperature_icon_warning ""
set -g @powerkit_plugin_temperature_icon_hot "󱃂"

# Thresholds (in Celsius, higher = worse)
set -g @powerkit_plugin_temperature_warning_threshold "70"
set -g @powerkit_plugin_temperature_critical_threshold "85"

# Cache
set -g @powerkit_plugin_temperature_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_temperature_source` | string | `auto` | Temperature source (see Sources section) |
| `@powerkit_plugin_temperature_unit` | string | `C` | Temperature unit: `C` (Celsius) or `F` (Fahrenheit) |
| `@powerkit_plugin_temperature_show_unit` | bool | `true` | Show unit symbol (°C/°F) |
| `@powerkit_plugin_temperature_hide_below_threshold` | number | `` | Hide plugin when temp is below this value (°C) |
| `@powerkit_plugin_temperature_icon` | icon | `` | Default temperature icon |
| `@powerkit_plugin_temperature_icon_warning` | icon | `` | Warning temperature icon (optional) |
| `@powerkit_plugin_temperature_icon_hot` | icon | `󱃂` | Critical temperature icon |
| `@powerkit_plugin_temperature_warning_threshold` | number | `70` | Warning threshold in °C |
| `@powerkit_plugin_temperature_critical_threshold` | number | `85` | Critical threshold in °C |
| `@powerkit_plugin_temperature_cache_ttl` | number | `5` | Cache duration in seconds |

## States

| State | Condition |
|-------|-----------|
| `active` | Temperature sensor available |
| `inactive` | No temperature sensor available (plugin hidden) |

## Health Levels

Thresholds are always in Celsius, even when displaying Fahrenheit.

| Level | Condition |
|-------|-----------|
| `ok` | Temperature < warning threshold |
| `warning` | Temperature >= warning threshold and < critical threshold |
| `error` | Temperature >= critical threshold |

## Context Values

| Context | Description |
|---------|-------------|
| `normal` | Temperature is within normal range |
| `warm` | Temperature is elevated (warning threshold) |
| `hot` | Temperature is critical |

## Temperature Sources

The plugin supports multiple temperature sources on Linux. Use the `source` option to select:

| Source | Description | Hardware |
|--------|-------------|----------|
| `auto` | Auto-detect best source | All |
| `cpu` or `coretemp` | Intel/AMD CPU package | Intel Core, AMD Ryzen |
| `cpu-pkg` or `x86_pkg_temp` | CPU package temp | Intel |
| `cpu-acpi` or `tcpu` | ACPI CPU temp | Generic |
| `nvme` or `ssd` | NVMe SSD temperature | NVMe drives |
| `wifi` or `iwlwifi` | WiFi module temp | Intel WiFi |
| `acpi` or `ambient` | System ambient temp | ACPI |
| `dell` or `dell_smm` | Dell laptop sensors | Dell systems |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "temperature"
```

### Display in Fahrenheit

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_unit "F"
```

### Hide Unit Symbol

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_show_unit "false"
```

### Show Only When Hot

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_hide_below_threshold "60"
```

### Aggressive Thresholds

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_warning_threshold "60"
set -g @powerkit_plugin_temperature_critical_threshold "75"
```

### Specific Temperature Source

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_source "cpu-pkg"
```

### NVMe SSD Temperature

```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_source "nvme"
```

## Display Format

| Condition | Output |
|-----------|--------|
| Celsius with unit | `45°C` |
| Fahrenheit with unit | `113°F` |
| Without unit | `45` or `113` |
| Below hide threshold | (hidden) |

## Platform-Specific Behavior

### macOS

Uses either `osx-cpu-temp` or `smctemp` to read CPU temperature from SMC (System Management Controller).

```bash
# Check temperature manually
osx-cpu-temp
# Output: 45.5°C

smctemp -c
# Output: 45.5
```

The plugin tries `osx-cpu-temp` first, then falls back to `smctemp`.

### Linux

Uses multiple detection methods in order:

1. **hwmon** - `/sys/class/hwmon/hwmon*/` (fastest, no external commands)
   - coretemp (Intel)
   - k10temp (AMD)
   - zenpower (AMD Zen)
   - nvme
   - iwlwifi
   - dell_smm

2. **thermal_zone** - `/sys/class/thermal/thermal_zone*/`
   - x86_pkg_temp
   - TCPU
   - INT3400

3. **sensors command** - fallback if sysfs unavailable

## Temperature Thresholds

Typical safe operating temperatures:

| Component | Normal | Warning | Critical |
|-----------|--------|---------|----------|
| Intel CPU | < 60°C | 60-80°C | > 80°C |
| AMD CPU | < 65°C | 65-85°C | > 85°C |
| NVMe SSD | < 50°C | 50-70°C | > 70°C |
| WiFi Module | < 60°C | 60-80°C | > 80°C |

Default thresholds (70°C/85°C) are conservative and work for most systems.

## Troubleshooting

### Plugin Not Showing (macOS)

1. Install temperature tool:
   ```bash
   brew install osx-cpu-temp
   ```

2. Verify it works:
   ```bash
   osx-cpu-temp
   ```

3. Test plugin:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin temperature
   ```

### Plugin Not Showing (Linux)

1. Check if sensors are available:
   ```bash
   # Check sysfs
   ls /sys/class/hwmon/hwmon*/temp*_input
   ls /sys/class/thermal/thermal_zone*/temp

   # Check sensors command
   sensors
   ```

2. Run sensor detection:
   ```bash
   sudo sensors-detect
   # Answer YES to all questions
   ```

3. Load kernel modules:
   ```bash
   # Intel
   sudo modprobe coretemp

   # AMD
   sudo modprobe k10temp

   # Generic
   sudo modprobe acpi_thermal
   ```

4. Test plugin:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin temperature
   ```

### Temperature Reading is 0

If temperature shows as 0°C:

1. Check sensor values manually:
   ```bash
   # Linux
   cat /sys/class/hwmon/hwmon0/temp1_input
   # Should show millidegrees (e.g., 45000 = 45°C)

   # macOS
   osx-cpu-temp
   ```

2. Try different source:
   ```bash
   set -g @powerkit_plugin_temperature_source "cpu-acpi"
   ```

3. Check sensors output:
   ```bash
   sensors | grep -i "core\|package\|tctl"
   ```

### Wrong Temperature Source

If the detected temperature seems wrong:

1. List all available sources:
   ```bash
   # List hwmon sensors
   for dir in /sys/class/hwmon/hwmon*/; do
       echo "=== $dir ==="
       cat "$dir/name"
       cat "$dir/temp"*_input 2>/dev/null | head -5
   done

   # List thermal zones
   for zone in /sys/class/thermal/thermal_zone*/; do
       echo "=== $zone ==="
       cat "$zone/type"
       cat "$zone/temp"
   done
   ```

2. Specify source explicitly:
   ```bash
   set -g @powerkit_plugin_temperature_source "cpu-pkg"
   ```

### Temperature Too High/Low

If reported temperature seems incorrect:

1. Compare with other tools:
   ```bash
   # Linux
   sensors
   cat /proc/cpuinfo | grep "cpu MHz"

   # macOS
   istats cpu temp  # if iStats installed
   ```

2. Check if laptop is throttling:
   ```bash
   # Linux
   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

   # macOS
   pmset -g therm
   ```

### Slow Performance

If temperature checks are slow:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_temperature_cache_ttl "10"
   ```

2. Check command performance:
   ```bash
   time osx-cpu-temp
   time sensors
   ```

3. Use sysfs instead of sensors command (Linux):
   - Plugin automatically prefers sysfs (faster)
   - Ensure sensors are in `/sys/class/hwmon/`

## Advanced Usage

### Combined System Monitoring

```bash
set -g @powerkit_plugins "cpu,temperature,fan,loadavg"
```

### Multiple Temperature Sources

To monitor multiple sources, you can't use the same plugin twice, but you can use smartkey:

```bash
set -g @powerkit_plugins "temperature,smartkey"
set -g TEMP_NVME "$(cat /sys/class/hwmon/hwmon2/temp1_input | awk '{print $1/1000}')°C"
set -g @powerkit_plugin_smartkey_key "TEMP_NVME"
```

### Conditional Display

Show only when temperature is high:
```bash
set -g @powerkit_plugins "temperature"
set -g @powerkit_plugin_temperature_hide_below_threshold "60"
set -g @powerkit_plugin_temperature_warning_threshold "60"
```

This creates a "hot indicator" that only appears when system is warm.

## Related Plugins

- [PluginCpu](PluginCpu) - CPU usage percentage
- [PluginFan](PluginFan) - Fan speed (macOS)
- [PluginLoadavg](PluginLoadavg) - System load average
- [PluginGpu](PluginGpu) - GPU usage and temperature
