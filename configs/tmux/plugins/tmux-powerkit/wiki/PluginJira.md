# Plugin: jira

Display Jira assigned issues count with interactive issue browser.

## Screenshot

```
 3 issues    # OK - few issues
 12 issues   # Warning - many issues
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `curl`, Jira API token |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

### 1. Get API Token

1. Go to [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Give it a name (e.g., "tmux-powerkit")
4. Copy the generated token

### 2. Configure Plugin

```bash
set -g @powerkit_plugins "jira"

# Required credentials
set -g @powerkit_plugin_jira_domain "your-company.atlassian.net"
set -g @powerkit_plugin_jira_email "your@email.com"
set -g @powerkit_plugin_jira_api_token "your-api-token"
```

## Quick Start

```bash
# Enable plugin with credentials
set -g @powerkit_plugins "jira"
set -g @powerkit_plugin_jira_domain "mycompany.atlassian.net"
set -g @powerkit_plugin_jira_email "john@mycompany.com"
set -g @powerkit_plugin_jira_api_token "ATATT3xFfGF0..."
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "jira"

# Required: API credentials
set -g @powerkit_plugin_jira_domain "your-company.atlassian.net"
set -g @powerkit_plugin_jira_email "your@email.com"
set -g @powerkit_plugin_jira_api_token "your-api-token"

# Custom JQL query (default: assigned and unresolved)
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND status!=Done"

# Display options
set -g @powerkit_plugin_jira_show_count "true"

# Icon
set -g @powerkit_plugin_jira_icon ""

# Keybinding for issue selector
set -g @powerkit_plugin_jira_keybinding_issues "C-j"

# Popup dimensions
set -g @powerkit_plugin_jira_popup_width "80%"
set -g @powerkit_plugin_jira_popup_height "80%"

# Cache duration (seconds)
set -g @powerkit_plugin_jira_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_jira_domain` | string | `` | Jira domain (e.g., `company.atlassian.net`) |
| `@powerkit_plugin_jira_email` | string | `` | Your Atlassian email |
| `@powerkit_plugin_jira_api_token` | string | `` | Jira API token |
| `@powerkit_plugin_jira_jql` | string | `assignee=currentuser() AND status!=Done` | JQL query filter |
| `@powerkit_plugin_jira_show_count` | bool | `true` | Show issue count |
| `@powerkit_plugin_jira_icon` | icon | `` | Plugin icon |
| `@powerkit_plugin_jira_keybinding_issues` | string | `` | Keybinding for issue selector |
| `@powerkit_plugin_jira_popup_width` | string | `80%` | Popup width |
| `@powerkit_plugin_jira_popup_height` | string | `80%` | Popup height |
| `@powerkit_plugin_jira_cache_ttl` | number | `300` | Cache duration for plugin (5 minutes) |
| `@powerkit_plugin_jira_selector_cache_ttl` | number | `7200` | Cache duration for issue selector (2 hours) |
| `@powerkit_plugin_jira_show_only_on_threshold` | bool | `false` | Only show when has issues |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Has assigned issues | Visible |
| `inactive` | No assigned issues | Hidden |
| `failed` | Missing credentials | Hidden (error logged) |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | 10 or fewer issues | Green |
| `warning` | More than 10 issues | Yellow |
| `error` | API error or missing credentials | Red |

## Context Values

| Context | Condition |
|---------|-----------|
| `unconfigured` | Missing credentials |
| `clear` | No issues assigned |
| `light` | 1-3 issues |
| `moderate` | 4-7 issues |
| `busy` | 8+ issues |

## JQL Query Examples

### Default (Assigned and Open)

```bash
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND status!=Done"
```

### Only In Progress

```bash
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND status='In Progress'"
```

### Specific Project

```bash
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND project=MYPROJ AND resolution=Unresolved"
```

### High Priority Only

```bash
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND priority in (High, Highest) AND resolution=Unresolved"
```

### Due This Week

```bash
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND due <= endOfWeek() AND resolution=Unresolved"
```

## Helper: jira_issue_selector

Interactive issue browser with fzf/gum.

### Trigger

| Method | Default | Option |
|--------|---------|--------|
| Keybinding | `prefix + C-j` | `@powerkit_plugin_jira_keybinding_issues` |

### Features

- Browse assigned issues with fuzzy search
- See issue key, summary, status, and priority
- **Automatic flagged issue detection**
- Issues grouped by section (Flagged, In Progress, Backlog)
- Press Enter to open issue in browser
- Press Escape to cancel

### Issue Sections

Issues are automatically grouped into sections:

| Section | Condition | Color |
|---------|-----------|-------|
| **FLAGGED** | Jira flagged field is set, or status contains blocked/impediment/waiting/on hold/paused | Red |
| **IN PROGRESS** | Status category is "In Progress" | Blue |
| **BACKLOG** | All other issues (To Do, etc.) | Yellow |

### Flagged Issue Detection

The selector detects flagged issues through multiple methods:

1. **Jira flagged field**: Standard `flagged` field set to true or "Impediment"
2. **Custom fields**: Fields with names containing "flagged" or "impediment"
3. **Status keywords**: Status name contains: `blocked`, `impediment`, `waiting`, `on hold`, `paused`

### Actions

| Key | Action |
|-----|--------|
| `Enter` | Open selected issue in browser |
| `Escape` | Cancel and close popup |
| Type | Filter issues |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "jira"
set -g @powerkit_plugin_jira_domain "mycompany.atlassian.net"
set -g @powerkit_plugin_jira_email "me@mycompany.com"
set -g @powerkit_plugin_jira_api_token "ATATT3x..."
```

### With Custom Query

```bash
set -g @powerkit_plugins "jira"
set -g @powerkit_plugin_jira_domain "mycompany.atlassian.net"
set -g @powerkit_plugin_jira_email "me@mycompany.com"
set -g @powerkit_plugin_jira_api_token "ATATT3x..."
set -g @powerkit_plugin_jira_jql "assignee=currentuser() AND sprint in openSprints()"
```

### With Issue Selector

```bash
set -g @powerkit_plugins "jira"
set -g @powerkit_plugin_jira_domain "mycompany.atlassian.net"
set -g @powerkit_plugin_jira_email "me@mycompany.com"
set -g @powerkit_plugin_jira_api_token "ATATT3x..."
set -g @powerkit_plugin_jira_keybinding_issues "C-j"
```

## Troubleshooting

### Plugin Not Showing

1. Verify credentials are correct:
   ```bash
   curl -u "email:token" "https://domain.atlassian.net/rest/api/3/myself"
   ```

2. Check if you have assigned issues:
   ```bash
   curl -u "email:token" "https://domain.atlassian.net/rest/api/3/search?jql=assignee=currentuser()"
   ```

### API Errors

- **401 Unauthorized**: Check email and API token
- **403 Forbidden**: API token may have expired
- **404 Not Found**: Check domain is correct

### Cache Issues

Clear the cache to force a refresh:
```bash
rm -rf ~/.cache/tmux-powerkit/data/jira_*
```

## Security Notes

- API tokens are stored in tmux.conf (ensure proper file permissions)
- Consider using environment variables for sensitive data:
  ```bash
  set -g @powerkit_plugin_jira_api_token "$JIRA_API_TOKEN"
  ```

## Related Plugins

- [PluginGithub](PluginGithub) - GitHub notifications and PRs
- [PluginGitlab](PluginGitlab) - GitLab merge requests
- [PluginBitbucket](PluginBitbucket) - Bitbucket pull requests
