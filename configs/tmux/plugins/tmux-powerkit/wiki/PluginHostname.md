# Plugin: hostname

Display current system hostname with short or full domain format.

## Screenshot

```
 macbook-pro     # Short format (default)
 server.local    # Short format with local domain
 server.example.com  # Full format
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, FreeBSD |
| **Dependencies** | None (uses built-in commands) |
| **Content Type** | dynamic |
| **Presence** | always |

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "hostname"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "hostname"

# Hostname format: short or full
set -g @powerkit_plugin_hostname_format "short"

# Icon
set -g @powerkit_plugin_hostname_icon "󰒋"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_hostname_format` | string | `short` | Hostname format: `short` (hostname only) or `full` (FQDN) |
| `@powerkit_plugin_hostname_icon` | icon | `󰒋` | Hostname icon |
| `@powerkit_plugin_hostname_show_only_on_threshold` | bool | `false` | Only show based on conditions |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Always active | Visible |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Always | Green |

## Context Values

| Context | Description |
|---------|-------------|
| `local` | Not in SSH session |
| `remote` | Inside SSH session |

## Format Options

### Short Format (default)

Displays only the hostname without domain:

```bash
set -g @powerkit_plugin_hostname_format "short"
```

Examples:
- `macbook-pro`
- `server`
- `workstation`

### Full Format

Displays fully qualified domain name (FQDN):

```bash
set -g @powerkit_plugin_hostname_format "full"
```

Examples:
- `macbook-pro.local`
- `server.example.com`
- `workstation.internal.company.com`

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "hostname"
```

### Full Domain Name

```bash
set -g @powerkit_plugins "hostname"
set -g @powerkit_plugin_hostname_format "full"
```

### Custom Icon

```bash
set -g @powerkit_plugins "hostname"
set -g @powerkit_plugin_hostname_icon "💻"
```

### Combined with SSH Indicator

```bash
# Show hostname with SSH indicator
set -g @powerkit_plugins "ssh,hostname"

# Hostname will show 'remote' context when in SSH
```

## Use Cases

### Local Development

Show hostname to identify which machine you're working on:

```bash
set -g @powerkit_plugins "hostname,datetime"
```

### Multi-Server Management

Display full hostname to distinguish between servers:

```bash
set -g @powerkit_plugins "hostname"
set -g @powerkit_plugin_hostname_format "full"
```

### SSH Sessions

Hostname automatically detects SSH context. Combine with SSH plugin for complete info:

```bash
set -g @powerkit_plugins "ssh,hostname"
```

Output: ` user@remote  server.example.com`

## Troubleshooting

### Hostname Not Showing

1. Verify hostname is set:
   ```bash
   hostname        # Short format
   hostname -f     # Full format (FQDN)
   ```

2. Set hostname if missing:
   ```bash
   # Temporary
   sudo hostname my-machine

   # Permanent (varies by distro)
   # Debian/Ubuntu
   sudo hostnamectl set-hostname my-machine

   # macOS
   sudo scutil --set HostName my-machine
   sudo scutil --set ComputerName my-machine
   sudo scutil --set LocalHostName my-machine
   ```

### Full Format Shows Same as Short

- Your system may not have a fully qualified domain name configured
- This is normal for most desktop/laptop machines
- Servers typically have FQDN configured via DNS

### Context Detection

The plugin detects SSH sessions via environment variables:
- `SSH_CONNECTION`
- `SSH_CLIENT`
- `SSH_TTY`

If context is wrong, check these variables:
```bash
echo $SSH_CONNECTION
echo $SSH_CLIENT
```

## Platform Differences

| Platform | Short Format | Full Format |
|----------|--------------|-------------|
| macOS | `hostname -s` | `hostname -f` or scutil |
| Linux | `hostname -s` | `hostname -f` |
| FreeBSD | `hostname -s` | `hostname` |

## Performance

- Hostname is cached for 1 hour by default (rarely changes)
- Very lightweight - no external dependencies
- No network calls required

## Related Plugins

- [PluginSsh](PluginSsh) - SSH session indicator
- [PluginDatetime](PluginDatetime) - Date and time display
- [PluginUptime](PluginUptime) - System uptime
