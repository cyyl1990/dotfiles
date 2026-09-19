# Plugin: uptime

Display system uptime in a human-readable format.

## Screenshots

```
 2d 5h
 25d 3h
 3h 45m
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux, FreeBSD |
| Dependencies | `uptime` (built-in), `sysctl` (macOS) |
| Content Type | dynamic |
| Presence | always |

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "uptime"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "uptime"

# Icons
set -g @powerkit_plugin_uptime_icon ""

# Cache (uptime changes slowly, default is 5 minutes)
set -g @powerkit_plugin_uptime_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_uptime_icon` | icon | `` | Uptime icon |
| `@powerkit_plugin_uptime_cache_ttl` | number | `300` | Cache duration in seconds (default: 5 minutes) |

## States

| State | Condition |
|-------|-----------|
| `active` | Uptime data is available (always) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Normal operation (always) |

## Context Values

| Context | Description |
|---------|-------------|
| `days` | Uptime is measured in days |
| `hours` | Uptime is measured in hours |
| `minutes` | Uptime is measured in minutes |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "uptime"
```

### Custom Icon

```bash
set -g @powerkit_plugins "uptime"
set -g @powerkit_plugin_uptime_icon "󰔟"
```

### Faster Cache Updates

```bash
set -g @powerkit_plugins "uptime"
set -g @powerkit_plugin_uptime_cache_ttl "30"
```

### Combined with System Monitoring

```bash
set -g @powerkit_plugins "hostname,uptime,loadavg,cpu,memory"
```

## Display Format

The plugin automatically formats uptime based on duration:

| Duration | Format | Example |
|----------|--------|---------|
| < 1 hour | `Xm` | `45m` |
| < 1 day | `Xh Ym` | `3h 45m` |
| < 10 days | `Xd Yh` | `2d 5h` |
| >= 10 days | `Xd` | `25d` |

## Troubleshooting

### Uptime Not Showing

1. Verify uptime command is available:
   ```bash
   which uptime
   ```

2. Check if plugin is in the list:
   ```bash
   tmux show-options -g | grep powerkit_plugins
   ```

3. Verify plugin data collection:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin uptime
   ```

### Incorrect Uptime Value

On macOS, the plugin uses `sysctl kern.boottime` for accurate uptime calculation. On Linux, it reads from `/proc/uptime`.

If values seem incorrect:
- macOS: Check `sysctl kern.boottime`
- Linux: Check `cat /proc/uptime`

## Related Plugins

- [PluginHostname](PluginHostname) - Display system hostname
- [PluginLoadavg](PluginLoadavg) - Display system load average
- [PluginCpu](PluginCpu) - Display CPU usage
