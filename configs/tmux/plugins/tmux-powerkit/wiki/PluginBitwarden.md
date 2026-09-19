# Plugin: bitwarden

Display Bitwarden vault status with interactive password and TOTP selectors for secure credential management.

## Screenshots

```
󰿆 Locked
󰿆 Unlocked
󰅙 Logged Out
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `bw` (Bitwarden CLI) or `rbw` (unofficial Rust client) |
| Content Type | dynamic |
| Presence | conditional (hidden when unauthenticated, or when locked if `show_only_when_unlocked` is enabled) |

## Installation

```bash
# Official Bitwarden CLI
# macOS
brew install bitwarden-cli

# Linux (npm)
npm install -g @bitwarden/cli

# Unofficial Rust client (faster)
cargo install rbw

# Login (official CLI)
bw login

# Unlock vault
bw unlock
```

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "bitwarden"

# Set keybindings
set -g @powerkit_plugin_bitwarden_keybinding_password "C-v"
set -g @powerkit_plugin_bitwarden_keybinding_totp "C-t"
set -g @powerkit_plugin_bitwarden_keybinding_unlock "C-w"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "bitwarden"

# Cache (higher TTL because bw status is slow ~1.5s)
set -g @powerkit_plugin_bitwarden_cache_ttl "60"

# Icons
set -g @powerkit_plugin_bitwarden_icon "󰌋"
set -g @powerkit_plugin_bitwarden_icon_locked "󰌾"
set -g @powerkit_plugin_bitwarden_icon_unlocked "󰿆"
set -g @powerkit_plugin_bitwarden_icon_unauthenticated "󰅙"

# Keybindings
set -g @powerkit_plugin_bitwarden_keybinding_password "C-v"
set -g @powerkit_plugin_bitwarden_keybinding_totp "C-t"
set -g @powerkit_plugin_bitwarden_keybinding_unlock "C-w"
set -g @powerkit_plugin_bitwarden_keybinding_lock ""

# Popup dimensions
set -g @powerkit_plugin_bitwarden_popup_width "60%"
set -g @powerkit_plugin_bitwarden_popup_height "80%"
set -g @powerkit_plugin_bitwarden_popup_unlock_width "40%"
set -g @powerkit_plugin_bitwarden_popup_unlock_height "30%"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_bitwarden_show_only_when_unlocked` | bool | `false` | Only show plugin when vault is unlocked |
| `@powerkit_plugin_bitwarden_cache_ttl` | number | `60` | Cache duration (bw status is slow) |
| `@powerkit_plugin_bitwarden_icon` | icon | `󰌋` | Default icon |
| `@powerkit_plugin_bitwarden_icon_locked` | icon | `󰌾` | Locked vault icon |
| `@powerkit_plugin_bitwarden_icon_unlocked` | icon | `󰿆` | Unlocked vault icon |
| `@powerkit_plugin_bitwarden_icon_unauthenticated` | icon | `󰅙` | Logged out icon |
| `@powerkit_plugin_bitwarden_keybinding_password` | key | `C-v` | Password selector keybinding |
| `@powerkit_plugin_bitwarden_keybinding_totp` | key | `C-t` | TOTP selector keybinding |
| `@powerkit_plugin_bitwarden_keybinding_unlock` | key | `C-w` | Unlock vault keybinding |
| `@powerkit_plugin_bitwarden_keybinding_lock` | key | `` | Lock vault keybinding |
| `@powerkit_plugin_bitwarden_popup_width` | string | `60%` | Password/TOTP popup width |
| `@powerkit_plugin_bitwarden_popup_height` | string | `80%` | Password/TOTP popup height |
| `@powerkit_plugin_bitwarden_popup_unlock_width` | string | `40%` | Unlock popup width |
| `@powerkit_plugin_bitwarden_popup_unlock_height` | string | `30%` | Unlock popup height |

## States

| State | Condition |
|-------|-----------|
| `active` | Vault is locked or unlocked (logged in) |
| `inactive` | Not logged in (unauthenticated), or locked when `show_only_when_unlocked` is enabled |

> **Note:** With `show_only_when_unlocked` enabled, the plugin is only visible when the vault is unlocked. This is useful for a cleaner status bar when you don't need to see the "Locked" status.

## Health Levels

| Level | Condition |
|-------|-----------|
| `good` | Vault is unlocked |
| `warning` | Vault is locked |
| `error` | Not logged in (unauthenticated) |

## Context Values

| Context | Description |
|---------|-------------|
| `unlocked` | Vault is unlocked and accessible |
| `locked` | Vault is locked, master password required |
| `unauthenticated` | Not logged in, credentials required |

## Examples

### Basic Setup with Password Selector

```bash
set -g @powerkit_plugins "bitwarden"
set -g @powerkit_plugin_bitwarden_keybinding_password "C-v"
```

### Full Keybinding Setup

```bash
set -g @powerkit_plugins "bitwarden"
set -g @powerkit_plugin_bitwarden_keybinding_password "C-v"
set -g @powerkit_plugin_bitwarden_keybinding_totp "C-t"
set -g @powerkit_plugin_bitwarden_keybinding_unlock "C-w"
set -g @powerkit_plugin_bitwarden_keybinding_lock "C-l"
```

### Larger Popup for Password Selection

```bash
set -g @powerkit_plugins "bitwarden"
set -g @powerkit_plugin_bitwarden_popup_width "80%"
set -g @powerkit_plugin_bitwarden_popup_height "90%"
```

### Faster Cache Updates

```bash
set -g @powerkit_plugins "bitwarden"
set -g @powerkit_plugin_bitwarden_cache_ttl "30"
```

### Show Only When Unlocked

Hide the plugin when the vault is locked (only show when unlocked):

```bash
set -g @powerkit_plugins "bitwarden"
set -g @powerkit_plugin_bitwarden_show_only_when_unlocked "true"
```

## Keybindings

| Action | Default Key | Description |
|--------|------------|-------------|
| Password Selector | `prefix + C-v` | Search and copy password to clipboard |
| TOTP Selector | `prefix + C-t` | Search and copy TOTP code to clipboard |
| Unlock Vault | `prefix + C-w` | Unlock vault with master password |
| Lock Vault | (not bound) | Lock vault |

## Workflow

### Initial Setup

1. Install Bitwarden CLI
2. Login: `bw login`
3. Unlock: `bw unlock`
4. Export session token to tmux:
   ```bash
   tmux setenv -g BW_SESSION "your-session-token"
   ```

### Using Password Selector

1. Press `prefix + C-v`
2. Search for item (fuzzy search with fzf)
3. Select item
4. Password is copied to clipboard
5. Notification shown in tmux

### Using TOTP Selector

1. Press `prefix + C-t`
2. Search for item with TOTP enabled
3. Select item
4. TOTP code is copied to clipboard
5. Notification shown with code and countdown

### Unlocking Vault

1. Press `prefix + C-w`
2. Enter master password
3. Vault unlocks and session token stored
4. Plugin status updates to "Unlocked"

## Client Support

The plugin supports both official and unofficial Bitwarden clients:

| Client | Command | Speed | Notes |
|--------|---------|-------|-------|
| Official CLI | `bw` | Slow (~1.5s) | Full feature support |
| Unofficial Rust | `rbw` | Fast (~100ms) | Faster, limited features |

The plugin automatically detects which client is available and prefers `bw` if both are installed.

## Session Management

The plugin reads `BW_SESSION` from tmux environment:

```bash
# After unlocking, store session in tmux
bw unlock
# Copy the session token shown
tmux setenv -g BW_SESSION "your-session-token"

# Verify session is stored
tmux showenv -g BW_SESSION
```

For `rbw`, session management is handled automatically by the client.

## Troubleshooting

### Plugin Shows "Logged Out" When Logged In

1. Verify login status:
   ```bash
   bw status
   ```

2. Check if BW_SESSION is set:
   ```bash
   tmux showenv -g BW_SESSION
   ```

3. Unlock vault and set session:
   ```bash
   BW_SESSION=$(bw unlock --raw)
   tmux setenv -g BW_SESSION "$BW_SESSION"
   ```

### Password Selector Not Working

1. Verify fzf is installed:
   ```bash
   which fzf
   ```

2. Check if vault is unlocked:
   ```bash
   bw list items
   ```

3. Test helper script manually:
   ```bash
   bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/bitwarden_password_selector.sh select
   ```

### TOTP Codes Not Showing

1. Verify items have TOTP configured in Bitwarden
2. Check if `jq` is installed (optional but recommended):
   ```bash
   which jq
   ```

3. Test TOTP helper:
   ```bash
   bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/bitwarden_totp_selector.sh select
   ```

### Slow Performance

The official `bw` CLI is slow (~1.5s per call). To improve performance:

1. Use `rbw` instead:
   ```bash
   cargo install rbw
   rbw register
   rbw login
   ```

2. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_bitwarden_cache_ttl "120"
   ```

### Keybinding Conflicts

Check for conflicts with other plugins:
```bash
prefix + C-y  # View all keybindings
```

If conflicts exist, change the keybinding:
```bash
set -g @powerkit_plugin_bitwarden_keybinding_password "C-b"
```

## Security Notes

- Session tokens are stored in tmux environment variables
- Passwords are copied to clipboard and cleared after use
- The plugin never logs passwords or TOTP codes
- Cache stores only vault status (locked/unlocked), not credentials
- Helper scripts use temporary files that are cleaned up automatically

## Helper Scripts

The plugin uses three helper scripts:

1. **bitwarden_password_selector.sh**
   - Search and copy passwords
   - Handles vault unlocking
   - Actions: `select`, `unlock`, `lock`

2. **bitwarden_totp_selector.sh**
   - Search and copy TOTP codes
   - Shows countdown timer
   - Actions: `select`

3. **bitwarden_common.sh**
   - Shared utilities
   - Session management
   - Item parsing

## Related Plugins

- [PluginSmartkey](PluginSmartkey) - Display custom environment variables
- [PluginGit](PluginGit) - Git repository status
