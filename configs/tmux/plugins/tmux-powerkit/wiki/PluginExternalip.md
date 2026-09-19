# Plugin: externalip

Display external (public) IP address.

## Screenshot

```
󰩟 203.0.113.42
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `curl` |
| Content Type | dynamic |
| Presence | conditional |

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "externalip"
```

## Configuration Example

```bash
set -g @powerkit_plugins "externalip"

# Icon
set -g @powerkit_plugin_externalip_icon "󰩟"

# Cache duration (10 minutes default - IP rarely changes)
set -g @powerkit_plugin_externalip_cache_ttl "600"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_externalip_icon` | icon | `󰩟` | Plugin icon |
| `@powerkit_plugin_externalip_cache_ttl` | number | `600` | Cache duration in seconds (10 min) |
| `@powerkit_plugin_externalip_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## States

| State | Condition |
|-------|-----------|
| `active` | IP address successfully retrieved |
| `inactive` | No network or API error |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Always (when active) |

## Context Values

| Context | Condition |
|---------|-----------|
| `online` | IP address available |
| `offline` | No IP address retrieved |

## Display Examples

**Normal display:**
```
󰩟 203.0.113.42
```

**No network:**
```
󰩟 N/A
```

## Data Source

Uses [ipify API](https://api.ipify.org) - a simple, free IP address API.

Request: `https://api.ipify.org`
Response: Plain text IP address

## Privacy Note

This plugin makes an external request to retrieve your public IP. The IP address is:
- Fetched from ipify.org
- Cached locally (default 10 minutes)
- Displayed in your status bar

If privacy is a concern, consider:
- Increasing `cache_ttl` to reduce requests
- Not using this plugin on public displays

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Shows N/A | Check internet connection |
| Stale IP | Decrease `cache_ttl` for faster updates |
| Slow to load | API timeout is 3 seconds; check network |
| Plugin not showing | State is `inactive` when offline |

## Alternative APIs

The plugin uses ipify.org by default. If you need a different provider, you would need to modify the plugin source. Common alternatives:
- `https://ifconfig.me/ip`
- `https://icanhazip.com`
- `https://checkip.amazonaws.com`

## Related Plugins

- [PluginNetspeed](PluginNetspeed) - Network upload/download speed
- [PluginWifi](PluginWifi) - WiFi connection info
- [PluginVpn](PluginVpn) - VPN connection status
- [PluginPing](PluginPing) - Network latency
