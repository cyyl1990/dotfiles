# Plugin: terraform

Display Terraform/OpenTofu workspace with production warnings and pending changes indicator.

## Screenshots

```
󱁢 production
󱁢 dev
󱁣 staging*
󱁢 default
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux, FreeBSD |
| Dependencies | `terraform` or `tofu` (OpenTofu) |
| Content Type | dynamic |
| Presence | conditional (hidden outside Terraform directories) |

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "terraform"

# Optional: Add workspace selector keybinding
set -g @powerkit_plugin_terraform_keybinding_workspace ""

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "terraform"

# Tool selection (auto detects terraform or tofu)
set -g @powerkit_plugin_terraform_tool "auto"

# Display options
set -g @powerkit_plugin_terraform_show_pending "true"

# Production warning
set -g @powerkit_plugin_terraform_warn_on_prod "true"
set -g @powerkit_plugin_terraform_prod_keywords "prod,production,prd"

# Icons
set -g @powerkit_plugin_terraform_icon "󱁢"
set -g @powerkit_plugin_terraform_icon_pending "󱁣"

# Keybindings
set -g @powerkit_plugin_terraform_keybinding_workspace ""
set -g @powerkit_plugin_terraform_popup_width "60%"
set -g @powerkit_plugin_terraform_popup_height "60%"

# Cache
set -g @powerkit_plugin_terraform_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_terraform_tool` | enum | `auto` | Preferred tool: `auto`, `terraform`, or `tofu` |
| `@powerkit_plugin_terraform_show_pending` | bool | `true` | Show indicator for pending changes |
| `@powerkit_plugin_terraform_warn_on_prod` | bool | `true` | Warn when in production workspace |
| `@powerkit_plugin_terraform_prod_keywords` | string | `prod,production,prd` | Comma-separated production keywords |
| `@powerkit_plugin_terraform_icon` | icon | `󱁢` | Default Terraform icon |
| `@powerkit_plugin_terraform_icon_pending` | icon | `󱁣` | Pending changes icon |
| `@powerkit_plugin_terraform_keybinding_workspace` | string | `` | Keybinding for workspace selector |
| `@powerkit_plugin_terraform_popup_width` | string | `60%` | Workspace selector popup width |
| `@powerkit_plugin_terraform_popup_height` | string | `60%` | Workspace selector popup height |
| `@powerkit_plugin_terraform_cache_ttl` | number | `5` | Cache duration in seconds |

## States

| State | Condition |
|-------|-----------|
| `active` | In Terraform directory, workspace detected |
| `degraded` | In Terraform directory with pending changes |
| `inactive` | Not in Terraform directory |

### Context-Aware Visibility

This plugin uses `plugin_should_be_active()` to check if the current pane is in a Terraform directory **before** returning cached data. This ensures the plugin disappears immediately when switching to a non-Terraform directory, rather than showing stale data from the previous context.

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Non-production workspace, no pending changes |
| `warning` | Pending changes detected |
| `error` | Production workspace (based on keywords) |

## Context Values

| Context | Description |
|---------|-------------|
| `none` | Not in Terraform directory |
| `production` | In production workspace |
| `production_pending` | In production with pending changes |
| `default` | Using default workspace |
| `default_pending` | Default workspace with pending changes |
| `staging` | In staging workspace |
| `staging_pending` | Staging workspace with pending changes |
| `development` | In development workspace |
| `development_pending` | Development workspace with pending changes |
| `custom` | Custom workspace name |
| `custom_pending` | Custom workspace with pending changes |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "terraform"
```

### Using OpenTofu

```bash
set -g @powerkit_plugins "terraform"
set -g @powerkit_plugin_terraform_tool "tofu"
```

### Add Workspace Selector

```bash
set -g @powerkit_plugins "terraform"
set -g @powerkit_plugin_terraform_keybinding_workspace "C-w"
```

### Custom Production Keywords

```bash
set -g @powerkit_plugins "terraform"
set -g @powerkit_plugin_terraform_prod_keywords "prod,production,live,prd"
```

### Show Only in Terraform Directories

```bash
set -g @powerkit_plugins "terraform"
set -g @powerkit_plugin_terraform_show_only_in_dir "true"
```

### Disable Pending Changes Indicator

```bash
set -g @powerkit_plugins "terraform"
set -g @powerkit_plugin_terraform_show_pending "false"
```

## Workspace Detection

The plugin detects Terraform workspaces using multiple methods:

1. **Environment file** (fastest, no command execution)
   - Reads `.terraform/environment`

2. **Tool command** (fallback)
   - `terraform workspace show`
   - `tofu workspace show`

3. **Default** (if nothing found)
   - Returns "default"

## Terraform Directory Detection

A directory is considered a Terraform directory if it contains:

- `.terraform/` directory (initialized project)
- `*.tf` files (Terraform configuration files)

## Pending Changes Detection

The plugin detects pending changes by checking for:

- `tfplan` file in current directory
- `tfplan` file in `.terraform/` directory

These files are created by `terraform plan -out=tfplan`.

## Production Warning

When `warn_on_prod` is enabled, the plugin:

1. Checks workspace name against `prod_keywords` (case-insensitive)
2. Sets health to `error` if match found
3. Displays workspace in error color (red by default)

This helps prevent accidental modifications to production infrastructure.

## OpenTofu Support

OpenTofu is a fork of Terraform. The plugin supports both:

| Tool | Command | Detection |
|------|---------|-----------|
| Terraform | `terraform` | Checked first if `tool = terraform` |
| OpenTofu | `tofu` | Checked first if `tool = tofu` |

The plugin automatically falls back to the other tool if the preferred one isn't available.

## Keybindings

| Action | Default Key | Description |
|--------|------------|-------------|
| Workspace Selector | (not bound) | Interactive workspace selector |

The workspace selector uses tmux `display-menu` (not popup) to show and switch between available workspaces.

## Display Format

| Condition | Output |
|-----------|--------|
| `show_workspace = true` | `workspace` (e.g., `production`) |
| `show_workspace = true` + pending | `workspace*` (e.g., `staging*`) |
| `show_workspace = false` | `TF` |

## Troubleshooting

### Plugin Not Showing

1. Verify you're in a Terraform directory:
   ```bash
   ls .terraform/
   ls *.tf
   ```

2. Check tool availability:
   ```bash
   which terraform
   # or
   which tofu
   ```

3. Verify workspace:
   ```bash
   terraform workspace show
   # or
   tofu workspace show
   ```

4. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin terraform
   ```

### Wrong Workspace Showing

The plugin reads from `.terraform/environment` file. If this is out of sync:

```bash
# Remove environment file
rm .terraform/environment

# Reinitialize
terraform init

# Select workspace
terraform workspace select <name>
```

### Production Warning Not Showing

1. Check workspace name matches keywords:
   ```bash
   terraform workspace show
   ```

2. Verify keywords configuration:
   ```bash
   tmux show-options -g | grep terraform_prod_keywords
   ```

3. Keywords are case-insensitive partial matches:
   - `prod` matches: `prod`, `production`, `prod-us-east`
   - `prd` matches: `prd`, `prd-staging`

### Workspace Selector Not Working

1. Verify keybinding is set:
   ```bash
   tmux show-options -g | grep terraform_keybinding
   ```

2. Check for keybinding conflicts:
   ```bash
   tmux list-keys | grep "C-w"
   ```

3. Test helper script manually:
   ```bash
   bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/terraform_workspace_selector.sh select
   ```

### Pending Changes Always Showing

The plugin looks for `tfplan` files. If always showing:

1. Check for leftover plan files:
   ```bash
   find . -name "tfplan"
   ```

2. Remove old plan files:
   ```bash
   rm tfplan
   rm .terraform/tfplan
   ```

3. Or disable pending detection:
   ```bash
   set -g @powerkit_plugin_terraform_show_pending "false"
   ```

## Best Practices

### Production Safety

Always enable production warnings:
```bash
set -g @powerkit_plugin_terraform_warn_on_prod "true"
set -g @powerkit_plugin_terraform_prod_keywords "prod,production,live"
```

This provides visual confirmation when working in production environments.

### Workflow Integration

Use workspace selector for quick switching:
```bash
set -g @powerkit_plugin_terraform_keybinding_workspace "C-w"
```

Then:
1. Navigate to Terraform directory
2. Press `prefix + C-w`
3. Select workspace from menu
4. Plugin updates automatically

### Multi-Environment Projects

For projects with many environments, customize keywords:
```bash
set -g @powerkit_plugin_terraform_prod_keywords "prod,production,live,prd"
```

This ensures all production-like environments trigger warnings.

## Helper Scripts

The plugin uses `src/helpers/terraform_workspace_selector.sh` for workspace management:

```bash
# List workspaces
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/terraform_workspace_selector.sh list

# Select workspace
bash ~/.config/tmux/plugins/tmux-powerkit/src/helpers/terraform_workspace_selector.sh select
```

## Related Plugins

- [PluginKubernetes](PluginKubernetes) - Kubernetes context and namespace
- [PluginCloud](PluginCloud) - Cloud provider profile
- [PluginGit](PluginGit) - Git repository status
