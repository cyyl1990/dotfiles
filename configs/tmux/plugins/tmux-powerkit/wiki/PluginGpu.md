# Plugin: gpu

Display GPU usage, memory, temperature, and frequency with multi-vendor support (NVIDIA, AMD, Intel, macOS).

## Screenshot

```
󰢮 45% | 409M                     # Usage and memory (NVIDIA/AMD)
󰢮  45% |  2.1G | 󰔏 72°C          # All metrics with icons
󰢮 78%                            # Warning - yellow
󰢮 95%                            # Critical - red
󰢮  60% | 󱓟 1150/1900MHz          # Intel GPU (usage + frequency)
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | See Platform Support table below |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Platform Support

| Platform | Backend | Metrics Available | Notes |
|----------|---------|-------------------|-------|
| Linux + NVIDIA | `nvidia-smi` | usage, memory, temp | Full support |
| Linux + AMD | sysfs (`gpu_busy_percent`) | usage, memory, temp | Full support via amdgpu driver |
| Linux + Intel | sysfs (i915/xe driver) | usage, freq | Frequency-based usage proxy |
| macOS | `powerkit-gpu` binary | usage, memory, temp | Apple Silicon and Intel Macs |

### Intel GPU Notes

Intel GPUs use shared system memory, so **memory metrics are not available**. The plugin provides:

- **Usage**: Calculated as `(current_frequency / max_frequency) * 100` - a proxy for GPU activity
- **Frequency**: Shows current and maximum frequency in MHz

Intel GPU metrics are read from:
- `/sys/class/drm/card{0,1}/gt/gt0/rps_cur_freq_mhz` - Current frequency
- `/sys/class/drm/card{0,1}/gt/gt0/rps_max_freq_mhz` - Maximum frequency

### AMD GPU Notes

AMD GPUs are detected via the amdgpu sysfs interface:
- `/sys/class/drm/card{0,1}/device/gpu_busy_percent` - GPU utilization
- `/sys/class/drm/card{0,1}/device/hwmon/hwmon*/temp1_input` - Temperature
- `/sys/class/drm/card{0,1}/device/mem_info_vram_used` - VRAM used
- `/sys/class/drm/card{0,1}/device/mem_info_vram_total` - VRAM total

## macOS Native Binary

This plugin uses a native macOS binary for efficient GPU metric collection on Apple Silicon and Intel Macs.

| Property | Value |
|----------|-------|
| **Binary** | `bin/powerkit-gpu` |
| **Source** | `src/native/macos/powerkit-gpu.m` |
| **Frameworks** | IOKit, Foundation |

### Automatic Download

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

### Manual Compilation

```bash
cd src/native/macos && make powerkit-gpu
cp powerkit-gpu ../../bin/
```

### Fallback

If the binary is not available and you decline the download, the plugin returns `inactive` state on macOS (no fallback method available).

## Installation

### Linux with NVIDIA GPU

```bash
# Install NVIDIA drivers (includes nvidia-smi)
sudo apt install nvidia-driver-XXX  # Ubuntu/Debian
sudo dnf install akmod-nvidia       # Fedora
```

### Linux with AMD GPU

AMD GPU support works out of the box with the amdgpu kernel driver (included in modern kernels).

### Linux with Intel GPU

Intel GPU support works out of the box with the i915 or xe kernel driver (included in modern kernels).

### macOS

The plugin uses the bundled `powerkit-gpu` native binary. No additional installation required if pre-compiled.

## Quick Start

```bash
set -g @powerkit_plugins "gpu"
```

## Configuration Example

```bash
set -g @powerkit_plugins "gpu"

# Metrics to display: usage, memory, temp, freq, all, or comma-separated
set -g @powerkit_plugin_gpu_metric "usage"
set -g @powerkit_plugin_gpu_separator " | "
set -g @powerkit_plugin_gpu_show_metric_icons "true"

# Memory format: memory_use, memory_usage, memory_percentage (NVIDIA/AMD only)
set -g @powerkit_plugin_gpu_memory_format "memory_usage"

# Icons
set -g @powerkit_plugin_gpu_icon "󰢮"
set -g @powerkit_plugin_gpu_icon_usage ""
set -g @powerkit_plugin_gpu_icon_memory ""
set -g @powerkit_plugin_gpu_icon_temp "󰔏"
set -g @powerkit_plugin_gpu_icon_freq "󱓟"

# Thresholds - Usage (%)
set -g @powerkit_plugin_gpu_usage_warning_threshold "70"
set -g @powerkit_plugin_gpu_usage_critical_threshold "90"

# Thresholds - Memory (% of allocation)
set -g @powerkit_plugin_gpu_memory_warning_threshold "70"
set -g @powerkit_plugin_gpu_memory_critical_threshold "90"

# Thresholds - Temperature (°C)
set -g @powerkit_plugin_gpu_temp_warning_threshold "70"
set -g @powerkit_plugin_gpu_temp_critical_threshold "85"

# Cache
set -g @powerkit_plugin_gpu_cache_ttl "3"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_gpu_metric` | string | `usage` | Metrics: `usage`, `memory`, `temp`, `freq`, `all`, or comma-separated |
| `@powerkit_plugin_gpu_separator` | string | ` \| ` | Separator between metrics |
| `@powerkit_plugin_gpu_show_metric_icons` | bool | `true` | Show icons next to each metric |
| `@powerkit_plugin_gpu_memory_format` | string | `memory_usage` | Memory format: `memory_use`, `memory_usage`, `memory_percentage` |
| `@powerkit_plugin_gpu_icon` | icon | `󰢮` | Main plugin icon |
| `@powerkit_plugin_gpu_icon_usage` | icon | `` | Usage metric icon |
| `@powerkit_plugin_gpu_icon_memory` | icon | `` | Memory metric icon |
| `@powerkit_plugin_gpu_icon_temp` | icon | `󰔏` | Temperature metric icon |
| `@powerkit_plugin_gpu_icon_freq` | icon | `󱓟` | Frequency metric icon |
| `@powerkit_plugin_gpu_usage_warning_threshold` | number | `70` | Usage warning threshold (%) |
| `@powerkit_plugin_gpu_usage_critical_threshold` | number | `90` | Usage critical threshold (%) |
| `@powerkit_plugin_gpu_memory_warning_threshold` | number | `70` | Memory warning threshold (%) |
| `@powerkit_plugin_gpu_memory_critical_threshold` | number | `90` | Memory critical threshold (%) |
| `@powerkit_plugin_gpu_temp_warning_threshold` | number | `70` | Temperature warning threshold (°C) |
| `@powerkit_plugin_gpu_temp_critical_threshold` | number | `85` | Temperature critical threshold (°C) |
| `@powerkit_plugin_gpu_cache_ttl` | number | `3` | Cache duration in seconds |
| `@powerkit_plugin_gpu_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Metric Options

| Value | Description | Example | Availability |
|-------|-------------|---------|--------------|
| `usage` | GPU utilization percentage | `45%` | All GPUs |
| `memory` | GPU memory (format configurable) | `409M` or `409M/4.1G` | NVIDIA, AMD, macOS |
| `temp` | GPU temperature | `72°C` | NVIDIA, AMD, macOS |
| `freq` | Current/max frequency | `1150/1900MHz` | Intel (others on request) |
| `all` | All available metrics | Varies by GPU type | All GPUs |

> **Note**: When `metric="all"` is used:
> - **NVIDIA/AMD/macOS**: Expands to `usage,memory,temp`
> - **Intel**: Expands to `usage,freq` (memory and temp not available)

## Memory Format Options

| Format | Description | Example |
|--------|-------------|---------|
| `memory_use` | Used memory only | `409M` |
| `memory_usage` | Used / Total | `409M/4.1G` |
| `memory_percentage` | Percentage of allocation | `10%` |

> **Note**: Memory metrics are only available for NVIDIA, AMD, and macOS GPUs. Intel GPUs use shared system memory.

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | GPU detected and readable | Visible |
| `inactive` | No supported GPU found | Hidden |

## Health Levels

Health is determined by the worst status across all displayed metrics.

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | All metrics below warning thresholds | Green |
| `warning` | Any metric between warning and critical | Yellow |
| `error` | Any metric above critical threshold | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `idle` | GPU usage is 0% |
| `light` | GPU usage < 30% |
| `moderate` | GPU usage 30-70% |
| `heavy` | GPU usage > 70% |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "gpu"
```

### Intel GPU - Show Usage and Frequency

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "usage,freq"
```

### Show All Metrics

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "all"
```

### Usage Only

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "usage"
```

### Memory with Percentage (NVIDIA/AMD)

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "memory"
set -g @powerkit_plugin_gpu_memory_format "memory_percentage"
```

### Detailed Memory Display (NVIDIA/AMD)

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "memory"
set -g @powerkit_plugin_gpu_memory_format "memory_usage"
```

### Without Metric Icons

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "usage,temp"
set -g @powerkit_plugin_gpu_show_metric_icons "false"
```

### Custom Separator

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_metric "usage,memory,temp"
set -g @powerkit_plugin_gpu_separator " - "
```

### Gaming/ML Thresholds

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_usage_warning_threshold "80"
set -g @powerkit_plugin_gpu_usage_critical_threshold "95"
set -g @powerkit_plugin_gpu_temp_warning_threshold "75"
set -g @powerkit_plugin_gpu_temp_critical_threshold "90"
```

### Show Only When Active

```bash
set -g @powerkit_plugins "gpu"
set -g @powerkit_plugin_gpu_show_only_on_threshold "true"
set -g @powerkit_plugin_gpu_usage_warning_threshold "10"
```

## GPU Detection Commands

### NVIDIA GPU

```bash
# GPU utilization
nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits

# Memory used/total
nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits
nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

# Temperature
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits
```

### AMD GPU

```bash
# GPU utilization
cat /sys/class/drm/card0/device/gpu_busy_percent

# Temperature (millidegrees)
cat /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input

# VRAM
cat /sys/class/drm/card0/device/mem_info_vram_used
cat /sys/class/drm/card0/device/mem_info_vram_total
```

### Intel GPU

```bash
# Current frequency (MHz)
cat /sys/class/drm/card1/gt/gt0/rps_cur_freq_mhz

# Maximum frequency (MHz)
cat /sys/class/drm/card1/gt/gt0/rps_max_freq_mhz
```

## Troubleshooting

### GPU Not Detected

1. Check which GPU you have:
   ```bash
   lspci | grep -i vga
   ```

2. For NVIDIA - check if nvidia-smi works:
   ```bash
   nvidia-smi
   ```

3. For AMD - check if sysfs files exist:
   ```bash
   ls /sys/class/drm/card*/device/gpu_busy_percent
   ```

4. For Intel - check if frequency files exist:
   ```bash
   ls /sys/class/drm/card*/gt/gt0/rps_cur_freq_mhz
   ```

5. For macOS - check if powerkit-gpu binary exists:
   ```bash
   ls -la ~/.tmux/plugins/tmux-powerkit/bin/powerkit-gpu
   ```

6. Compile the binary if missing (macOS):
   ```bash
   cd ~/.tmux/plugins/tmux-powerkit/src/native/macos && make powerkit-gpu
   cp powerkit-gpu ../../bin/
   ```

### Plugin Shows "Inactive"

- Normal on systems without a supported GPU
- For integrated Intel graphics, ensure the i915 or xe driver is loaded
- Verify GPU detection commands work (see above)

### Intel GPU Shows High Usage When Idle

The frequency-based usage calculation may show non-zero values even when idle because:
- The GPU maintains a minimum frequency
- Power management may boost frequency briefly

This is normal behavior and reflects the GPU's frequency state, not actual computational workload.

### Multi-GPU Systems

Currently shows data for the first detected GPU only. Multi-GPU selection is a future enhancement.

## Performance Notes

- nvidia-smi is relatively fast (~10-50ms)
- AMD sysfs reads are very fast (~1ms)
- Intel sysfs reads are very fast (~1ms)
- Default cache TTL is 3 seconds
- Higher cache_ttl recommended for battery-powered devices

## Data Stored

The plugin stores the following data via `plugin_data_set`:

| Key | Description | Availability |
|-----|-------------|--------------|
| `gpu_type` | `nvidia`, `amd`, `intel`, or `macos` | All |
| `available` | `1` if GPU detected, `0` otherwise | All |
| `usage` | GPU utilization percentage | All |
| `mem_used_mb` | Memory used in MB | NVIDIA, AMD, macOS |
| `mem_total_mb` | Total memory in MB | NVIDIA, AMD, macOS |
| `temp` | Temperature in °C | NVIDIA, AMD, macOS |
| `freq_cur` | Current frequency in MHz | Intel |
| `freq_max` | Maximum frequency in MHz | Intel |

## Related Plugins

- [PluginCpu](PluginCpu) - CPU usage monitoring
- [PluginMemory](PluginMemory) - Memory usage
- [PluginTemperature](PluginTemperature) - CPU temperature
- [PluginFan](PluginFan) - Fan speed monitoring
