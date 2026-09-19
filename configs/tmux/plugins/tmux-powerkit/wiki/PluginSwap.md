# Plugin: swap

Display swap memory usage with threshold-based coloring and graceful degradation on macOS.

## Screenshot

```
 45%        # OK - green (percentage mode)
 2.3G/8.0G  # OK - green (usage mode)
 5.7G free  # OK - green (free mode)
 84%        # Critical - red
swap active # Degraded - blue (macOS vm_stat fallback)
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, WSL |
| **Dependencies** | `sysctl`/`vm_stat` (macOS), `/proc/meminfo` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
set -g @powerkit_plugins "swap"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "swap"

# Display format: percent, usage, or free
set -g @powerkit_plugin_swap_format "percent"

# Thresholds (higher = worse)
set -g @powerkit_plugin_swap_warning_threshold "60"
set -g @powerkit_plugin_swap_critical_threshold "80"

# Icon
set -g @powerkit_plugin_swap_icon "󰓡"

# Cache duration (seconds)
set -g @powerkit_plugin_swap_cache_ttl "30"

# Optional: Include compressed memory (macOS only)
set -g @powerkit_plugin_swap_include_compressed "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_swap_format` | string | `usage` | Display format: `percent`, `usage`, or `free` |
| `@powerkit_plugin_swap_icon` | icon | `󰓡` | Swap/exchange icon |
| `@powerkit_plugin_swap_warning_threshold` | number | `60` | Warning threshold percentage |
| `@powerkit_plugin_swap_critical_threshold` | number | `80` | Critical threshold percentage |
| `@powerkit_plugin_swap_cache_ttl` | number | `30` | Cache duration in seconds |
| `@powerkit_plugin_swap_include_compressed` | bool | `false` | Include compressed memory (macOS only) |
| `@powerkit_plugin_swap_show_only_on_threshold` | bool | `false` | Only show when above warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Swap available with accurate data | Visible |
| `degraded` | Swap available but limited data (macOS vm_stat fallback) | Visible |
| `inactive` | No swap configured or unable to read | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Below warning threshold (< 60%) | Green |
| `info` | Degraded mode (macOS vm_stat) | Blue |
| `warning` | Between warning and critical (60-80%) | Yellow |
| `error` | Above critical threshold (> 80%) | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `normal_usage` | Swap usage below warning threshold |
| `high_usage` | Swap usage at warning level |
| `critical_usage` | Swap usage at critical level |

## Display Formats

### Percentage Mode (default)

Shows swap usage as percentage:

```
 84%
```

```bash
set -g @powerkit_plugin_swap_format "percent"
```

### Usage Mode

Shows used/total swap:

```
 3.3G/4.0G
```

```bash
set -g @powerkit_plugin_swap_format "usage"
```

### Free Mode

Shows available swap:

```
 648M free
```

```bash
set -g @powerkit_plugin_swap_format "free"
```

## Platform Support

| Platform | Method | Notes |
|----------|--------|-------|
| Linux | `/proc/meminfo` | Reads SwapTotal and SwapFree |
| WSL | `/proc/meminfo` | Standard Linux interface, no special handling |
| macOS (Primary) | `sysctl vm.swapusage` | Most accurate, provides total/used/free |
| macOS (Fallback) | `vm_stat` | Degraded mode - shows "swap active" or "no swap" |

### macOS Behavior

The plugin uses a **dual-method approach** on macOS:

1. **Primary Method (`sysctl vm.swapusage`)**: Provides accurate swap metrics similar to Linux
2. **Fallback Method (`vm_stat`)**: When sysctl is unavailable, uses swap activity as indicator
   - State: `degraded`
   - Health: `info` (blue)
   - Display: Shows "swap active" instead of percentage

This ensures the plugin provides useful information even when precise metrics aren't available.

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "swap"
```

### Show Used/Total

```bash
set -g @powerkit_plugins "swap"
set -g @powerkit_plugin_swap_format "usage"
```

### Show Free Space

```bash
set -g @powerkit_plugins "swap"
set -g @powerkit_plugin_swap_format "free"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "swap"
set -g @powerkit_plugin_swap_warning_threshold "50"
set -g @powerkit_plugin_swap_critical_threshold "75"
```

### Only Show When High

```bash
set -g @powerkit_plugins "swap"
set -g @powerkit_plugin_swap_show_only_on_threshold "true"
set -g @powerkit_plugin_swap_warning_threshold "40"
```

### Longer Cache for Swap (Changes Slowly)

```bash
set -g @powerkit_plugins "swap"
set -g @powerkit_plugin_swap_cache_ttl "60"
```

## No Swap Systems

The plugin gracefully handles systems without swap:

- **Containers/VMs**: Many containerized environments (Docker, LXC) don't configure swap
- **Behavior**: Plugin returns `inactive` state and is automatically hidden
- **Detection**: Checks for zero swap on Linux, no swap files on macOS

This ensures the plugin doesn't clutter your status bar on systems where swap isn't available.

## Troubleshooting

### Plugin Not Showing

**Possible causes:**
1. No swap configured on your system
   - Linux: Check with `swapon --show` or `cat /proc/swaps`
   - macOS: Check with `sysctl vm.swapusage`
2. Plugin hidden due to threshold setting
   - Check `@powerkit_plugin_swap_show_only_on_threshold` is false

### Shows "swap active" on macOS

This indicates the plugin is in **degraded mode** using `vm_stat` fallback:
- `sysctl vm.swapusage` is not available on your system
- Plugin can only detect swap activity, not precise usage
- This is informational - swap is being used but exact amount is unknown

### WSL Shows No Swap

WSL2 may not have swap configured by default:
- Check with `cat /proc/swaps` or `swapon --show`
- Configure swap in `.wslconfig` if needed
- Plugin will show when swap is enabled

### High Swap Usage

High swap usage (> 60%) indicates:
- Insufficient RAM for current workload
- Memory-intensive applications running
- Possible memory leak
- Consider: Adding more RAM or closing applications

## Performance Notes

- **Cache TTL**: Default 30 seconds (swap changes slowly)
- **Collection Time**: < 50ms on both Linux and macOS
- **System Impact**: Minimal - reads system files/sysctls only

## Related Plugins

- [PluginMemory](PluginMemory) - RAM usage monitoring
- [PluginCpu](PluginCpu) - CPU usage monitoring
- [PluginDisk](PluginDisk) - Disk usage monitoring
- [PluginLoadavg](PluginLoadavg) - System load average

## Technical Details

### Swap vs Memory

**Memory (RAM)**:
- Fast, volatile storage
- Cleared on reboot
- Used for active processes

**Swap**:
- Slower, disk-based storage
- Persists across reboots (when on disk)
- Used when RAM is full
- High swap usage = performance degradation

### Why Lower Thresholds?

Swap thresholds (60%/80%) are lower than memory thresholds (80%/90%) because:
- Swap usage indicates RAM exhaustion
- Swap I/O is much slower than RAM
- Even moderate swap usage impacts performance
- Better to warn earlier for swap than memory
