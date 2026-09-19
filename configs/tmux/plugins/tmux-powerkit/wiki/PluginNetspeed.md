# Plugin: netspeed

Display real-time network traffic with upload and download speeds.

> **Note:** This plugin was renamed from `network` to `netspeed` to better reflect its purpose (speed monitoring) and avoid confusion with other network-related plugins.

## Screenshot

```
 ↓125K ↑45K   # Normal traffic - green/ok
 ↓2.5M ↑850K  # High traffic - green/ok
 ↓0K ↑0K      # Idle - green/ok
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `ifstat` (preferred) or `netstat`/`sysfs` |
| **Content Type** | dynamic |
| **Presence** | always |

## Installation

```bash
# macOS
brew install ifstat

# Linux (Debian/Ubuntu)
sudo apt install ifstat

# Linux (Fedora)
sudo dnf install ifstat

# Linux (Arch)
sudo pacman -S ifstat
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "netspeed"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "netspeed"

# Network interface (auto-detect if not set)
set -g @powerkit_plugin_netspeed_interface "auto"

# Display mode: both, upload, download
set -g @powerkit_plugin_netspeed_display "both"
set -g @powerkit_plugin_netspeed_separator " | "

# Icons
set -g @powerkit_plugin_netspeed_icon "󰈀"
set -g @powerkit_plugin_netspeed_icon_upload "󰕒"
set -g @powerkit_plugin_netspeed_icon_download "󰇚"

# Cache duration (seconds)
set -g @powerkit_plugin_netspeed_cache_ttl "2"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_netspeed_interface` | string | `auto` | Network interface to monitor (auto-detects active interface) |
| `@powerkit_plugin_netspeed_display` | enum | `both` | What to display: `both`, `upload`, `download` |
| `@powerkit_plugin_netspeed_separator` | string | ` \| ` | Separator between upload and download speeds |
| `@powerkit_plugin_netspeed_icon` | icon | `󰈀` | Main plugin icon |
| `@powerkit_plugin_netspeed_icon_upload` | icon | `󰕒` | Upload speed icon (shown before upload value) |
| `@powerkit_plugin_netspeed_icon_download` | icon | `󰇚` | Download speed icon (shown before download value) |
| `@powerkit_plugin_netspeed_cache_ttl` | number | `2` | Cache duration in seconds |
| `@powerkit_plugin_netspeed_show_only_on_threshold` | bool | `false` | Only show when traffic detected |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Network interface available | Visible |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Network active | Green |

## Context Values

| Context | Description |
|---------|-------------|
| `idle` | No network activity (0 KB/s up and down) |
| `downloading` | Download speed > upload speed |
| `uploading` | Upload speed > download speed |
| `active` | Balanced traffic or equal speeds |

## Speed Display Format

The plugin automatically formats speeds for readability:

| Range | Format | Example |
|-------|--------|---------|
| < 1 MB/s | KB/s | `125K` |
| ≥ 1 MB/s | MB/s | `2.5M` |

## Interface Detection

### Auto Mode (default)

Automatically detects the active network interface:

- **macOS**: Uses `route -n get default`
- **Linux**: Uses `ip route` to find default interface

### Manual Mode

Specify interface explicitly:

```bash
set -g @powerkit_plugin_netspeed_interface "en0"     # macOS WiFi
set -g @powerkit_plugin_netspeed_interface "eth0"    # Linux Ethernet
set -g @powerkit_plugin_netspeed_interface "wlan0"   # Linux WiFi
```

## Detection Methods

The plugin tries multiple methods in order of preference:

| Method | Priority | Accuracy | Speed |
|--------|----------|----------|-------|
| `ifstat` | 1 | High | Fast |
| `/sys/class/net` | 2 | Medium | Medium |
| Fallback | 3 | Low | Slow |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "netspeed"
```

### Show Only Download Speed

```bash
set -g @powerkit_plugins "netspeed"
set -g @powerkit_plugin_netspeed_display "download"
```

### Show Only Upload Speed

```bash
set -g @powerkit_plugins "netspeed"
set -g @powerkit_plugin_netspeed_display "upload"
```

### Monitor Specific Interface

```bash
set -g @powerkit_plugins "netspeed"
set -g @powerkit_plugin_netspeed_interface "eth0"
```

### Custom Separator

```bash
set -g @powerkit_plugins "netspeed"
set -g @powerkit_plugin_netspeed_separator " | "
```

Output: ` ↓125K | ↑45K`

### Show Only When Active

```bash
set -g @powerkit_plugins "netspeed"
set -g @powerkit_plugin_netspeed_show_only_on_threshold "true"
```

## Common Interface Names

### macOS
- `en0` - Built-in WiFi/Ethernet
- `en1` - Thunderbolt Ethernet
- `en2`, `en3` - Additional interfaces

### Linux
- `eth0`, `eth1` - Ethernet
- `wlan0`, `wlan1` - WiFi
- `enp0s3`, `enp2s0` - Predictable names (systemd)
- `wlp3s0` - WiFi with predictable names

## Troubleshooting

### No Data Showing

1. Check if network interface exists:
   ```bash
   # macOS
   ifconfig
   networksetup -listallhardwareports

   # Linux
   ip link
   ifconfig -a
   ```

2. Verify active interface:
   ```bash
   # macOS
   route -n get default

   # Linux
   ip route
   ```

3. Install ifstat for better accuracy:
   ```bash
   # macOS
   brew install ifstat

   # Linux
   sudo apt install ifstat
   ```

### Wrong Interface

If auto-detection fails, manually specify interface:

```bash
# Find your interface
ip link show  # Linux
ifconfig      # macOS

# Set it manually
set -g @powerkit_plugin_netspeed_interface "YOUR_INTERFACE"
```

### Zero Traffic Always

1. Check if interface is active:
   ```bash
   # Test with ping
   ping -c 1 8.8.8.8
   ```

2. Try a different detection method by installing `ifstat`

3. Verify interface has IP address:
   ```bash
   # macOS
   ifconfig en0

   # Linux
   ip addr show eth0
   ```

### Linux sysfs Method Issues

If using `/sys/class/net` fallback:
- First read establishes baseline
- Speeds calculated on subsequent reads
- May show 0 on first render cycle

## Performance Notes

- Updates every 2 seconds by default
- ifstat is fastest and most accurate
- sysfs method requires two samples to calculate rate
- Consider increasing cache_ttl on slower systems

## Platform Differences

### macOS
- Requires `ifstat` for accurate measurement
- Built-in network stack provides basic stats
- WiFi interface usually `en0`

### Linux
- Multiple detection methods available
- sysfs provides reliable fallback
- Interface naming varies by distribution

## Related Plugins

- [PluginWifi](PluginWifi) - WiFi signal strength
- [PluginVpn](PluginVpn) - VPN connection status
- [PluginPing](PluginPing) - Network latency
- [PluginExternalip](PluginExternalip) - Public IP address
