# Plugin: vpn

Display VPN connection status with multi-provider detection including WARP, FortiClient, WireGuard, Tailscale, and more.

## Screenshots

```
󰖂 Cloudflare WARP
󰖂 FortiClient
󰖂 tun0
󰖂 VPN
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | None (checks network interfaces), optional: `warp-cli`, `tailscale`, `wg`, `openvpn`, `nmcli`, `scutil` |
| Content Type | dynamic |
| Presence | conditional (hidden when disconnected) |

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "vpn"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "vpn"

# Display format: name, ip, provider
set -g @powerkit_plugin_vpn_format "name"
set -g @powerkit_plugin_vpn_max_length "20"

# Interface detection fallback (Linux only)
set -g @powerkit_plugin_vpn_interfaces "tun,tap,ppp,wg"

# macOS: Detect iCloud Private Relay as VPN
set -g @powerkit_plugin_vpn_detect_private_relay "false"

# Icon
set -g @powerkit_plugin_vpn_icon "󱒃"

# Cache
set -g @powerkit_plugin_vpn_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_vpn_format` | string | `name` | Display format: `name`, `ip`, `provider` |
| `@powerkit_plugin_vpn_max_length` | number | `20` | Maximum length for display text |
| `@powerkit_plugin_vpn_interfaces` | string | `tun,tap,ppp,wg` | VPN interface prefixes for fallback detection (Linux only) |
| `@powerkit_plugin_vpn_detect_private_relay` | bool | `false` | Detect iCloud Private Relay as VPN (macOS only) |
| `@powerkit_plugin_vpn_icon` | icon | `󱒃` | VPN connected icon |
| `@powerkit_plugin_vpn_cache_ttl` | number | `5` | Cache duration in seconds |

## States

| State | Condition |
|-------|-----------|
| `active` | VPN is connected |
| `inactive` | VPN is disconnected (plugin hidden) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `info` | VPN connected (always returns `info` when connected) |

**Note**: The plugin is hidden when disconnected, so there's no "disconnected" health level.

## Context Values

The context returns the detected provider name:

| Context | Description |
|---------|-------------|
| `warp` | Cloudflare WARP |
| `forticlient` | FortiClient VPN |
| `wireguard` | WireGuard |
| `tailscale` | Tailscale |
| `openvpn` | OpenVPN |
| `system` | macOS/NetworkManager native VPN |
| `private_relay` | iCloud Private Relay (macOS, requires `detect_private_relay=true`) |
| `interface` | Generic tun/tap interface detected |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "vpn"
```

### Show IP Address Instead of Name

```bash
set -g @powerkit_plugins "vpn"
set -g @powerkit_plugin_vpn_format "ip"
```

### Show Provider Type

```bash
set -g @powerkit_plugins "vpn"
set -g @powerkit_plugin_vpn_format "provider"
```

### Custom Interface Prefixes (Linux)

```bash
set -g @powerkit_plugins "vpn"
set -g @powerkit_plugin_vpn_interfaces "tun,tap,wg,vpn"
```

### Truncate Long Names

```bash
set -g @powerkit_plugins "vpn"
set -g @powerkit_plugin_vpn_max_length "15"
```

### Detect iCloud Private Relay (macOS)

```bash
set -g @powerkit_plugins "vpn"
set -g @powerkit_plugin_vpn_detect_private_relay "true"
```

## Supported VPN Providers

The plugin automatically detects various VPN providers in order of specificity:

| Provider | Detection Method | Name Source |
|----------|-----------------|-------------|
| Cloudflare WARP | `warp-cli status` | "Cloudflare WARP" |
| FortiClient | `forticlient`, process, or macOS app | VPN name or "FortiClient" |
| Tailscale | `tailscale status --json` | Hostname or "Tailscale" |
| WireGuard | `wg show interfaces` | Interface name |
| OpenVPN | `pgrep openvpn` | Config filename or "OpenVPN" |
| macOS Native | `scutil --nc list` | VPN connection name |
| NetworkManager | `nmcli` | Connection name |
| Generic | Network interfaces | Interface name (tun0, tap0, etc.) |

## Detection Priority

Providers are checked in order of specificity (most specific first):

1. **Cloudflare WARP** - Via warp-cli
2. **FortiClient** - Via CLI, process, or macOS app
3. **Tailscale** - Via tailscale CLI
4. **WireGuard** - Via wg CLI
5. **OpenVPN** - Via process detection
6. **System VPN** - Via scutil (macOS) or nmcli (Linux)
7. **Generic Interface** - Fallback to interface detection

## Display Format

| Format | Output | Description |
|--------|--------|-------------|
| `name` (default) | `Cloudflare WARP` | VPN connection name |
| `ip` | `100.64.0.1` | VPN IP address (falls back to name if unavailable) |
| `provider` | `tailscale` | Provider type |
| Disconnected | (hidden) | Plugin is hidden when no VPN connected |

If the output exceeds `max_length`, it will be truncated with `…`.

## Platform-Specific Behavior

### macOS

Detection methods:
- FortiClient app and processes
- scutil for native VPN connections
- Network interface detection (utun*, tun*, tap*)

```bash
# List VPN connections
scutil --nc list

# Check FortiClient
pgrep -f FortiClient
```

### Linux

Detection methods:
- NetworkManager connections via nmcli
- OpenVPN processes
- Network interface detection (tun*, tap*, wg*)

```bash
# List active VPN connections
nmcli connection show --active | grep vpn

# Check for OpenVPN
pgrep openvpn
```

## Troubleshooting

### Plugin Not Showing When VPN is Connected

1. Check if VPN interface exists:
   ```bash
   # macOS
   ifconfig | grep -E "(tun|tap|utun|ppp)"

   # Linux
   ip link show | grep -E "(tun|tap|wg)"
   ```

2. Check provider-specific CLI:
   ```bash
   # WARP
   warp-cli status

   # Tailscale
   tailscale status

   # WireGuard
   wg show

   # OpenVPN
   pgrep openvpn
   ```

3. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin vpn
   ```

### Wrong VPN Name Showing

If the detected name is incorrect:

1. Check what the plugin is detecting:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin vpn
   ```

2. For FortiClient, check VPN name:
   ```bash
   # macOS
   scutil --nc list | grep -i forti

   # Look for connected VPN
   scutil --nc list | grep "Connected"
   ```

3. For NetworkManager:
   ```bash
   nmcli connection show --active
   ```

### FortiClient Not Detected

FortiClient detection requires one of:

1. **CLI** (`forticlient` or `openfortivpn` command)
2. **Process** (FortiClient or FortiTray running)
3. **macOS app** (FortiClient.app with active connection)
4. **Interface** (ppp0 interface present)

Check each:
```bash
# CLI
which forticlient openfortivpn

# Process
pgrep -f FortiClient

# Interface
ifconfig ppp0
```

### Generic Interface Name Showing

If seeing "tun0" instead of provider name, it means the plugin couldn't detect a specific provider. This usually means:

1. VPN client isn't in the supported list
2. VPN client CLI isn't available
3. VPN is using a generic interface

The `format` option can be used to display different information:
```bash
# Show provider type instead of connection name
set -g @powerkit_plugin_vpn_format "provider"
```

### Slow Performance

If VPN detection is slow:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_vpn_cache_ttl "30"
   ```

2. Check slow commands:
   ```bash
   time warp-cli status
   time tailscale status
   time scutil --nc list
   ```

3. Disable unused providers by removing their CLIs from PATH

## Common VPN Configurations

### Cloudflare WARP

```bash
# Install
# macOS: Download from cloudflare.com
# Linux: Follow Cloudflare's instructions

# Connect
warp-cli connect

# Check status
warp-cli status
```

### Tailscale

```bash
# Install
curl -fsSL https://tailscale.com/install.sh | sh

# Login and connect
tailscale up

# Check status
tailscale status
```

### WireGuard

```bash
# Install
# macOS: brew install wireguard-tools
# Linux: sudo apt install wireguard

# Start interface
sudo wg-quick up wg0

# Check status
wg show
```

### OpenVPN

```bash
# Start connection
sudo openvpn --config /path/to/config.ovpn

# Check process
pgrep openvpn
```

### FortiClient

```bash
# macOS: Use FortiClient GUI or CLI
# Linux: Use openfortivpn

# Using openfortivpn
sudo openfortivpn vpn.example.com:443 -u username

# Check process
pgrep openfortivpn
```

## Related Plugins

- [PluginWifi](PluginWifi) - WiFi SSID and signal strength
- [PluginNetspeed](PluginNetspeed) - Network upload/download speed
- [PluginExternalip](PluginExternalip) - Public IP address
- [PluginPing](PluginPing) - Network latency
