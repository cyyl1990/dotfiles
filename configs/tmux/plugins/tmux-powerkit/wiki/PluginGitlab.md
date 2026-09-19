# Plugin: gitlab

Monitor GitLab repositories for merge requests and issues with support for both GitLab.com and self-hosted instances.

## Screenshots

```
 3i / 2mr
 5 issues
 2 merge requests
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `curl`, `jq` (optional but recommended) |
| Content Type | dynamic |
| Presence | conditional (hidden when no activity) |

## Installation

### Using glab CLI (recommended)

```bash
# macOS
brew install glab

# Linux
# Download from https://gitlab.com/gitlab-org/cli/-/releases

# Authenticate
glab auth login
```

### Using API Token

```bash
# Create personal access token at:
# https://gitlab.com/-/profile/personal_access_tokens
# Scopes: read_api

# Set in environment
export GITLAB_TOKEN="your-token"
# Or
export GITLAB_PRIVATE_TOKEN="your-token"
```

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "gitlab"

# For specific repos (optional)
set -g @powerkit_plugin_gitlab_repos "username/repo1,group/repo2"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "gitlab"

# GitLab configuration
set -g @powerkit_plugin_gitlab_url "https://gitlab.com"
set -g @powerkit_plugin_gitlab_repos "myuser/project1,myteam/project2"
set -g @powerkit_plugin_gitlab_token ""  # Or use env vars

# Display options
set -g @powerkit_plugin_gitlab_show_issues "true"
set -g @powerkit_plugin_gitlab_show_mrs "true"
set -g @powerkit_plugin_gitlab_separator " | "

# Icons
set -g @powerkit_plugin_gitlab_icon ""
set -g @powerkit_plugin_gitlab_icon_issue ""
set -g @powerkit_plugin_gitlab_icon_mr ""

# Thresholds
set -g @powerkit_plugin_gitlab_warning_threshold_issues "10"
set -g @powerkit_plugin_gitlab_warning_threshold_mrs "5"

# Cache (5 minutes)
set -g @powerkit_plugin_gitlab_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_gitlab_url` | string | `https://gitlab.com` | GitLab instance URL (supports self-hosted) |
| `@powerkit_plugin_gitlab_repos` | string | `` | Comma-separated list: `owner/repo` or `group/project` |
| `@powerkit_plugin_gitlab_token` | string | `` | GitLab personal access token |
| `@powerkit_plugin_gitlab_show_issues` | bool | `true` | Show open issues count |
| `@powerkit_plugin_gitlab_show_mrs` | bool | `true` | Show open merge requests count |
| `@powerkit_plugin_gitlab_separator` | string | ` \| ` | Separator between metrics |
| `@powerkit_plugin_gitlab_icon` | icon | `` | GitLab icon |
| `@powerkit_plugin_gitlab_icon_issue` | icon | `` | Issues icon (optional) |
| `@powerkit_plugin_gitlab_icon_mr` | icon | `` | Merge request icon (optional) |
| `@powerkit_plugin_gitlab_warning_threshold_issues` | number | `10` | Warning when issues exceed threshold |
| `@powerkit_plugin_gitlab_warning_threshold_mrs` | number | `5` | Warning when MRs exceed threshold |
| `@powerkit_plugin_gitlab_cache_ttl` | number | `300` | Cache duration in seconds (5 minutes) |

## States

| State | Condition |
|-------|-----------|
| `active` | Authenticated and has issues/MRs |
| `inactive` | No issues or MRs |
| `degraded` | API errors encountered |
| `failed` | Not authenticated |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Total items < warning threshold |
| `warning` | Total items >= warning threshold |
| `error` | API errors or not authenticated |

## Context Values

| Context | Description |
|---------|-------------|
| `unauthenticated` | Not logged in or no token |
| `api_error` | API request failed |
| `clear` | No pending items |
| `issues_and_mrs` | Both issues and MRs present |
| `issues_only` | Only issues present |
| `mrs_only` | Only merge requests present |
| `activity` | Has activity |

## Examples

### Using glab CLI (No Configuration Needed)

```bash
# Authenticate with glab
glab auth login

# Enable plugin
set -g @powerkit_plugins "gitlab"
```

The plugin automatically uses `glab` to fetch your assigned issues and MRs.

### Specific Repositories with API Token

```bash
set -g @powerkit_plugins "gitlab"
set -g @powerkit_plugin_gitlab_repos "mygroup/backend,mygroup/frontend"
set -g @powerkit_plugin_gitlab_token "glpat-xxxxxxxxxxxx"
```

### Self-Hosted GitLab

```bash
set -g @powerkit_plugins "gitlab"
set -g @powerkit_plugin_gitlab_url "https://gitlab.company.com"
set -g @powerkit_plugin_gitlab_repos "team/project"
set -g @powerkit_plugin_gitlab_token "glpat-xxxxxxxxxxxx"
```

### Show Only Merge Requests

```bash
set -g @powerkit_plugins "gitlab"
set -g @powerkit_plugin_gitlab_show_issues "false"
set -g @powerkit_plugin_gitlab_show_mrs "true"
```

### Custom Icons

```bash
set -g @powerkit_plugins "gitlab"
set -g @powerkit_plugin_gitlab_icon_issue ""
set -g @powerkit_plugin_gitlab_icon_mr ""
```

## Display Format

The plugin formats output based on what's enabled and available:

| Configuration | Output |
|--------------|--------|
| Both enabled, both have data | `3i / 2mr` or ` 3 /  2` (with icons) |
| Both enabled, only issues | `5i` or ` 5` (with icon) |
| Both enabled, only MRs | `2mr` or ` 2` (with icon) |
| Only issues enabled | `5i` or `5 issues` |
| Only MRs enabled | `2mr` or `2 merge requests` |

## Authentication Methods

The plugin supports multiple authentication methods (tried in order):

1. **glab CLI** (if available and authenticated)
   ```bash
   glab auth status
   ```

2. **Option token**
   ```bash
   set -g @powerkit_plugin_gitlab_token "glpat-xxxxxxxxxxxx"
   ```

3. **Environment variable: GITLAB_TOKEN**
   ```bash
   export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
   ```

4. **Environment variable: GITLAB_PRIVATE_TOKEN**
   ```bash
   export GITLAB_PRIVATE_TOKEN="glpat-xxxxxxxxxxxx"
   ```

## API Usage

The plugin uses GitLab REST API v4:

- **Issues**: `/api/v4/projects/{id}/issues_statistics?scope=all`
- **Merge Requests**: `/api/v4/projects/{id}/merge_requests?state=opened` (uses X-Total header)

Project paths with slashes (e.g., `group/subgroup/project`) are URL-encoded automatically.

## Performance Notes

- Default cache: 5 minutes (API rate limits: 2000 requests/minute for GitLab.com)
- Uses efficient endpoints (`issues_statistics`, HEAD requests for MR count)
- Parallel requests are NOT used (sequential to avoid rate limits)

## Troubleshooting

### Plugin Not Showing

1. Check authentication:
   ```bash
   # Using glab
   glab auth status

   # Using token
   curl -H "PRIVATE-TOKEN: your-token" \
     "https://gitlab.com/api/v4/user"
   ```

2. Verify plugin is enabled:
   ```bash
   tmux show-options -g | grep powerkit_plugins
   ```

3. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin gitlab
   ```

### API Errors

If you see API errors:

1. Check API token permissions (needs `read_api` scope)

2. Verify repository format (use `owner/repo` or `group/project`):
   ```bash
   # Correct
   set -g @powerkit_plugin_gitlab_repos "gitlab-org/gitlab"

   # Incorrect
   set -g @powerkit_plugin_gitlab_repos "https://gitlab.com/gitlab-org/gitlab"
   ```

3. Test API manually:
   ```bash
   # URL-encode project path
   curl -H "PRIVATE-TOKEN: token" \
     "https://gitlab.com/api/v4/projects/gitlab-org%2Fgitlab/issues_statistics?scope=all"
   ```

### Self-Hosted GitLab Issues

1. Ensure URL is accessible:
   ```bash
   curl "https://gitlab.company.com/api/v4/version"
   ```

2. Check SSL certificate issues:
   ```bash
   curl -v "https://gitlab.company.com/api/v4/version"
   ```

3. If using self-signed certs, curl may fail. The plugin doesn't currently support `-k` flag.

### Slow Performance

If plugin is slow:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_gitlab_cache_ttl "600"  # 10 minutes
   ```

2. Reduce number of repos:
   ```bash
   set -g @powerkit_plugin_gitlab_repos "important/repo"
   ```

3. Use glab CLI instead of API:
   ```bash
   # Remove repos option to use glab
   # unset @powerkit_plugin_gitlab_repos
   ```

### glab Not Working

If glab is installed but not being used:

1. Check glab authentication:
   ```bash
   glab auth status
   ```

2. Re-authenticate:
   ```bash
   glab auth login
   ```

3. Verify glab can list MRs:
   ```bash
   glab mr list --assignee @me --state opened
   ```

## Related Plugins

- [PluginGithub](PluginGithub) - Monitor GitHub repositories
- [PluginBitbucket](PluginBitbucket) - Monitor Bitbucket repositories
- [PluginJira](PluginJira) - Monitor Jira issues
- [PluginGit](PluginGit) - Git repository status
