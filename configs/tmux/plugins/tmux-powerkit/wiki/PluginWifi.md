# Plugin: wifi

Display WiFi network name (SSID), IP address, and signal strength with multi-platform support.

## Screenshot

```
󰤨 MyNetwork          # Connected, excellent signal - green/ok
󰤢 Office-WiFi (45%)  # Connected, fair signal - yellow/warning
󰤟 Cafe-Guest (18%)   # Connected, weak signal - red/error
󰖪 N/A                # Disconnected - hidden
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | Built-in (macOS), `nmcli`/`iw`/`iwconfig` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS - all tools are built-in

# Linux (Debian/Ubuntu) - NetworkManager
sudo apt install network-manager

# Linux (Fedora)
sudo dnf install NetworkManager

# Linux (Arch)
sudo pacman -S networkmanager

# Linux - Alternative: iw (modern)
sudo apt install iw

# Linux - Alternative: iwconfig (legacy)
sudo apt install wireless-tools
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "wifi"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "wifi"

# Visibility control: connected, disconnected, always
set -g @powerkit_plugin_wifi_show_when "connected"

# Display format: ssid, ip, signal (comma-separated for multiple)
set -g @powerkit_plugin_wifi_format "ssid"
set -g @powerkit_plugin_wifi_separator " | "
set -g @powerkit_plugin_wifi_max_length "20"

# Icons - signal-based (auto-selected)
set -g @powerkit_plugin_wifi_icon "󰤨"
set -g @powerkit_plugin_wifi_icon_excellent "󰤨"
set -g @powerkit_plugin_wifi_icon_good "󰤥"
set -g @powerkit_plugin_wifi_icon_fair "󰤢"
set -g @powerkit_plugin_wifi_icon_weak "󰤟"
set -g @powerkit_plugin_wifi_icon_poor "󰤯"
set -g @powerkit_plugin_wifi_icon_disconnected "󰖪"

# Cache duration (seconds)
set -g @powerkit_plugin_wifi_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_wifi_show_when` | string | `connected` | When to show: `connected`, `disconnected`, `always` |
| `@powerkit_plugin_wifi_format` | string | `ssid` | Display format: `ssid`, `ip`, `signal` (comma-separated for multiple) |
| `@powerkit_plugin_wifi_separator` | string | ` \| ` | Separator for composite format |
| `@powerkit_plugin_wifi_max_length` | number | `20` | Maximum length for display text |
| `@powerkit_plugin_wifi_icon` | icon | `󰤨` | Connected icon (full signal) |
| `@powerkit_plugin_wifi_icon_excellent` | icon | `󰤨` | Excellent signal (80-100%) |
| `@powerkit_plugin_wifi_icon_good` | icon | `󰤥` | Good signal (60-80%) |
| `@powerkit_plugin_wifi_icon_fair` | icon | `󰤢` | Fair signal (40-60%) |
| `@powerkit_plugin_wifi_icon_weak` | icon | `󰤟` | Weak signal (20-40%) |
| `@powerkit_plugin_wifi_icon_poor` | icon | `󰤯` | Poor signal (0-20%) |
| `@powerkit_plugin_wifi_icon_disconnected` | icon | `󰖪` | Disconnected icon |
| `@powerkit_plugin_wifi_cache_ttl` | number | `5` | Cache duration in seconds |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Connected (when `show_when=connected`) or Disconnected (when `show_when=disconnected`) | Visible |
| `inactive` | Not matching `show_when` condition | Hidden |

**Note**: When `show_when=always`, the plugin is always visible regardless of connection state.

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Signal strength > 60% | Green |
| `warning` | Signal strength 20-60% | Yellow |
| `error` | Signal strength < 20% | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `connected` | Connected to WiFi |
| `disconnected` | Not connected |

## Signal Icons

Icons automatically change based on signal strength:

| Signal Range | Icon | Quality | Color |
|--------------|------|---------|-------|
| 80-100% | 󰤨 | Excellent | Green |
| 60-80% | 󰤥 | Good | Green |
| 40-60% | 󰤢 | Fair | Yellow |
| 20-40% | 󰤟 | Weak | Yellow |
| 0-20% | 󰤯 | Poor | Red |
| Disconnected | 󰖪 | N/A | Hidden |

## Detection Methods

The plugin tries multiple methods in order:

### macOS

| Method | Priority | Command | Notes |
|--------|----------|---------|-------|
| ipconfig | 1 | `ipconfig getsummary` | Fastest, requires Location Services |
| system_profiler | 2 | `system_profiler SPAirPortDataType` | Most reliable, includes signal |
| airport | 3 | `airport -I` | Deprecated but works |
| networksetup | 4 | `networksetup -getairportnetwork` | Basic, no signal |

### Linux

| Method | Priority | Command | Notes |
|--------|----------|---------|-------|
| nmcli | 1 | `nmcli -t -f active,ssid,signal dev wifi` | NetworkManager, most common |
| iw | 2 | `iw dev <interface> link` | Modern, requires root on some systems |
| iwconfig | 3 | `iwconfig` | Legacy, widely available |

## Display Modes

The `format` option controls what information is displayed. Use comma-separated values for multiple fields.

### SSID Mode (default)

Show network name:

```bash
set -g @powerkit_plugin_wifi_format "ssid"
```

Output: `󰤨 MyNetwork`

### IP Address Mode

Show IP instead of SSID:

```bash
set -g @powerkit_plugin_wifi_format "ip"
```

Output: `󰤨 192.168.1.100`

### Signal Only

Show signal strength:

```bash
set -g @powerkit_plugin_wifi_format "signal"
```

Output: `󰤨 85%`

### Combined Formats

Show SSID and signal:

```bash
set -g @powerkit_plugin_wifi_format "ssid,signal"
```

Output: `󰤨 MyNetwork | 85%`

Show all information:

```bash
set -g @powerkit_plugin_wifi_format "ssid,ip,signal"
set -g @powerkit_plugin_wifi_separator " • "
```

Output: `󰤨 MyNetwork • 192.168.1.100 • 85%`

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "wifi"
```

### Show IP Address

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_format "ip"
```

### Show Signal Strength

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_format "ssid,signal"
```

### Network Monitoring Setup

```bash
set -g @powerkit_plugins "wifi,ping,netspeed"
set -g @powerkit_plugin_wifi_format "ssid,signal"
```

### Always Show (Even When Disconnected)

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_show_when "always"
```

### Custom Icons

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_icon_excellent "📶"
set -g @powerkit_plugin_wifi_icon_poor "📵"
```

### Custom Separator

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_format "ssid,signal"
set -g @powerkit_plugin_wifi_separator " → "
```

## Common WiFi Issues

### No SSID Detected

1. Check WiFi is enabled:
   ```bash
   # macOS
   networksetup -getairportpower en0

   # Linux
   nmcli radio wifi
   ip link show wlan0
   ```

2. List available networks:
   ```bash
   # macOS
   /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s

   # Linux
   nmcli dev wifi list
   iw dev wlan0 scan | grep SSID
   ```

### Wrong Signal Strength

Signal strength calculation varies by platform:
- **macOS**: RSSI converted to percentage (-100 to -50 dBm)
- **Linux**: Direct percentage from driver

Quality ranges:
- Excellent: -50 dBm (100%) or 80%+
- Good: -60 dBm (80%) or 60-80%
- Fair: -70 dBm (60%) or 40-60%
- Poor: -80 dBm (40%) or 20-40%
- Very Poor: -90 dBm (20%) or < 20%

### Location Services (macOS)

If `ipconfig` method fails with "<redacted>" SSID:

1. Enable Location Services:
   - System Settings → Privacy & Security → Location Services
   - Enable for "System Services"

2. Use alternative detection method (automatic fallback)

### Plugin Shows "WiFi" Instead of SSID

When SSID is redacted or unavailable:
- macOS privacy settings may hide SSID
- Plugin falls back to generic "WiFi" text
- Try enabling Location Services

## Troubleshooting

### No Data on macOS

1. Check WiFi interface:
   ```bash
   networksetup -listallhardwareports | grep -A 1 Wi-Fi
   ifconfig en0
   ```

2. Test detection methods:
   ```bash
   # Method 1
   ipconfig getsummary en0

   # Method 2
   system_profiler SPAirPortDataType

   # Method 3
   /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
   ```

### No Data on Linux

1. Install required tools:
   ```bash
   sudo apt install network-manager iw wireless-tools
   ```

2. Check NetworkManager is running:
   ```bash
   systemctl status NetworkManager
   sudo systemctl start NetworkManager
   ```

3. Find WiFi interface:
   ```bash
   iw dev
   ip link | grep wl
   nmcli device
   ```

4. Test detection:
   ```bash
   nmcli -t -f active,ssid,signal dev wifi
   iw dev wlan0 link
   iwconfig wlan0
   ```

### Wrong Interface

Find your WiFi interface:

```bash
# macOS
networksetup -listallhardwareports | grep -A 1 Wi-Fi

# Linux
nmcli device status | grep wifi
iw dev
ls /sys/class/net/ | grep wl
```

Common interface names:
- **macOS**: `en0`, `en1`
- **Linux**: `wlan0`, `wlp2s0`, `wlp3s0`

### Permissions (Linux)

Some WiFi commands require root:

```bash
# Add user to netdev group
sudo usermod -aG netdev $USER

# Or use sudo for specific commands (not recommended)
```

## Performance Notes

- WiFi detection is relatively fast (50-200ms)
- Default cache TTL is 5 seconds
- macOS ipconfig is fastest (~10ms)
- Linux nmcli is fast (~50ms)
- system_profiler is slower (~500ms) but more reliable

## Platform Support

| Feature | macOS | Linux | Notes |
|---------|-------|-------|-------|
| SSID | ✓ | ✓ | Full support |
| Signal | ✓ | ✓ | Different calculation methods |
| IP Address | ✓ | ✓ | Full support |
| Multiple Methods | ✓ | ✓ | Automatic fallback |

## Use Cases

### Mobile Workspace

Track which network you're on:

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_format "ssid"
```

### Network Debugging

Show connection details:

```bash
set -g @powerkit_plugins "wifi,ping,netspeed"
set -g @powerkit_plugin_wifi_format "ssid,ip,signal"
```

### Signal Quality Monitoring

Visual indicator of connection quality:

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_format "signal"
# Icon changes based on signal strength automatically
```

### Minimal Information

Just show you're connected (icon only):

```bash
set -g @powerkit_plugins "wifi"
set -g @powerkit_plugin_wifi_max_length "0"
# Only shows icon when connected
```

## Related Plugins

- [PluginNetspeed](PluginNetspeed) - Network traffic monitoring
- [PluginPing](PluginPing) - Network latency
- [PluginVpn](PluginVpn) - VPN status
- [PluginExternalip](PluginExternalip) - Public IP address
