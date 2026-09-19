# Plugin: github

Monitor GitHub repositories for issues, PRs, and comments.

## Screenshot

```
 5i | 3p                       # Simple format: 5 issues, 3 PRs
  5 |  3                    # Detailed format with icons
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `curl` (required), `jq` (optional), `gh` CLI (optional) |
| Content Type | dynamic |
| Presence | conditional |

## Installation

```bash
# GitHub CLI (recommended - easiest authentication)
brew install gh
gh auth login

# Or use a Personal Access Token
# Create at: https://github.com/settings/tokens
```

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "github"

# If using gh CLI, no additional config needed
# If using token:
set -g @powerkit_plugin_github_token "ghp_xxxxxxxxxxxx"
set -g @powerkit_plugin_github_repos "owner/repo1,owner/repo2"
```

## Configuration Example

```bash
set -g @powerkit_plugins "github"

# Repository configuration
set -g @powerkit_plugin_github_repos "anthropics/claude-code,facebook/react"
set -g @powerkit_plugin_github_token "ghp_xxxxxxxxxxxx"
set -g @powerkit_plugin_github_filter_user "myusername"

# Display options
set -g @powerkit_plugin_github_show_issues "true"
set -g @powerkit_plugin_github_show_prs "true"
set -g @powerkit_plugin_github_format "detailed"
set -g @powerkit_plugin_github_separator " | "

# Icons
set -g @powerkit_plugin_github_icon ""
set -g @powerkit_plugin_github_icon_issue ""
set -g @powerkit_plugin_github_icon_pr ""

# Thresholds
set -g @powerkit_plugin_github_warning_threshold_issues "10"
set -g @powerkit_plugin_github_warning_threshold_prs "5"

# Cache duration (5 minutes)
set -g @powerkit_plugin_github_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_github_repos` | string | `` | Comma-separated list of owner/repo |
| `@powerkit_plugin_github_token` | string | `` | GitHub personal access token |
| `@powerkit_plugin_github_filter_user` | string | `` | Filter issues/PRs by username |
| `@powerkit_plugin_github_show_issues` | bool | `true` | Show open issues count |
| `@powerkit_plugin_github_show_prs` | bool | `true` | Show open PRs count |
| `@powerkit_plugin_github_format` | string | `detailed` | Format: `simple` or `detailed` |
| `@powerkit_plugin_github_separator` | string | ` \| ` | Separator between metrics |
| `@powerkit_plugin_github_icon` | icon | `` | Plugin icon |
| `@powerkit_plugin_github_icon_issue` | icon | `` | Issues icon |
| `@powerkit_plugin_github_icon_pr` | icon | `` | PR icon |
| `@powerkit_plugin_github_warning_threshold_issues` | number | `10` | Warning when issues exceed threshold |
| `@powerkit_plugin_github_warning_threshold_prs` | number | `5` | Warning when PRs exceed threshold |
| `@powerkit_plugin_github_cache_ttl` | number | `300` | Cache duration in seconds |
| `@powerkit_plugin_github_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Authentication Methods

### 1. GitHub CLI (Recommended)
```bash
gh auth login
```
The plugin will automatically use `gh` CLI authentication.

### 2. Environment Variables
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
# or
export GH_TOKEN="ghp_xxxxxxxxxxxx"
```

### 3. Tmux Option
```bash
set -g @powerkit_plugin_github_token "ghp_xxxxxxxxxxxx"
```

## Format Options

| Value | Description | Example Output |
|-------|-------------|----------------|
| `simple` | Compact with suffixes | `5i \| 3p` |
| `detailed` | With icons | ` 5 \|  3` |

## States

| State | Condition |
|-------|-----------|
| `active` | Authenticated and has issues/PRs |
| `inactive` | Authenticated but no issues/PRs |
| `degraded` | API error occurred |
| `failed` | Not authenticated |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Total below warning threshold |
| `warning` | Total >= warning threshold |
| `error` | Not authenticated or API error |

## Context Values

| Context | Condition |
|---------|-----------|
| `clear` | No issues or PRs |
| `issues_only` | Only issues present |
| `prs_only` | Only PRs present |
| `issues_and_prs` | Both issues and PRs |
| `activity` | General activity |
| `unauthenticated` | Not logged in |
| `api_error` | API call failed |

## Display Examples

**Simple format:**
```
 5i | 3p
```

**Detailed format:**
```
  5 |  3
```

**With comments:**
```
 5i | 3p | 12c
```

## API Rate Limits

- **Authenticated**: 5,000 requests/hour
- **Unauthenticated**: 60 requests/hour

The plugin uses the Search API efficiently to minimize API calls.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Plugin not showing | Check authentication with `gh auth status` |
| Rate limited | Increase `cache_ttl` or authenticate for higher limits |
| Wrong counts | Check `repos` configuration format (owner/repo) |
| API errors | Verify token has `repo` scope |

## Required Token Scopes

- `repo` - Full control of private repositories
- `read:org` - Read org membership (if using org repos)

## Related Plugins

- [PluginGitlab](PluginGitlab) - GitLab merge requests
- [PluginBitbucket](PluginBitbucket) - Bitbucket pull requests
- [PluginJira](PluginJira) - Jira issues
- [PluginGit](PluginGit) - Local git status
