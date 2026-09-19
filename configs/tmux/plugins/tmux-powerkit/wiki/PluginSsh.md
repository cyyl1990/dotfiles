# Plugin: ssh

Display SSH connection indicator for both incoming and outgoing sessions.

## Screenshot

```
󰣀 user@server     # Incoming SSH session (you SSH'd into this machine)
󰣀 admin@prod      # Outgoing SSH from tmux pane (you SSH'd from tmux)
󰣀 SSH             # Indicator format (minimal)
(hidden)           # Local session - not shown
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, FreeBSD |
| **Dependencies** | None (uses environment variables and process detection) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "ssh"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "ssh"

# Display format: auto, host, user, indicator
set -g @powerkit_plugin_ssh_format "auto"

# Text for indicator format
set -g @powerkit_plugin_ssh_text "SSH"

# Detection mode: current (both), session (incoming only), pane (outgoing only)
set -g @powerkit_plugin_ssh_detection_mode "current"

# Show plugin even when not in SSH
set -g @powerkit_plugin_ssh_show_when_local "false"

# Legacy options (used when format=auto)
set -g @powerkit_plugin_ssh_show_user "true"
set -g @powerkit_plugin_ssh_show_host "true"

# Icon
set -g @powerkit_plugin_ssh_icon "󰣀"

# Cache duration (seconds)
set -g @powerkit_plugin_ssh_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_ssh_format` | string | `auto` | Display format: `auto`, `host`, `user`, `indicator` |
| `@powerkit_plugin_ssh_text` | string | `SSH` | Text to display when format is `indicator` |
| `@powerkit_plugin_ssh_detection_mode` | string | `current` | Detection: `current` (both), `session` (incoming), `pane` (outgoing) |
| `@powerkit_plugin_ssh_show_when_local` | bool | `false` | Show plugin even when not in SSH session |
| `@powerkit_plugin_ssh_show_user` | bool | `true` | Show username (when format=auto) |
| `@powerkit_plugin_ssh_show_host` | bool | `true` | Show hostname (when format=auto) |
| `@powerkit_plugin_ssh_icon` | icon | `󰣀` | SSH session icon |
| `@powerkit_plugin_ssh_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_ssh_show_only_on_threshold` | bool | `false` | Not applicable for this plugin |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | In SSH session (incoming or outgoing) | Visible |
| `active` | show_when_local=true and not in SSH | Visible (shows "local") |
| `inactive` | Local terminal and show_when_local=false | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `info` | Always (SSH sessions are informational) | Blue |

## Context Values

| Context | Description |
|---------|-------------|
| `incoming` | SSH session from remote to this host (you SSH'd into this machine) |
| `outgoing` | SSH connection from this host to remote (SSH running in tmux pane) |
| `local` | Not in SSH session |

## Detection Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `current` | Detects both incoming and outgoing SSH (default) | General use |
| `session` | Only detects incoming SSH sessions | When you SSH into a server and start tmux |
| `pane` | Only detects outgoing SSH in current pane | Monitor SSH connections made from within tmux |

## SSH Detection Methods

The plugin detects SSH sessions using multiple methods:

1. **Environment Variables**:
   - `SSH_CONNECTION` - Most reliable
   - `SSH_CLIENT` - Alternative
   - `SSH_TTY` - Terminal detection

2. **Parent Process**:
   - Checks if parent process is `sshd`

## Display Formats

### Auto Format (default)

Shows `user@hostname` using legacy options:

```bash
set -g @powerkit_plugin_ssh_format "auto"
set -g @powerkit_plugin_ssh_show_user "true"
set -g @powerkit_plugin_ssh_show_host "true"
```

Output: `󰣀 user@server.example.com`

### Host Only

Shows hostname only:

```bash
set -g @powerkit_plugin_ssh_format "host"
```

Output: `󰣀 server.example.com`

### User Only

Shows username only:

```bash
set -g @powerkit_plugin_ssh_format "user"
```

Output: `󰣀 user`

### Indicator Only

Shows custom text indicator:

```bash
set -g @powerkit_plugin_ssh_format "indicator"
set -g @powerkit_plugin_ssh_text "REMOTE"
```

Output: `󰣀 REMOTE`

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "ssh"
```

### Show Only Hostname

```bash
set -g @powerkit_plugins "ssh"
set -g @powerkit_plugin_ssh_show_user "false"
set -g @powerkit_plugin_ssh_show_host "true"
```

### Show Only When in SSH

The plugin automatically hides when not in SSH (conditional presence):

```bash
set -g @powerkit_plugins "ssh"
# No additional configuration needed
```

### Combined with Hostname Plugin

Show local hostname always, SSH info when remote:

```bash
set -g @powerkit_plugins "hostname,ssh"

# Local: only hostname shows
# SSH: both hostname and SSH info show
```

### Custom Icon

```bash
set -g @powerkit_plugins "ssh"
set -g @powerkit_plugin_ssh_icon "🔐"
```

## Use Cases

### Multi-Server Administration

Identify which server you're connected to:

```bash
set -g @powerkit_plugins "ssh,hostname"
set -g @powerkit_plugin_ssh_show_host "true"
```

### Security Awareness

Visual indicator when in remote session:

```bash
set -g @powerkit_plugins "ssh"
# Icon color changes based on theme's ok-base color
```

### Simplified Status Bar

Minimize information when local, show details when remote:

```bash
# Local: clean status bar
# Remote: shows SSH indicator automatically
set -g @powerkit_plugins "ssh,datetime"
```

## Troubleshooting

### Plugin Always Shows SSH

If the plugin shows SSH indicator even in local terminal:

1. Check environment variables:
   ```bash
   echo $SSH_CONNECTION
   echo $SSH_CLIENT
   echo $SSH_TTY
   ```

2. These should be empty in local terminal. If not:
   ```bash
   # Unset SSH variables (temporary)
   unset SSH_CONNECTION SSH_CLIENT SSH_TTY
   ```

3. Some terminal multiplexers preserve environment:
   - Restart tmux session
   - Check `~/.bashrc`, `~/.zshrc` for SSH variable exports

### Plugin Never Shows SSH

If the plugin doesn't show when in SSH:

1. Verify you're actually in SSH:
   ```bash
   who am i
   w
   ```

2. Check if environment variables are set:
   ```bash
   env | grep SSH
   ```

3. Ensure tmux is started AFTER SSH login:
   ```bash
   # Correct order:
   ssh user@host
   tmux new-session

   # Wrong (won't detect):
   tmux new-session
   # then SSH from within tmux
   ```

### Wrong Username/Hostname

The plugin uses system commands to get user/host:

```bash
# Check what the plugin sees
whoami          # Username
hostname        # Hostname
hostname -s     # Short hostname
```

If these return wrong values, set them properly:

```bash
# Set hostname
sudo hostnamectl set-hostname myhost

# Or use SSH config to set display name
# ~/.ssh/config
Host myserver
    HostName actual-server.com
    User myuser
```

## SSH Sessions vs SSH Plugin

The plugin can detect both scenarios depending on `detection_mode`:

### detection_mode="session" (incoming only)

- **tmux in SSH**: You SSH first, then start tmux → Plugin detects SSH ✓
- **SSH from tmux**: You start tmux first, then SSH → Plugin won't detect ✗

### detection_mode="pane" (outgoing only)

- **tmux in SSH**: You SSH first, then start tmux → Plugin won't detect ✗
- **SSH from tmux**: You start tmux first, then SSH → Plugin detects SSH ✓

### detection_mode="current" (default - both)

- **tmux in SSH**: You SSH first, then start tmux → Plugin detects SSH ✓
- **SSH from tmux**: You start tmux first, then SSH → Plugin detects SSH ✓

The default mode detects both incoming sessions (environment-based) and outgoing connections (pane process detection).

## Platform Support

| Platform | Detection Method | Notes |
|----------|------------------|-------|
| macOS | Environment + process | Fully supported |
| Linux | Environment + process | Fully supported |
| FreeBSD | Environment + process | Fully supported |
| WSL | Environment | Fully supported |

## Performance Notes

- Very lightweight - only checks environment variables
- Default cache TTL is 600 seconds (10 minutes)
- SSH status rarely changes during session
- No external commands required for detection

## Related Plugins

- [PluginHostname](PluginHostname) - Display hostname
- [PluginVpn](PluginVpn) - VPN connection indicator
- [PluginCloud](PluginCloud) - Cloud provider info
- [PluginKubernetes](PluginKubernetes) - K8s context indicator
