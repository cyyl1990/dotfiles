# Plugin: loadavg

Display system load average with CPU core-aware thresholds.

## Screenshot

```
󰓅 1.25                    # 1-minute load average
󰓅 1.25 | 2.30 | 3.15      # All load averages (format=all)
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | None (uses `/proc/loadavg`, `sysctl`, or `uptime`) |
| **Content Type** | dynamic |
| **Presence** | always |

## Quick Start

```bash
set -g @powerkit_plugins "loadavg"
```

## Configuration Example

```bash
set -g @powerkit_plugins "loadavg"

# Display format: 1, 5, 15, or all
set -g @powerkit_plugin_loadavg_format "1"

# Separator (when format=all)
set -g @powerkit_plugin_loadavg_separator " | "

# Icon
set -g @powerkit_plugin_loadavg_icon "󰓅"

# Thresholds (multiplied by CPU cores)
set -g @powerkit_plugin_loadavg_warning_threshold_multiplier "2"
set -g @powerkit_plugin_loadavg_critical_threshold_multiplier "4"

# Cache
set -g @powerkit_plugin_loadavg_cache_ttl "10"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_loadavg_format` | string | `1` | Load average format: `1`, `5`, `15`, or `all` |
| `@powerkit_plugin_loadavg_separator` | string | ` \| ` | Separator between values (when format=all) |
| `@powerkit_plugin_loadavg_icon` | icon | `󰓅` | Load average icon |
| `@powerkit_plugin_loadavg_warning_threshold_multiplier` | number | `2` | Warning threshold (cores x multiplier) |
| `@powerkit_plugin_loadavg_critical_threshold_multiplier` | number | `4` | Critical threshold (cores x multiplier) |
| `@powerkit_plugin_loadavg_cache_ttl` | number | `10` | Cache duration in seconds |
| `@powerkit_plugin_loadavg_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Format Options

| Format | Description | Example Output |
|--------|-------------|----------------|
| `1` | 1-minute load average (default) | `1.25` |
| `5` | 5-minute load average | `2.30` |
| `15` | 15-minute load average | `3.15` |
| `all` | All three load averages | `1.25 \| 2.30 \| 3.15` |

## States

| State | Condition |
|-------|-----------|
| `active` | Load average data available (always) |

## Health Levels

Thresholds are multiplied by CPU core count for accurate system load assessment.

| Level | Condition |
|-------|-----------|
| `ok` | Load < (cores x warning_multiplier) |
| `warning` | Load >= (cores x warning_multiplier) and < (cores x critical_multiplier) |
| `error` | Load >= (cores x critical_multiplier) |

### Example (4-core system with defaults)

| Load | Calculation | Status | Color |
|------|-------------|--------|-------|
| 4.0 | 4 < (4 x 2) | Normal | Green |
| 10.0 | 10 >= (4 x 2) | Warning | Yellow |
| 18.0 | 18 >= (4 x 4) | Critical | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `normal_load` | Load is within normal operating range |
| `high_load` | Load is elevated (warning threshold) |
| `critical_load` | Load is critically high |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "loadavg"
```

### Show 5-Minute Average

```bash
set -g @powerkit_plugins "loadavg"
set -g @powerkit_plugin_loadavg_format "5"
```

### Show All Averages

```bash
set -g @powerkit_plugins "loadavg"
set -g @powerkit_plugin_loadavg_format "all"
set -g @powerkit_plugin_loadavg_separator " / "
```

### Custom Thresholds (More Sensitive)

```bash
set -g @powerkit_plugins "loadavg"
set -g @powerkit_plugin_loadavg_warning_threshold_multiplier "1"
set -g @powerkit_plugin_loadavg_critical_threshold_multiplier "2"
```

### Combined System Monitoring

```bash
set -g @powerkit_plugins "cpu,loadavg,memory,disk"
```

## Understanding Load Average

Load average represents the average number of processes waiting for CPU time over a period.

### The Three Values

- **1 minute**: Short-term load, good for detecting spikes
- **5 minutes**: Medium-term load, balanced view
- **15 minutes**: Long-term load, shows sustained usage

### Interpreting Values

On a system with **N cores**:

| Load Value | Status | Description |
|------------|--------|-------------|
| < N | Normal | System has spare capacity |
| N to N x 2 | Busy | System is fully utilized |
| N x 2 to N x 4 | Overloaded | Processes are waiting |
| > N x 4 | Critical | Severe resource contention |

## Platform-Specific Behavior

### macOS

Uses `sysctl -n vm.loadavg` for load average and `sysctl -n hw.ncpu` for core count.

```bash
sysctl -n vm.loadavg
sysctl -n hw.ncpu
```

### Linux

Uses `/proc/loadavg` for load average and `nproc` or `/proc/cpuinfo` for core count.

```bash
cat /proc/loadavg
nproc
```

## Troubleshooting

### Load Average Not Showing

1. Verify system commands are available:
   ```bash
   # macOS
   sysctl -n vm.loadavg

   # Linux
   cat /proc/loadavg
   ```

2. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin loadavg
   ```

### Thresholds Not Triggering

Check your core count and calculate expected thresholds:

```bash
# Get core count
# macOS
sysctl -n hw.ncpu

# Linux
nproc

# With 8 cores and default multipliers:
# Warning: 8 x 2 = 16
# Critical: 8 x 4 = 32
```

## Comparison with CPU Plugin

| Metric | loadavg | cpu |
|--------|---------|-----|
| What it shows | Processes waiting for CPU | Instant CPU usage % |
| Time scale | 1/5/15 minute average | Current snapshot |
| Best for | System saturation | Instant utilization |
| Value range | 0 to infinity | 0% to 100% |

Use both plugins together for comprehensive CPU monitoring:
```bash
set -g @powerkit_plugins "cpu,loadavg"
```

## Related Plugins

- [PluginCpu](PluginCpu) - CPU usage percentage
- [PluginUptime](PluginUptime) - System uptime
- [PluginMemory](PluginMemory) - Memory usage
