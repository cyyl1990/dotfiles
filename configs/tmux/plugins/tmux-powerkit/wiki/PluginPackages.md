# Plugin: packages

Display count of pending package updates across multiple package managers with threshold-based warnings.

## Screenshots

```
󰏔 5 updates
󰏔 23 updates
󰏔 Updates available
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | Package manager: `brew`, `yay`, `apt`, `dnf`, `yum`, or `pacman` |
| Content Type | dynamic |
| Presence | conditional (hidden when no updates) |

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "packages"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "packages"

# Backend selection (auto, brew, yay, apt, dnf, yum, pacman)
set -g @powerkit_plugin_packages_backend "auto"

# Brew-specific options (empty by default)
# Use "--greedy" to include all casks (may show false positives for auto-updating apps)
set -g @powerkit_plugin_packages_brew_options ""

# Display options
set -g @powerkit_plugin_packages_show_count "true"

# Icons
set -g @powerkit_plugin_packages_icon ""

# Thresholds
set -g @powerkit_plugin_packages_warning_threshold "10"
set -g @powerkit_plugin_packages_critical_threshold "50"

# Cache (check for updates infrequently - 1 hour)
set -g @powerkit_plugin_packages_cache_ttl "3600"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_packages_backend` | enum | `auto` | Package manager: `auto`, `brew`, `yay`, `apt`, `dnf`, `yum`, `pacman` |
| `@powerkit_plugin_packages_brew_options` | string | `""` | Additional options for `brew outdated` command (e.g., `--greedy` for all casks) |
| `@powerkit_plugin_packages_show_count` | bool | `true` | Show update count |
| `@powerkit_plugin_packages_icon` | icon | `` | Package icon |
| `@powerkit_plugin_packages_warning_threshold` | number | `10` | Warning threshold for update count |
| `@powerkit_plugin_packages_critical_threshold` | number | `50` | Critical threshold for update count |
| `@powerkit_plugin_packages_cache_ttl` | number | `3600` | Cache duration in seconds (1 hour) |

## States

| State | Condition |
|-------|-----------|
| `active` | Updates available (count > 0) |
| `inactive` | No updates available (plugin hidden) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `info` | Updates < warning threshold |
| `warning` | Updates >= warning threshold and < critical threshold |
| `error` | Updates >= critical threshold |

## Context Values

| Context | Description |
|---------|-------------|
| `up_to_date` | No updates available (count = 0) |
| `few_updates` | 1-5 updates available |
| `some_updates` | 6-20 updates available |
| `many_updates` | More than 20 updates available |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "packages"
```

### Hide Count, Show Only Indicator

```bash
set -g @powerkit_plugins "packages"
set -g @powerkit_plugin_packages_show_count "false"
```

### Aggressive Warning Thresholds

```bash
set -g @powerkit_plugins "packages"
set -g @powerkit_plugin_packages_warning_threshold "5"
set -g @powerkit_plugin_packages_critical_threshold "20"
```

### Check More Frequently

```bash
set -g @powerkit_plugins "packages"
set -g @powerkit_plugin_packages_cache_ttl "1800"  # 30 minutes
```

### Combined with System Monitoring

```bash
set -g @powerkit_plugins "cpu,memory,disk,packages"
```

## Supported Package Managers

The plugin automatically detects and uses the appropriate package manager:

| Package Manager | Platform | Command Used |
|----------------|----------|--------------|
| Homebrew | macOS | `brew outdated [options]` |
| yay | Arch (AUR) | `yay -Qu` |
| DNF | Fedora/RHEL 8+ | `dnf check-update -q` |
| APT | Debian/Ubuntu | `apt list --upgradable` |
| YUM | RHEL/CentOS 7 | `yum check-update -q` |
| Pacman | Arch/Manjaro | `pacman -Qu` |

### Homebrew `--greedy` Flag

By default, the plugin runs `brew outdated` **without** the `--greedy` flag. This checks only:
- Formula packages (command-line tools)
- Casks with version strings tracked by Homebrew

**What `--greedy` does:**
- Includes **all** casks, even those with `version :latest` or auto-updating apps
- May show false positives for apps that update independently (Chrome, VSCode, etc)
- These apps don't sync their installed version back to Homebrew

**When to use `--greedy`:**
```bash
# If you want to check ALL casks (including auto-updating apps)
set -g @powerkit_plugin_packages_brew_options "--greedy"
```

**Recommended approach:**
- Use default (no `--greedy`) for accurate count
- Manually run `brew outdated --greedy` periodically to check casks
- Update casks with: `brew upgrade --cask --greedy`

## Display Format

| Condition | Output |
|-----------|--------|
| `show_count = true` | `X updates` (e.g., `23 updates`) |
| `show_count = false` | `Updates available` |
| No updates | (hidden) |

## Performance Notes

Package update checks can be slow (especially `apt` and `yum`). The default cache TTL is 1 hour to minimize performance impact.

**Important**: The plugin does NOT run `apt-get update` or equivalent commands. It only checks what updates are available based on the last refresh. To ensure accuracy:

```bash
# macOS
brew update

# Debian/Ubuntu
sudo apt update

# RHEL/Fedora
sudo yum check-update

# Arch
sudo pacman -Sy
```

## Troubleshooting

### No Updates Showing When Updates Exist

1. Verify package manager is available:
   ```bash
   which brew  # or apt, yum, pacman
   ```

2. Manually check for updates:
   ```bash
   # macOS
   brew outdated

   # Debian/Ubuntu
   apt list --upgradable

   # RHEL/Fedora
   yum list updates

   # Arch
   pacman -Qu
   ```

3. Clear cache and test:
   ```bash
   rm ~/.cache/tmux-powerkit/data/cache_plugin_packages_*
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin packages
   ```

### Update Count Seems Stale

The plugin caches results for 1 hour by default. To force refresh:

1. Clear the cache:
   ```bash
   rm ~/.cache/tmux-powerkit/data/cache_plugin_packages_*
   ```

2. Refresh tmux:
   ```bash
   tmux refresh-client
   ```

Or reduce cache TTL:
```bash
set -g @powerkit_plugin_packages_cache_ttl "600"  # 10 minutes
```

### Permission Errors

Some package managers may require sudo for certain operations. The plugin uses read-only commands that shouldn't require elevated privileges:

- `brew outdated` - no sudo required
- `apt list` - no sudo required (but `apt update` does)
- `yum list` - may require sudo on some systems
- `pacman -Qu` - no sudo required

If you encounter permission errors with `yum`:
```bash
# Add user to wheel group or configure sudoers
sudo usermod -aG wheel $USER
```

### Slow Performance

If the plugin is causing tmux to lag:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_packages_cache_ttl "7200"  # 2 hours
   ```

2. Check package manager performance:
   ```bash
   time brew outdated  # Should complete in < 2 seconds
   time apt list --upgradable  # May be slower
   ```

## Related Plugins

- [PluginCpu](PluginCpu) - Display CPU usage
- [PluginMemory](PluginMemory) - Display memory usage
- [PluginDisk](PluginDisk) - Display disk usage
