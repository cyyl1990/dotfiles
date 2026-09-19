# Plugin: smartkey

Display hardware key touch indicator for YubiKey, SoloKeys, Nitrokey and similar security devices.

## Screenshot

```
󰟵 TOUCH       # Key is waiting for touch (attention needed)
(hidden)       # No key activity
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `gpg-connect-agent` (optional), `pcsc_scan` (optional) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

No mandatory dependencies - the plugin uses multiple detection methods:

```bash
# Optional: For GPG/scdaemon detection
# macOS
brew install gnupg

# Linux
sudo apt install gnupg2

# Optional: For PCSC detection
# Linux
sudo apt install pcscd pcsc-tools
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "smartkey"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "smartkey"

# Icons
set -g @powerkit_plugin_smartkey_icon "󰟵"
set -g @powerkit_plugin_smartkey_icon_waiting "󰟵"

# Cache - very short TTL since touch state changes quickly
set -g @powerkit_plugin_smartkey_cache_ttl "2"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_smartkey_icon` | icon | `󰟵` | Default plugin icon |
| `@powerkit_plugin_smartkey_icon_waiting` | icon | `󰟵` | Icon when waiting for touch |
| `@powerkit_plugin_smartkey_cache_ttl` | number | `2` | Cache duration in seconds |
| `@powerkit_plugin_smartkey_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded (N/A) |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Hardware key is waiting for touch | Visible |
| `inactive` | No key activity | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `error` | Key is waiting for touch (urgent attention needed) | Red |
| `ok` | No key activity | Green |

## Context Values

| Context | Description |
|---------|-------------|
| `waiting` | Key is waiting for touch interaction |
| `idle` | No key activity |

## Detection Methods

The plugin uses multiple methods to detect when a hardware key is waiting for touch, in priority order:

### 1. yubikey-touch-detector Daemon

If installed, the [yubikey-touch-detector](https://github.com/maximbaz/yubikey-touch-detector) daemon is the most reliable method:

```bash
# Install on Linux
yay -S yubikey-touch-detector
systemctl --user enable --now yubikey-touch-detector.socket
```

### 2. SSH/FIDO2 Operations

Detects when SSH is waiting for FIDO2 key touch:
- `ssh-keygen` processes (git signing, resident keys)
- `ssh-sk-helper` (SSH authentication)
- `libfido2` tools

### 3. GPG Pinentry

Detects when pinentry is prompting for smartcard PIN/touch.

### 4. scdaemon Signing

Detects when GPG's scdaemon is blocked waiting for card interaction.

### 5. YubiKey Manager

Detects when `ykman` is waiting for user interaction.

### 6. Generic Smartcard Transaction

Detects when YubiKey USB device is busy (transaction in progress):
- macOS: Uses `ioreg` to check busy state
- Linux: Uses `/sys/class/hidraw` and `lsof`

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "smartkey"
```

### Custom Waiting Icon

```bash
set -g @powerkit_plugins "smartkey"
set -g @powerkit_plugin_smartkey_icon_waiting "🔑"
```

### Faster Detection

```bash
set -g @powerkit_plugins "smartkey"
set -g @powerkit_plugin_smartkey_cache_ttl "1"
```

## Use Cases

### Git Commit Signing

When using a YubiKey for GPG signing git commits:

```bash
git commit -m "Signed commit"
# Plugin shows "TOUCH" when key needs touch
```

### SSH Authentication

When using FIDO2 key for SSH:

```bash
ssh user@server
# Plugin shows "TOUCH" when key needs touch
```

### GPG Decryption

When decrypting files with smartcard:

```bash
gpg --decrypt file.gpg
# Plugin shows "TOUCH" when key needs touch
```

## Supported Hardware Keys

- **YubiKey** (all models with touch)
- **SoloKeys** (Solo, Solo V2)
- **Nitrokey** (Nitrokey 3, Nitrokey FIDO2)
- **Google Titan**
- **Feitian** (ePass FIDO)
- Any FIDO2/U2F key with touch requirement

## Troubleshooting

### Plugin Never Shows

1. Verify key requires touch:
   ```bash
   # For YubiKey
   ykman info
   ```

2. Check if detection methods are available:
   ```bash
   which gpg-connect-agent
   which pcsc_scan
   ```

3. Test with a signing operation:
   ```bash
   echo "test" | gpg --sign
   # Plugin should show during touch wait
   ```

### Plugin Shows But Disappears Quickly

The cache TTL is 2 seconds by default. Touch states can be very brief. This is expected behavior.

### False Positives

If the plugin shows "TOUCH" when not expected:

1. Check for background GPG operations
2. Verify no other processes are accessing the key
3. Ensure yubikey-touch-detector (if installed) is working correctly

### Detection Not Working for Specific Operations

Different operations use different detection methods. If a specific operation isn't detected:

1. Try installing yubikey-touch-detector for most reliable detection
2. Check if the operation uses scdaemon, FIDO2, or CCID
3. Report the issue with details about the operation

## Performance Notes

- Very short cache TTL (2 seconds) for responsiveness
- Detection methods are checked in priority order, early exit on first match
- Minimal overhead when no key activity

## Platform Differences

### macOS

- Uses `ioreg` for YubiKey busy state detection
- Uses `osascript` for pinentry-mac detection

### Linux

- Uses `/sys/class/hidraw` for device detection
- Uses `/proc` filesystem for process inspection
- PCSC daemon integration available

## Related Plugins

- [PluginBitwarden](PluginBitwarden) - Bitwarden vault status (can use hardware key)
- [PluginGit](PluginGit) - Git status (signing uses hardware key)
- [PluginSsh](PluginSsh) - SSH session indicator
