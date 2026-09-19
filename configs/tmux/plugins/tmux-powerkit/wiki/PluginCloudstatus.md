# Plugin: cloudstatus

Monitor cloud provider service status using StatusPage.io compatible APIs.

## Screenshot

```
 ☁ ☁ ☁      # All services operational
 ☁! ☁ ☁     # AWS degraded
 ☁!! ☁ ☁    # AWS major outage
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, BSD |
| **Dependencies** | `curl` (required), `jq` (optional, improves parsing) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# curl is usually pre-installed
# For better JSON parsing, install jq:

# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt install jq curl

# Linux (Arch)
sudo pacman -S jq curl

# Linux (Fedora)
sudo dnf install jq curl
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "cloudstatus"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "cloudstatus"

# Providers to monitor (comma-separated)
set -g @powerkit_plugin_cloudstatus_providers "aws,gcp,azure,cloudflare,github"

# Separator between provider icons
set -g @powerkit_plugin_cloudstatus_separator " "

# Only show providers with issues
set -g @powerkit_plugin_cloudstatus_issues_only "true"

# HTTP request timeout
set -g @powerkit_plugin_cloudstatus_timeout "5"

# Icons
set -g @powerkit_plugin_cloudstatus_icon ""          # Operational icon
set -g @powerkit_plugin_cloudstatus_icon_warning ""  # Warning icon
set -g @powerkit_plugin_cloudstatus_icon_error ""    # Error icon

# Cache duration (5 minutes default)
set -g @powerkit_plugin_cloudstatus_cache_ttl "300"

# Show only on threshold (not applicable)
set -g @powerkit_plugin_cloudstatus_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_cloudstatus_providers` | string | `aws,gcp,azure,cloudflare,github` | Comma-separated list of providers to monitor |
| `@powerkit_plugin_cloudstatus_separator` | string | ` ` | Separator between provider icons |
| `@powerkit_plugin_cloudstatus_issues_only` | bool | `true` | Only show providers with issues (hide operational) |
| `@powerkit_plugin_cloudstatus_timeout` | number | `5` | HTTP request timeout in seconds |
| `@powerkit_plugin_cloudstatus_icon` | icon | `` | Default cloud icon (operational) |
| `@powerkit_plugin_cloudstatus_icon_warning` | icon | `` | Warning icon (degraded service) |
| `@powerkit_plugin_cloudstatus_icon_error` | icon | `` | Error icon (major outage) |
| `@powerkit_plugin_cloudstatus_cache_ttl` | number | `300` | Cache duration in seconds (5 minutes) |
| `@powerkit_plugin_cloudstatus_show_only_on_threshold` | bool | `false` | Only show when warning or critical threshold exceeded |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Has issues to display | Visible |
| `inactive` | All services operational (no issues) | Hidden (when `issues_only="true"`) |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | All monitored services operational | Green |
| `warning` | Minor or degraded issues detected | Yellow |
| `error` | Major or critical issues detected | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `operational` | All services OK |
| `degraded` | Minor issues present |
| `incident` | Major incident active |

## Supported Providers

### Major Cloud Providers (3)

| Provider | Key | Icon | API Endpoint |
|----------|-----|------|--------------|
| **AWS** | `aws` |  | health.aws.amazon.com |
| **Google Cloud** | `gcp` |  | status.cloud.google.com |
| **Microsoft Azure** | `azure` |  | status.azure.com |

### CDN & Infrastructure (3)

| Provider | Key | Icon |
|----------|-----|------|
| **Cloudflare** | `cloudflare` | ☁ |
| **Fastly** | `fastly` | ☁ |
| **Akamai** | `akamai` | ☁ |

### Platform as a Service (5)

| Provider | Key | Icon |
|----------|-----|------|
| **Vercel** | `vercel` |  |
| **Netlify** | `netlify` |  |
| **Heroku** | `heroku` |  |
| **DigitalOcean** | `digitalocean` | ☁ |
| **Linode** | `linode` | ☁ |

### Development Tools (5)

| Provider | Key | Icon |
|----------|-----|------|
| **GitHub** | `github` |  |
| **GitLab** | `gitlab` |  |
| **Bitbucket** | `bitbucket` |  |
| **npm** | `npm` |  |
| **Docker Hub** | `docker` |  |

### CI/CD (2)

| Provider | Key | Icon |
|----------|-----|------|
| **CircleCI** | `circleci` | ☁ |
| **Travis CI** | `travisci` | ☁ |

### Communication (3)

| Provider | Key | Icon |
|----------|-----|------|
| **Discord** | `discord` |  |
| **Slack** | `slack` |  |
| **Zoom** | `zoom` |  |

### Databases & Services (3)

| Provider | Key | Icon |
|----------|-----|------|
| **MongoDB Atlas** | `mongodb` |  |
| **Redis Cloud** | `redis` |  |
| **Datadog** | `datadog` |  |

### Payment & Auth (3)

| Provider | Key | Icon |
|----------|-----|------|
| **Stripe** | `stripe` |  |
| **Auth0** | `auth0` |  |
| **Okta** | `okta` |  |

### Monitoring (2)

| Provider | Key | Icon |
|----------|-----|------|
| **PagerDuty** | `pagerduty` |  |
| **New Relic** | `newrelic` |  |

**Total**: 32 supported providers

## Status Indicators

| Indicator | Meaning |
|-----------|---------|
| `` (icon only) | Service operational |
| `!` (one exclamation) | Minor/degraded performance |
| `!!` (two exclamations) | Major outage/critical issue |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "cloudstatus"
# Uses default providers: aws,gcp,azure,cloudflare,github
```

### Monitor Specific Services

```bash
set -g @powerkit_plugins "cloudstatus"
set -g @powerkit_plugin_cloudstatus_providers "github,vercel,netlify"
```

### Show All Services (Including Operational)

```bash
set -g @powerkit_plugins "cloudstatus"
set -g @powerkit_plugin_cloudstatus_issues_only "false"
```

### Custom Separator

```bash
set -g @powerkit_plugins "cloudstatus"
set -g @powerkit_plugin_cloudstatus_separator " · "
```

### Fast Updates

```bash
set -g @powerkit_plugins "cloudstatus"
set -g @powerkit_plugin_cloudstatus_cache_ttl "60"  # 1 minute
```

### Monitor DevOps Stack

```bash
set -g @powerkit_plugins "cloudstatus"
set -g @powerkit_plugin_cloudstatus_providers "github,circleci,docker,datadog"
```

## Troubleshooting

### Plugin Not Showing

1. Check if curl is installed:
   ```bash
   which curl
   ```

2. Test API endpoints manually:
   ```bash
   curl -s "https://www.githubstatus.com/api/v2/status.json"
   ```

3. Check cache:
   ```bash
   ls -la ~/.cache/tmux-powerkit/data/
   ```

### Slow Status Updates

- Default cache is 5 minutes (300 seconds)
- Reduce for faster updates:
  ```bash
  set -g @powerkit_plugin_cloudstatus_cache_ttl "60"
  ```

### Timeout Errors

- Increase timeout for slow networks:
  ```bash
  set -g @powerkit_plugin_cloudstatus_timeout "10"
  ```

### Wrong Status Displayed

- Some providers use custom status formats
- Plugin may misinterpret custom statuses
- Check provider's status page manually

### Too Many Icons

- Use `issues_only="true"` (default) to hide operational services
- Or select fewer providers:
  ```bash
  set -g @powerkit_plugin_cloudstatus_providers "aws,github"
  ```

## API Details

All providers use **StatusPage.io** compatible APIs (or similar JSON endpoints):

- Returns JSON with status indicator
- Standard indicators: `none`, `minor`, `major`, `critical`
- Some providers use custom formats (AWS, GCP, Azure, Slack, Heroku)
- Plugin normalizes all formats to: `ok`, `warning`, `error`

## Related Plugins

- [PluginCloud](PluginCloud) - Active cloud provider context (AWS/GCP/Azure profiles)
- [PluginGithub](PluginGithub) - GitHub issues/PRs
- [PluginGitlab](PluginGitlab) - GitLab merge requests
- [PluginExternalip](PluginExternalip) - Public IP address
