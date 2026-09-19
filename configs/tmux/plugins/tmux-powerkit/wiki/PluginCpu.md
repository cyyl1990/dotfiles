# Plugin: cpu

Display CPU usage percentage with threshold-based coloring.

## Screenshot

```
 45%    # OK - green
 75%    # Warning - yellow
 95%    # Critical - red
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `top`/`iostat` (macOS), `/proc/stat` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
set -g @powerkit_plugins "cpu"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "cpu"

# Thresholds (higher = worse)
set -g @powerkit_plugin_cpu_warning_threshold "70"
set -g @powerkit_plugin_cpu_critical_threshold "90"

# Icons
set -g @powerkit_plugin_cpu_icon ""
set -g @powerkit_plugin_cpu_icon_warning ""
set -g @powerkit_plugin_cpu_icon_critical ""

# Sampling interval for Linux (seconds)
set -g @powerkit_plugin_cpu_sample_interval "0.1"

# Cache duration (seconds)
set -g @powerkit_plugin_cpu_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_cpu_icon` | icon | `` | Default CPU icon |
| `@powerkit_plugin_cpu_icon_warning` | icon | `` | Icon when warning (empty = use default) |
| `@powerkit_plugin_cpu_icon_critical` | icon | `` | Icon when critical (empty = use default) |
| `@powerkit_plugin_cpu_warning_threshold` | number | `70` | Warning threshold percentage |
| `@powerkit_plugin_cpu_critical_threshold` | number | `90` | Critical threshold percentage |
| `@powerkit_plugin_cpu_sample_interval` | number | `0.1` | Sampling interval in seconds (Linux only) |
| `@powerkit_plugin_cpu_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_cpu_show_only_on_threshold` | bool | `false` | Only show when above warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | CPU metrics available | Visible |
| `inactive` | Unable to read CPU metrics | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Below warning threshold (< 70%) | Green |
| `warning` | Between warning and critical (70-90%) | Yellow |
| `error` | Above critical threshold (> 90%) | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `normal_load` | CPU usage below warning threshold |
| `high_load` | CPU usage at warning level |
| `critical_load` | CPU usage at critical level |

## Platform Support

| Platform | Method | Notes |
|----------|--------|-------|
| macOS | `top -l 1` | Most accurate, single sample |
| macOS | `iostat` | Fallback |
| macOS | `ps` | Last resort fallback |
| Linux | `/proc/stat` | Delta sampling for accuracy |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "cpu"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "cpu"
set -g @powerkit_plugin_cpu_warning_threshold "60"
set -g @powerkit_plugin_cpu_critical_threshold "85"
```

### Only Show When High

```bash
set -g @powerkit_plugins "cpu"
set -g @powerkit_plugin_cpu_show_only_on_threshold "true"
set -g @powerkit_plugin_cpu_warning_threshold "50"
```

### Custom Icons

```bash
set -g @powerkit_plugins "cpu"
set -g @powerkit_plugin_cpu_icon ""
set -g @powerkit_plugin_cpu_icon_warning ""
set -g @powerkit_plugin_cpu_icon_critical ""
```

### Faster Sampling (Linux)

```bash
set -g @powerkit_plugins "cpu"
set -g @powerkit_plugin_cpu_sample_interval "0.05"
```

## Troubleshooting

### Inaccurate Readings on macOS

- The `top` command provides accurate readings but takes ~1 second
- If values seem off, try increasing cache_ttl

### High CPU Usage from Plugin

- Increase `sample_interval` on Linux
- Increase `cache_ttl` to reduce update frequency

### Always Shows 0%

- Check if `/proc/stat` exists (Linux)
- Verify `top` command works (macOS)

## Related Plugins

- [PluginMemory](PluginMemory) - Memory usage monitoring
- [PluginLoadavg](PluginLoadavg) - System load average
- [PluginTemperature](PluginTemperature) - CPU temperature
- [PluginGpu](PluginGpu) - GPU usage monitoring
