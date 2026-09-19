# Plugin: cloud

Display active cloud provider context (AWS/GCP/Azure) with session status.

## Screenshot

```
 production@us-east-1          # AWS profile with region
󰠅 my-subscription              # Azure subscription
󱇶 my-gcp-project               # GCP project
󰅟 prod-aws | staging-gcp       # Multiple providers
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | At least one of: `aws`, `gcloud`, `az` CLI |
| Content Type | dynamic |
| Presence | conditional |

## Installation

```bash
# AWS CLI
brew install awscli  # macOS
pip install awscli   # Linux

# Google Cloud SDK
brew install google-cloud-sdk  # macOS
# See https://cloud.google.com/sdk/docs/install for Linux

# Azure CLI
brew install azure-cli  # macOS
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash  # Debian/Ubuntu
```

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "cloud"
```

## Configuration Example

```bash
set -g @powerkit_plugins "cloud"

# Providers to monitor (all, or comma-separated list)
set -g @powerkit_plugin_cloud_providers "all"

# Show AWS region in display
set -g @powerkit_plugin_cloud_show_region "true"

# Verify session validity (not just config)
set -g @powerkit_plugin_cloud_verify_session "true"

# Icons
set -g @powerkit_plugin_cloud_icon "󰅟"
set -g @powerkit_plugin_cloud_icon_aws ""
set -g @powerkit_plugin_cloud_icon_gcp "󱇶"
set -g @powerkit_plugin_cloud_icon_azure "󰠅"
set -g @powerkit_plugin_cloud_icon_multi "󰅟"

# Cache duration (5 minutes)
set -g @powerkit_plugin_cloud_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_cloud_providers` | string | `all` | Providers to monitor: `all` or `aws,gcp,azure` |
| `@powerkit_plugin_cloud_show_region` | bool | `false` | Show AWS region in display |
| `@powerkit_plugin_cloud_verify_session` | bool | `true` | Verify active session (not just config) |
| `@powerkit_plugin_cloud_icon` | icon | `󰅟` | Default cloud icon |
| `@powerkit_plugin_cloud_icon_aws` | icon | `` | AWS icon |
| `@powerkit_plugin_cloud_icon_gcp` | icon | `󱇶` | GCP icon |
| `@powerkit_plugin_cloud_icon_azure` | icon | `󰠅` | Azure icon |
| `@powerkit_plugin_cloud_icon_multi` | icon | `󰅟` | Multi-provider icon |
| `@powerkit_plugin_cloud_cache_ttl` | number | `300` | Cache duration in seconds (5 minutes) |
| `@powerkit_plugin_cloud_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Provider Detection

### AWS
Checks in order:
1. `AWS_PROFILE` environment variable
2. `AWS_DEFAULT_PROFILE` environment variable
3. `~/.aws/config` default profile
4. First profile in config file

Session validation:
- SSO token cache (`~/.aws/sso/cache/*.json`)
- Credentials cache (`~/.aws/cli/cache/*.json`)
- `aws sts get-caller-identity` (fallback)

### GCP
Checks in order:
1. `CLOUDSDK_CORE_PROJECT` environment variable
2. `GOOGLE_CLOUD_PROJECT` environment variable
3. `~/.config/gcloud/configurations/config_default`

Session validation:
- Application default credentials
- Active account in gcloud properties
- `gcloud auth print-access-token` (fallback)

### Azure
Checks in order:
1. `AZURE_SUBSCRIPTION_ID` environment variable
2. `~/.azure/azureProfile.json` default subscription

Session validation:
- Access tokens (`~/.azure/accessTokens.json`)
- MSAL token cache (`~/.azure/msal_token_cache.json`)
- `az account show` (fallback)

## States

| State | Condition |
|-------|-----------|
| `active` | Cloud provider detected and session active |
| `inactive` | No cloud provider detected |
| `degraded` | Provider detected but session expired/invalid |

## Health Levels

| Level | Condition |
|-------|-----------|
| `good` | Session is active and valid |
| `warning` | Session expired or not authenticated |

## Context Values

| Context | Condition |
|---------|-----------|
| `aws` | AWS provider active |
| `gcp` | GCP provider active |
| `azure` | Azure provider active |
| `multi` | Multiple providers active |
| `none` | No provider detected |

## Display Examples

**AWS with region:**
```
 production@us-east-1
```

**AWS without region:**
```
 production
```

**GCP:**
```
󱇶 my-gcp-project
```

**Azure:**
```
󰠅 my-subscription
```

**Multiple providers:**
```
󰅟 prod-aws | staging-gcp
```

## Environment Variables

| Variable | Provider | Purpose |
|----------|----------|---------|
| `AWS_PROFILE` | AWS | Active profile name |
| `AWS_DEFAULT_PROFILE` | AWS | Default profile name |
| `AWS_REGION` | AWS | Active region |
| `AWS_DEFAULT_REGION` | AWS | Default region |
| `CLOUDSDK_CORE_PROJECT` | GCP | Active project |
| `GOOGLE_CLOUD_PROJECT` | GCP | Active project |
| `AZURE_SUBSCRIPTION_ID` | Azure | Active subscription |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Plugin not showing | Ensure at least one cloud CLI is installed |
| Session shows as expired | Re-authenticate with your cloud provider |
| Wrong profile shown | Check environment variables and config files |
| Slow rendering | Increase `cache_ttl` or disable `verify_session` |

## Related Plugins

- [PluginKubernetes](PluginKubernetes) - Kubernetes context and namespace
- [PluginTerraform](PluginTerraform) - Terraform workspace
