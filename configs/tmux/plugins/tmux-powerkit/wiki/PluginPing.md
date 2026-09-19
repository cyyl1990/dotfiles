# Plugin: ping

Display network latency to a target host with customizable thresholds.

## Screenshot

```
 25ms       # Good - green/ok
 150ms      # Fair - yellow/warning
 350ms      # Poor - red/error
 N/A        # Unreachable - red/error
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, FreeBSD |
| **Dependencies** | `ping` (built-in) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "ping"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "ping"

# Host to ping
set -g @powerkit_plugin_ping_host "8.8.8.8"

# Ping settings
set -g @powerkit_plugin_ping_count "1"
set -g @powerkit_plugin_ping_timeout "2"
set -g @powerkit_plugin_ping_unit "ms"

# Thresholds (milliseconds)
set -g @powerkit_plugin_ping_warning_threshold "100"
set -g @powerkit_plugin_ping_critical_threshold "300"

# Icon
set -g @powerkit_plugin_ping_icon "󰣐"

# Cache duration (seconds)
set -g @powerkit_plugin_ping_cache_ttl "30"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_ping_host` | string | `8.8.8.8` | Target host to ping (IP or hostname) |
| `@powerkit_plugin_ping_count` | number | `1` | Number of ping packets to send |
| `@powerkit_plugin_ping_timeout` | number | `2` | Ping timeout in seconds |
| `@powerkit_plugin_ping_unit` | string | `ms` | Display unit (ms, s) |
| `@powerkit_plugin_ping_warning_threshold` | number | `100` | Warning threshold in milliseconds |
| `@powerkit_plugin_ping_critical_threshold` | number | `300` | Critical threshold in milliseconds |
| `@powerkit_plugin_ping_icon` | icon | `󰣐` | Network icon |
| `@powerkit_plugin_ping_cache_ttl` | number | `30` | Cache duration in seconds |
| `@powerkit_plugin_ping_show_only_on_threshold` | bool | `false` | Only show when above warning threshold |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Host reachable | Visible |
| `inactive` | Host unreachable or timeout | Hidden (if conditional) |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Latency below warning threshold | Green |
| `warning` | Latency between warning and critical | Yellow |
| `error` | Latency above critical or unreachable | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `unreachable` | Host cannot be reached (timeout or network error) |
| `excellent` | Latency < 50ms |
| `good` | Latency 50-100ms |
| `fair` | Latency 100-200ms |
| `poor` | Latency > 200ms |

## Common Ping Targets

| Target | Description | Purpose |
|--------|-------------|---------|
| `8.8.8.8` | Google DNS | General internet connectivity |
| `1.1.1.1` | Cloudflare DNS | Alternative DNS check |
| `192.168.1.1` | Router (typical) | Local network check |
| `example.com` | Domain name | DNS resolution test |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "ping"
```

### Monitor Local Router

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "192.168.1.1"
set -g @powerkit_plugin_ping_warning_threshold "10"
set -g @powerkit_plugin_ping_critical_threshold "50"
```

### Monitor Specific Server

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "api.mycompany.com"
set -g @powerkit_plugin_ping_warning_threshold "50"
set -g @powerkit_plugin_ping_critical_threshold "150"
```

### Check Multiple Hosts

Use separate tmux windows/panes with different configurations:

```bash
# Window 1: Internet connectivity
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "8.8.8.8"

# Window 2: Production server
# In another tmux session/window
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "prod-server.example.com"
```

### Fast Refresh for Critical Monitoring

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "critical-service.local"
set -g @powerkit_plugin_ping_cache_ttl "5"
set -g @powerkit_plugin_ping_timeout "1"
```

### Show Only When Connection Degrades

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_show_only_on_threshold "true"
set -g @powerkit_plugin_ping_warning_threshold "50"
```

## Latency Guidelines

| Range | Quality | Suitable For |
|-------|---------|--------------|
| 0-20ms | Excellent | Gaming, real-time apps, local network |
| 20-50ms | Very Good | Video calls, cloud services |
| 50-100ms | Good | Web browsing, most apps |
| 100-200ms | Fair | General use, some lag noticeable |
| 200-500ms | Poor | Slow responses, noticeable delays |
| >500ms | Very Poor | Nearly unusable for interactive apps |

## Troubleshooting

### Always Shows "N/A"

1. Check if host is reachable manually:
   ```bash
   ping -c 1 8.8.8.8
   ```

2. Verify network connection:
   ```bash
   # Check default route
   ip route  # Linux
   route -n get default  # macOS
   ```

3. Test DNS resolution (if using hostname):
   ```bash
   nslookup example.com
   dig example.com
   ```

4. Check firewall rules:
   ```bash
   # Some networks block ICMP (ping)
   # Try a different target host
   ```

### High Latency Values

If you consistently see high latency:

1. Check local network first:
   ```bash
   ping 192.168.1.1
   ```

2. Test different hosts to isolate issue:
   ```bash
   ping 8.8.8.8    # Google
   ping 1.1.1.1    # Cloudflare
   ping 9.9.9.9    # Quad9
   ```

3. Check for packet loss:
   ```bash
   ping -c 100 8.8.8.8
   ```

### Plugin Slows Down tmux

If ping commands are slow:

1. Increase cache TTL to reduce frequency:
   ```bash
   set -g @powerkit_plugin_ping_cache_ttl "60"
   ```

2. Reduce timeout:
   ```bash
   set -g @powerkit_plugin_ping_timeout "1"
   ```

3. Use a closer/faster target:
   ```bash
   set -g @powerkit_plugin_ping_host "192.168.1.1"
   ```

### Firewall or Network Blocks ICMP

Some networks block ICMP packets (ping):

- Corporate networks often block outbound ICMP
- Some cloud providers filter ICMP
- VPNs may not route ICMP properly

**Solutions:**
- Use a different monitoring approach (like HTTP checks)
- Monitor internal/local targets instead
- Configure network to allow ICMP

## Platform Differences

### macOS

```bash
ping -c 1 -t 2 8.8.8.8
# -c count
# -t timeout
```

### Linux

```bash
ping -c 1 -W 2 8.8.8.8
# -c count
# -W timeout
```

The plugin handles these differences automatically.

## Performance Notes

- Ping adds 1-2 seconds per check (due to network round-trip)
- Default cache TTL is 30 seconds to minimize impact
- Consider higher cache_ttl for non-critical monitoring
- Each ping uses minimal bandwidth (typically < 100 bytes)

## Use Cases

### Internet Connectivity Monitor

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "8.8.8.8"
```

### VPN Health Check

Monitor VPN tunnel latency:

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "10.0.0.1"  # VPN gateway
set -g @powerkit_plugin_ping_warning_threshold "50"
```

### Network Quality Indicator

Combined with other network plugins:

```bash
set -g @powerkit_plugins "netspeed,ping,wifi"
set -g @powerkit_plugin_ping_host "8.8.8.8"
```

### Remote Server Monitoring

Check production server availability:

```bash
set -g @powerkit_plugins "ping"
set -g @powerkit_plugin_ping_host "prod-db.example.com"
set -g @powerkit_plugin_ping_cache_ttl "15"
```

## Related Plugins

- [PluginNetspeed](PluginNetspeed) - Network traffic monitoring
- [PluginWifi](PluginWifi) - WiFi signal strength
- [PluginVpn](PluginVpn) - VPN connection status
- [PluginExternalip](PluginExternalip) - Public IP address
