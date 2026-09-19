# Plugin: memory

Display memory usage percentage or absolute usage with threshold-based coloring.

## Screenshot

```
 45%        # OK - green (percentage mode)
 8.2G/16G   # OK - green (usage mode)
 85%        # Warning - yellow
 95%        # Critical - red
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `memory_pressure`/`vm_stat` (macOS), `/proc/meminfo` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
set -g @powerkit_plugins "memory"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "memory"

# Display format: percent or usage
set -g @powerkit_plugin_memory_format "percent"

# Thresholds (higher = worse)
set -g @powerkit_plugin_memory_warning_threshold "80"
set -g @powerkit_plugin_memory_critical_threshold "90"

# Icons
set -g @powerkit_plugin_memory_icon ""
set -g @powerkit_plugin_memory_icon_warning ""
set -g @powerkit_plugin_memory_icon_critical ""

# Cache duration (seconds)
set -g @powerkit_plugin_memory_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_memory_format` | string | `percent` | Display format: `percent` or `usage` |
| `@powerkit_plugin_memory_icon` | icon | `` | Default memory icon |
| `@powerkit_plugin_memory_icon_warning` | icon | `` | Icon when warning (empty = use default) |
| `@powerkit_plugin_memory_icon_critical` | icon | `` | Icon when critical (empty = use default) |
| `@powerkit_plugin_memory_warning_threshold` | number | `80` | Warning threshold percentage |
| `@powerkit_plugin_memory_critical_threshold` | number | `90` | Critical threshold percentage |
| `@powerkit_plugin_memory_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_memory_show_only_on_threshold` | bool | `false` | Only show when above warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Memory metrics available | Visible |
| `inactive` | Unable to read memory metrics | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Below warning threshold (< 80%) | Green |
| `warning` | Between warning and critical (80-90%) | Yellow |
| `error` | Above critical threshold (> 90%) | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `normal_load` | Memory usage below warning threshold |
| `high_load` | Memory usage at warning level |
| `critical_load` | Memory usage at critical level |

## Display Formats

### Percentage Mode (default)

Shows memory usage as percentage:

```
 72%
```

```bash
set -g @powerkit_plugin_memory_format "percent"
```

### Usage Mode

Shows used/total memory:

```
 8.2G/16.0G
```

```bash
set -g @powerkit_plugin_memory_format "usage"
```

## Platform Support

| Platform | Method | Notes |
|----------|--------|-------|
| macOS | `memory_pressure` | Most accurate, system-wide free % |
| macOS | `vm_stat` | Fallback (active + wired pages) |
| Linux | `/proc/meminfo` | Uses MemAvailable (kernel 3.14+) |
| Linux (old) | `/proc/meminfo` | Free + Buffers + Cached |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "memory"
```

### Show Used/Total

```bash
set -g @powerkit_plugins "memory"
set -g @powerkit_plugin_memory_format "usage"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "memory"
set -g @powerkit_plugin_memory_warning_threshold "70"
set -g @powerkit_plugin_memory_critical_threshold "85"
```

### Only Show When High

```bash
set -g @powerkit_plugins "memory"
set -g @powerkit_plugin_memory_show_only_on_threshold "true"
set -g @powerkit_plugin_memory_warning_threshold "60"
```

### Custom Icons

```bash
set -g @powerkit_plugins "memory"
set -g @powerkit_plugin_memory_icon ""
set -g @powerkit_plugin_memory_icon_warning ""
set -g @powerkit_plugin_memory_icon_critical ""
```

## Troubleshooting

### Inaccurate Readings

- macOS: Memory pressure gives most accurate readings
- Linux: MemAvailable is preferred over Free+Buffers+Cached

### High Values Despite Free Memory

- Modern OS uses available memory for disk cache
- This is normal - memory will be freed when applications need it
- MemAvailable accounts for this on Linux

### vm_stat Fallback on macOS

- If `memory_pressure` is unavailable, `vm_stat` is used
- vm_stat counts only active + wired pages as "used"
- This may show lower usage than expected

## Related Plugins

- [PluginCpu](PluginCpu) - CPU usage monitoring
- [PluginDisk](PluginDisk) - Disk usage monitoring
- [PluginLoadavg](PluginLoadavg) - System load average
