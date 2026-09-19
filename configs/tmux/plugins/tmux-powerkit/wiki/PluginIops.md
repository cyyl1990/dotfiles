# Plugin: iops

Display disk I/O throughput (read/write bytes per second).

## Screenshot

```
󰋊 125K/s  | 45K/s     # Read and write throughput
󰋊 1.2M/s  | 890K/s   # Higher activity
󰋊 45M/s              # Write only
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `ioreg` (macOS), `/proc/diskstats` (Linux) |
| **Content Type** | dynamic |
| **Presence** | always |

## Quick Start

```bash
set -g @powerkit_plugins "iops"
```

## Configuration Example

```bash
set -g @powerkit_plugins "iops"

# What to show: both, read, or write
set -g @powerkit_plugin_iops_show "both"

# Icons
set -g @powerkit_plugin_iops_icon "󰋊"
set -g @powerkit_plugin_iops_icon_read "󰁞"
set -g @powerkit_plugin_iops_icon_write "󰁆"

# Separator between read/write
set -g @powerkit_plugin_iops_separator " | "

# Thresholds (in bytes/s)
set -g @powerkit_plugin_iops_warning_threshold "104857600"   # 100MB/s
set -g @powerkit_plugin_iops_critical_threshold "524288000"  # 500MB/s

# Cache
set -g @powerkit_plugin_iops_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_iops_show` | string | `both` | What to show: `both`, `read`, `write` |
| `@powerkit_plugin_iops_icon` | icon | `󰋊` | Main plugin icon |
| `@powerkit_plugin_iops_icon_read` | icon | `󰁞` | Read throughput icon (arrow up) |
| `@powerkit_plugin_iops_icon_write` | icon | `󰁆` | Write throughput icon (arrow down) |
| `@powerkit_plugin_iops_separator` | string | ` \| ` | Separator between read/write values |
| `@powerkit_plugin_iops_warning_threshold` | number | `104857600` | Warning threshold (bytes/s, ~100MB/s) |
| `@powerkit_plugin_iops_critical_threshold` | number | `524288000` | Critical threshold (bytes/s, ~500MB/s) |
| `@powerkit_plugin_iops_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_iops_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Display Options

| Value | Description | Example Output |
|-------|-------------|----------------|
| `both` | Show read and write (default) | `125K/s 󰁞 \| 45K/s 󰁆` |
| `read` | Show read only | `125K/s 󰁞` |
| `write` | Show write only | `45K/s 󰁆` |

## States

| State | Condition |
|-------|-----------|
| `active` | I/O statistics available (always) |

## Health Levels

Health is based on total throughput (read + write combined).

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Total throughput < 100MB/s | Green |
| `warning` | Total throughput >= 100MB/s and < 500MB/s | Yellow |
| `error` | Total throughput >= 500MB/s | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `idle` | No I/O activity (0 bytes/s) |
| `read_heavy` | Read > 2x write throughput |
| `write_heavy` | Write > 2x read throughput |
| `balanced` | Similar read and write activity |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "iops"
```

### Show Read Only

```bash
set -g @powerkit_plugins "iops"
set -g @powerkit_plugin_iops_show "read"
```

### Show Write Only

```bash
set -g @powerkit_plugins "iops"
set -g @powerkit_plugin_iops_show "write"
```

### Custom Thresholds for NVMe

```bash
set -g @powerkit_plugins "iops"
set -g @powerkit_plugin_iops_warning_threshold "524288000"   # 500MB/s
set -g @powerkit_plugin_iops_critical_threshold "2147483648" # 2GB/s
```

### Show Only When Active

```bash
set -g @powerkit_plugins "iops"
set -g @powerkit_plugin_iops_show_only_on_threshold "true"
set -g @powerkit_plugin_iops_warning_threshold "10485760"  # 10MB/s
```

### Custom Separator

```bash
set -g @powerkit_plugins "iops"
set -g @powerkit_plugin_iops_separator " - "
```

## Platform Detection Methods

### macOS

Uses `ioreg` to read IOBlockStorageDriver statistics:
- Reads bytes from all disks combined
- Calculates delta between measurements
- Returns bytes/second throughput

```bash
# Manual check
ioreg -c IOBlockStorageDriver -r -w 0 | grep "Bytes (Read)"
ioreg -c IOBlockStorageDriver -r -w 0 | grep "Bytes (Write)"
```

### Linux

Uses `/proc/diskstats` to read sector counts:
- Reads from main disks only (sda, nvme0n1, vda - not partitions)
- Converts sectors to bytes (512 bytes per sector)
- Calculates delta between measurements

```bash
# Manual check
cat /proc/diskstats | grep -E "sd[a-z]|nvme[0-9]+n[0-9]+" | grep -v "[0-9]$"
```

## Threshold Reference

| Bytes/s | Human Readable | Typical Use Case |
|---------|----------------|------------------|
| 1048576 | 1MB/s | Low activity |
| 10485760 | 10MB/s | Normal file operations |
| 104857600 | 100MB/s | Heavy I/O (default warning) |
| 524288000 | 500MB/s | Very heavy I/O (default critical) |
| 1073741824 | 1GB/s | SSD sequential read |
| 2147483648 | 2GB/s | NVMe sequential read |

## Display Format

Throughput is automatically formatted to human-readable units:

| Raw Value | Display |
|-----------|---------|
| 500 | 500B/s |
| 1500 | 1.5K/s |
| 1500000 | 1.5M/s |
| 1500000000 | 1.5G/s |

## Troubleshooting

### No Data Showing

1. Check if stats are available:
   ```bash
   # macOS
   ioreg -c IOBlockStorageDriver -r -w 0 | grep Statistics

   # Linux
   cat /proc/diskstats
   ```

2. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin iops
   ```

### Values Always Zero

- First measurement returns 0 (need baseline)
- Wait for second update cycle (cache_ttl seconds)
- Try generating some I/O: `dd if=/dev/zero of=/tmp/test bs=1M count=100`

### Slow Performance

Increase cache TTL to reduce measurement frequency:
```bash
set -g @powerkit_plugin_iops_cache_ttl "10"
```

## Performance Notes

- Uses delta calculation between measurements
- Default cache TTL is 5 seconds
- Lower values give more responsive readings but use more CPU
- Cache stores previous measurement state for delta calculation

## Related Plugins

- [PluginDisk](PluginDisk) - Disk space usage
- [PluginCpu](PluginCpu) - CPU usage monitoring
- [PluginNetspeed](PluginNetspeed) - Network traffic monitoring
