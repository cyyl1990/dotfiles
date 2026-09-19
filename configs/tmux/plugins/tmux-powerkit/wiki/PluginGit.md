# Plugin: git

Display current git branch with modified and untracked file counts.

## Screenshot

```
󰊢 main              # Clean repository - green/ok
󰊢 main ~3           # 3 changed files - yellow/info
󰊢 main ~2 +4        # 2 changed, 4 untracked - yellow/info
󰊢 main ↑2           # 2 commits ahead - yellow/warning
󰊢 main ↓1           # 1 commit behind - yellow/info
󰊢 feature/auth…     # Truncated branch name (max 15 chars)
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, BSD, WSL |
| **Dependencies** | `git` |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS (Homebrew)
brew install git

# Linux (Debian/Ubuntu)
sudo apt install git

# Linux (Fedora)
sudo dnf install git

# Linux (Arch)
sudo pacman -S git
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "git"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "git"

# Icons
set -g @powerkit_plugin_git_icon "󰊢"
set -g @powerkit_plugin_git_icon_modified "󰊢"

# Display options
set -g @powerkit_plugin_git_branch_max_length "15"

# Cache duration (seconds)
set -g @powerkit_plugin_git_cache_ttl "15"

# Only show on threshold (not applicable - based on presence)
set -g @powerkit_plugin_git_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_git_icon` | icon | `󰊢` | Default git icon (clean repository) |
| `@powerkit_plugin_git_icon_modified` | icon | `󰊢` | Icon when repository has changes |
| `@powerkit_plugin_git_branch_max_length` | number | `15` | Maximum branch name length (0 to disable truncation) |
| `@powerkit_plugin_git_cache_ttl` | number | `15` | Cache duration in seconds |
| `@powerkit_plugin_git_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded (N/A for git) |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Inside git repository | Visible |
| `inactive` | Not in git repository or git not found | Hidden |

### Context-Aware Visibility

This plugin uses `plugin_should_be_active()` to check if the current pane is in a git repository **before** returning cached data. This ensures the plugin disappears immediately when switching to a non-git directory, rather than showing stale data from the previous context.

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Clean working tree (no changes, no unpushed commits) | Green |
| `info` | Modified, staged, or untracked files | Yellow |
| `warning` | Commits ahead (unpushed changes) | Orange |

## Context Values

| Context | Description |
|---------|-------------|
| `clean` | No changes in working tree |
| `modified` | Has modified, staged, or untracked files |
| `unpushed` | Has commits not pushed to upstream |

## Display Format

The plugin shows the branch name followed by change indicators:

```
branch ~changed +untracked ↑ahead ↓behind
```

### Components

| Component | Example | Description |
|-----------|---------|-------------|
| Branch name | `main` | Current git branch (truncated if > max length) |
| Changed files | `~3` | Modified or staged files count |
| Untracked files | `+4` | Untracked files count |
| Ahead | `↑2` | Commits ahead of upstream |
| Behind | `↓1` | Commits behind upstream |

### Examples

| Display | Meaning |
|---------|---------|
| `main` | On main branch, clean |
| `main ~2` | On main branch, 2 changed files |
| `main +3` | On main branch, 3 untracked files |
| `main ~2 +3` | On main branch, 2 changed and 3 untracked |
| `main ↑2` | On main branch, 2 commits ahead of upstream |
| `main ↓1` | On main branch, 1 commit behind upstream |
| `main ~1 ↑2 ↓1` | Changes, ahead and behind |
| `feature/aut…` | Branch name truncated (exceeds max length) |

## Git Status Detection

The plugin uses `git status --porcelain=v1` to detect:

| Status Code | Type | Counted As |
|-------------|------|------------|
| `M ` | Modified (staged) | Changed |
| ` M` | Modified (unstaged) | Changed |
| `MM` | Modified (both) | Changed |
| `A ` | Added | Changed |
| `D ` | Deleted | Changed |
| `R ` | Renamed | Changed |
| `C ` | Copied | Changed |
| `??` | Untracked | Untracked |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "git"
```

### Custom Icons

```bash
set -g @powerkit_plugins "git"
set -g @powerkit_plugin_git_icon ""
set -g @powerkit_plugin_git_icon_modified ""
```

### Fast Cache Updates

```bash
set -g @powerkit_plugins "git"
set -g @powerkit_plugin_git_cache_ttl "5"
```

### Slow Cache Updates (Large Repos)

```bash
set -g @powerkit_plugins "git"
set -g @powerkit_plugin_git_cache_ttl "30"
```

### Long Branch Names

```bash
set -g @powerkit_plugins "git"
# Show full branch name (no truncation)
set -g @powerkit_plugin_git_branch_max_length "0"

# Or limit to 25 characters
set -g @powerkit_plugin_git_branch_max_length "25"
```

## Troubleshooting

### Plugin Not Showing

1. Check if you're in a git repository:
   ```bash
   git rev-parse --is-inside-work-tree
   ```

2. Verify git is installed:
   ```bash
   which git
   git --version
   ```

3. Check tmux pane path:
   ```bash
   tmux display-message -p '#{pane_current_path}'
   ```

### Wrong Branch Shown

- The plugin detects the branch of the current tmux pane's working directory
- If you've changed directories in the shell, tmux's `#{pane_current_path}` may not reflect it
- Split a new pane or create a new window to update

### Performance Issues (Large Repos)

For very large repositories, `git status` can be slow:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_git_cache_ttl "60"
   ```

2. Consider using git's sparse checkout or partial clone features

3. Use `.gitignore` to exclude large directories

### Incorrect Count Display

- Counts reflect the current pane's directory, not your current shell directory
- Use `git status --short` to verify the actual changes
- Submodules and nested repositories are not included in counts

## Related Plugins

- [PluginGithub](PluginGithub) - GitHub notifications and PRs
- [PluginGitlab](PluginGitlab) - GitLab merge requests
- [PluginBitbucket](PluginBitbucket) - Bitbucket pull requests
