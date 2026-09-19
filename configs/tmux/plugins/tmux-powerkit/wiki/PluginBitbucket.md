# Plugin: bitbucket

Display Bitbucket pull requests and issues count.

## Screenshot

```
  5 |  3                     # 5 issues, 3 PRs with icons
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
set -g @powerkit_plugins "bitbucket"

# Configure credentials
set -g @powerkit_plugin_bitbucket_repos "workspace/repo"
set -g @powerkit_plugin_bitbucket_email "your@email.com"
set -g @powerkit_plugin_bitbucket_token "app-password-here"
```

## Configuration Example

### Bitbucket Cloud

```bash
set -g @powerkit_plugins "bitbucket"

# Bitbucket Cloud (default)
set -g @powerkit_plugin_bitbucket_type "cloud"
set -g @powerkit_plugin_bitbucket_repos "my-workspace/repo1,my-workspace/repo2"
set -g @powerkit_plugin_bitbucket_email "your@email.com"
set -g @powerkit_plugin_bitbucket_token "your-app-password"

# Display options
set -g @powerkit_plugin_bitbucket_show_issues "on"
set -g @powerkit_plugin_bitbucket_show_prs "on"
set -g @powerkit_plugin_bitbucket_separator " | "

# Icons
set -g @powerkit_plugin_bitbucket_icon ""
set -g @powerkit_plugin_bitbucket_icon_issue ""
set -g @powerkit_plugin_bitbucket_icon_pr ""

# Thresholds
set -g @powerkit_plugin_bitbucket_warning_threshold_issues "10"
set -g @powerkit_plugin_bitbucket_warning_threshold_prs "5"

# Cache duration (5 minutes)
set -g @powerkit_plugin_bitbucket_cache_ttl "300"
```

### Bitbucket Data Center

```bash
set -g @powerkit_plugins "bitbucket"

# Bitbucket Data Center / Server
set -g @powerkit_plugin_bitbucket_type "datacenter"
set -g @powerkit_plugin_bitbucket_url "https://bitbucket.yourcompany.com"
set -g @powerkit_plugin_bitbucket_repos "PROJECT/repo1,PROJECT/repo2"
set -g @powerkit_plugin_bitbucket_token "your-personal-access-token"

# Note: email is not needed for Data Center
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_bitbucket_type` | string | `cloud` | Bitbucket type: `cloud` or `datacenter` |
| `@powerkit_plugin_bitbucket_url` | string | `` | API URL (required for datacenter, auto for cloud) |
| `@powerkit_plugin_bitbucket_repos` | string | `` | Comma-separated list of workspace/repo or project/repo |
| `@powerkit_plugin_bitbucket_email` | string | `` | Atlassian account email (required for cloud) |
| `@powerkit_plugin_bitbucket_token` | string | `` | App password (cloud) or PAT (datacenter) |
| `@powerkit_plugin_bitbucket_show_issues` | bool | `on` | Show open issues count |
| `@powerkit_plugin_bitbucket_show_prs` | bool | `on` | Show open PRs count |
| `@powerkit_plugin_bitbucket_separator` | string | ` \| ` | Separator between metrics |
| `@powerkit_plugin_bitbucket_icon` | icon | `` | Plugin icon |
| `@powerkit_plugin_bitbucket_icon_issue` | icon | `` | Issues icon |
| `@powerkit_plugin_bitbucket_icon_pr` | icon | `` | PR icon |
| `@powerkit_plugin_bitbucket_warning_threshold_issues` | number | `10` | Warning when issues exceed threshold |
| `@powerkit_plugin_bitbucket_warning_threshold_prs` | number | `5` | Warning when PRs exceed threshold |
| `@powerkit_plugin_bitbucket_cache_ttl` | number | `300` | Cache duration in seconds |
| `@powerkit_plugin_bitbucket_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Authentication

### Bitbucket Cloud

1. Go to [Bitbucket App Passwords](https://bitbucket.org/account/settings/app-passwords/)
2. Create an App Password with:
   - `Repositories: Read`
   - `Pull requests: Read`
   - `Issues: Read`
3. Use your Atlassian email and the app password

### Bitbucket Data Center

1. Go to your profile -> Personal Access Tokens
2. Create a token with:
   - `Repository read`
   - `Pull request read`
3. Use only the token (no email needed)

## States

| State | Condition |
|-------|-----------|
| `active` | Has open issues or PRs |
| `inactive` | No issues or PRs |
| `failed` | Missing or invalid credentials |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Total below warning threshold |
| `warning` | Total >= warning threshold |
| `error` | Not configured or authentication failed |

## Context Values

| Context | Condition |
|---------|-----------|
| `clear` | No issues or PRs |
| `pr_heavy` | More PRs than issues |
| `issue_heavy` | More issues than PRs |
| `balanced` | Equal issues and PRs |
| `unconfigured` | Missing credentials |

## Display Examples

**With issues and PRs:**
```
  5 |  3
```

**PRs only:**
```
  3
```

**Issues only:**
```
  5
```

## Cloud vs Data Center

| Feature | Cloud | Data Center |
|---------|-------|-------------|
| URL | Auto (api.bitbucket.org) | Required |
| Auth | Email + App Password | PAT only |
| Issues | Supported | Not supported (use Jira) |
| Repos format | `workspace/repo` | `PROJECT/repo` |

## API Endpoints Used

### Cloud
- Issues: `/repositories/{workspace}/{repo}/issues`
- PRs: `/repositories/{workspace}/{repo}/pullrequests`

### Data Center
- PRs: `/rest/api/1.0/projects/{project}/repos/{repo}/pull-requests`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Shows "Not configured" | Check all required credentials are set |
| Authentication failed | Verify email/token combination |
| Wrong counts | Check repository path format |
| No issues shown | Data Center doesn't support issues; use Jira |

## Security Note

Store sensitive credentials securely:

```bash
# Option 1: Environment variable
set -g @powerkit_plugin_bitbucket_token "$BITBUCKET_TOKEN"

# Option 2: File sourcing
run-shell "source ~/.secrets && tmux set @powerkit_plugin_bitbucket_token $BB_TOKEN"
```

## Related Plugins

- [PluginGithub](PluginGithub) - GitHub issues and PRs
- [PluginGitlab](PluginGitlab) - GitLab merge requests
- [PluginJira](PluginJira) - Jira issues
- [PluginGit](PluginGit) - Local git status
