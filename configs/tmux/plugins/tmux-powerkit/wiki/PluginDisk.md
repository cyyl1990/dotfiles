# Plugin: disk

Display disk usage for one or more mount points with multiple display formats.

## Screenshot

```
 root 45%              # Single mount, percentage
 root 45% | home 72%   # Multiple mounts
 root 234.5G/500.0G    # Usage format
 root 265.5G           # Free space format
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `df` (built-in) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
set -g @powerkit_plugins "disk"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "disk"

# Mount points to monitor (comma-separated)
set -g @powerkit_plugin_disk_mounts "/"
# Multiple mounts: set -g @powerkit_plugin_disk_mounts "/,/home,/data"

# Display format: percent, usage, or free
set -g @powerkit_plugin_disk_format "percent"

# Separator between mount points
set -g @powerkit_plugin_disk_separator " | "

# Show mount point label
set -g @powerkit_plugin_disk_show_label "true"

# Thresholds (higher = worse)
set -g @powerkit_plugin_disk_warning_threshold "70"
set -g @powerkit_plugin_disk_critical_threshold "90"

# Icons
set -g @powerkit_plugin_disk_icon ""
set -g @powerkit_plugin_disk_icon_warning ""
set -g @powerkit_plugin_disk_icon_critical ""

# Cache duration (seconds)
set -g @powerkit_plugin_disk_cache_ttl "120"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_disk_mounts` | string | `/` | Comma-separated list of mount points |
| `@powerkit_plugin_disk_format` | string | `percent` | Display format: `percent`, `usage`, `free` |
| `@powerkit_plugin_disk_separator` | string | ` \| ` | Separator between mount points |
| `@powerkit_plugin_disk_show_label` | bool | `true` | Show mount point label before value |
| `@powerkit_plugin_disk_icon` | icon | `` | Default disk icon |
| `@powerkit_plugin_disk_icon_warning` | icon | `` | Icon when warning (empty = use default) |
| `@powerkit_plugin_disk_icon_critical` | icon | `` | Icon when critical (empty = use default) |
| `@powerkit_plugin_disk_warning_threshold` | number | `70` | Warning threshold percentage |
| `@powerkit_plugin_disk_critical_threshold` | number | `90` | Critical threshold percentage |
| `@powerkit_plugin_disk_cache_ttl` | number | `120` | Cache duration in seconds (2 minutes) |
| `@powerkit_plugin_disk_show_only_on_threshold` | bool | `false` | Only show when above warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | At least one mount point accessible | Visible |
| `inactive` | No mount points accessible | Hidden |

## Health Levels

Health is based on the **highest** usage across all monitored mount points.

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | All mounts below warning (< 70%) | Green |
| `warning` | Any mount between warning and critical (70-90%) | Yellow |
| `error` | Any mount above critical (> 90%) | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `normal_usage` | All disks below warning threshold |
| `high_usage` | At least one disk at warning level |
| `critical_usage` | At least one disk at critical level |

## Display Formats

### Percentage Mode (default)

Shows disk usage as percentage:

```
root 72%
```

```bash
set -g @powerkit_plugin_disk_format "percent"
```

### Usage Mode

Shows used/total space:

```
root 234.5G/500.0G
```

```bash
set -g @powerkit_plugin_disk_format "usage"
```

### Free Space Mode

Shows available free space:

```
root 265.5G
```

```bash
set -g @powerkit_plugin_disk_format "free"
```

## Mount Point Labels

Labels are automatically generated from mount paths:

| Mount Path | Label |
|------------|-------|
| `/` | `root` |
| `/home` | `home` |
| `/boot` | `boot` |
| `/tmp` | `tmp` |
| `/var` | `var` |
| `/opt` | `opt` |
| `/mnt/data` | `data` |
| `/media/usb` | `usb` |
| `/Volumes/Backup` | `Backup` |

## macOS APFS Notes

On macOS with APFS, the root filesystem (`/`) is a read-only snapshot. The plugin automatically redirects to `/System/Volumes/Data` for accurate readings.

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "disk"
```

### Multiple Mount Points

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_mounts "/,/home,/data"
```

### Show Free Space

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_format "free"
```

### Without Labels

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_show_label "false"
```

### Custom Separator

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_mounts "/,/home"
set -g @powerkit_plugin_disk_separator " - "
```

### Only Show When Running Low

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_show_only_on_threshold "true"
set -g @powerkit_plugin_disk_warning_threshold "80"
```

### External Drives (macOS)

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_mounts "/,/Volumes/Backup,/Volumes/Data"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "disk"
set -g @powerkit_plugin_disk_warning_threshold "80"
set -g @powerkit_plugin_disk_critical_threshold "95"
```

## Troubleshooting

### Mount Point Not Found

- Verify the mount point exists: `df -h /path`
- Check for typos in the path
- Ensure the filesystem is mounted

### Wrong Values on macOS

- The plugin automatically uses `/System/Volumes/Data` for root (`/`)
- This is correct behavior for APFS filesystems

### Slow Updates

- Increase `cache_ttl` to reduce `df` calls
- Default is 120 seconds (2 minutes)

## Related Plugins

- [PluginIops](PluginIops) - Disk I/O operations
- [PluginMemory](PluginMemory) - Memory usage
- [PluginCpu](PluginCpu) - CPU usage
