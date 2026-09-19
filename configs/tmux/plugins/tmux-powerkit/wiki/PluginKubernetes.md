# Plugin: kubernetes

Display current Kubernetes context and namespace with production warnings and interactive selectors.

## Screenshot

```
 dev/default         # Development context - green/ok
 staging/app-ns      # Staging context - green/ok
 prod/web-app        # Production context - red/error
(disconnected)        # Cluster unreachable - yellow/warning
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `kubectl` (optional - reads kubeconfig directly), `fzf` (optional - for selectors) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# kubectl (Kubernetes CLI)
# macOS
brew install kubectl

# Linux (Debian/Ubuntu)
sudo apt install kubectl

# Linux (Fedora)
sudo dnf install kubectl

# fzf (for interactive selectors)
# macOS
brew install fzf

# Linux
sudo apt install fzf
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "kubernetes"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "kubernetes"

# Display options
set -g @powerkit_plugin_kubernetes_display_mode "connected"
set -g @powerkit_plugin_kubernetes_show_context "true"
set -g @powerkit_plugin_kubernetes_show_namespace "true"
set -g @powerkit_plugin_kubernetes_separator "/"

# Connectivity options
set -g @powerkit_plugin_kubernetes_connectivity_timeout "2"
set -g @powerkit_plugin_kubernetes_connectivity_cache_ttl "120"

# Production warning
set -g @powerkit_plugin_kubernetes_warn_on_prod "true"
set -g @powerkit_plugin_kubernetes_prod_keywords "prod,production,prd"

# Icon
set -g @powerkit_plugin_kubernetes_icon "󱃾"

# Interactive selectors (requires fzf)
set -g @powerkit_plugin_kubernetes_keybinding_context "C-k C-c"
set -g @powerkit_plugin_kubernetes_keybinding_namespace "C-k C-n"
set -g @powerkit_plugin_kubernetes_popup_width "50%"
set -g @powerkit_plugin_kubernetes_popup_height "50%"

# Cache duration (seconds)
set -g @powerkit_plugin_kubernetes_cache_ttl "30"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_kubernetes_display_mode` | string | `connected` | `connected` (only when reachable) or `always` |
| `@powerkit_plugin_kubernetes_show_context` | bool | `true` | Show context name |
| `@powerkit_plugin_kubernetes_show_namespace` | bool | `true` | Show namespace |
| `@powerkit_plugin_kubernetes_separator` | string | `/` | Separator between context and namespace |
| `@powerkit_plugin_kubernetes_connectivity_timeout` | number | `2` | Cluster connectivity timeout (seconds) |
| `@powerkit_plugin_kubernetes_connectivity_cache_ttl` | number | `120` | Connectivity check cache (seconds) |
| `@powerkit_plugin_kubernetes_warn_on_prod` | bool | `true` | Show warning health for production contexts |
| `@powerkit_plugin_kubernetes_prod_keywords` | string | `prod,production,prd` | Comma-separated production keywords |
| `@powerkit_plugin_kubernetes_icon` | icon | `󱃾` | Kubernetes icon |
| `@powerkit_plugin_kubernetes_keybinding_context` | string | `` | Keybinding for context selector (e.g., `C-k C-c`) |
| `@powerkit_plugin_kubernetes_keybinding_namespace` | string | `` | Keybinding for namespace selector (e.g., `C-k C-n`) |
| `@powerkit_plugin_kubernetes_popup_width` | string | `50%` | Popup width for selectors |
| `@powerkit_plugin_kubernetes_popup_height` | string | `50%` | Popup height for selectors |
| `@powerkit_plugin_kubernetes_cache_ttl` | number | `30` | Cache duration in seconds |
| `@powerkit_plugin_kubernetes_show_only_on_threshold` | bool | `false` | Not applicable for this plugin |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Context exists and connected (or display_mode=always) | Visible |
| `inactive` | No kubeconfig or context | Hidden |
| `degraded` | Context exists but cluster unreachable (display_mode=connected) | Visible with warning |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Context available and connected | Green |
| `warning` | Cluster unreachable | Yellow |
| `error` | Production context (when warn_on_prod=true) | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `no_context` | No kubeconfig or context set |
| `disconnected` | Cluster not reachable |
| `production` | Production context (matches prod_keywords) |
| `staging` | Staging context |
| `development` | Development context |
| `local` | Local cluster (minikube, kind, k3s, docker-desktop) |
| `connected` | Connected but environment type unknown |

## Display Modes

### Connected Mode (default)

Only shows when cluster is reachable:

```bash
set -g @powerkit_plugin_kubernetes_display_mode "connected"
```

- Checks cluster connectivity (cached for 120s)
- Hides when cluster is down
- Useful for on-demand clusters

### Always Mode

Always shows context, even when cluster is unreachable:

```bash
set -g @powerkit_plugin_kubernetes_display_mode "always"
```

- Shows even when cluster is down
- No connectivity checks
- Faster, less accurate

## Display Formats

### Context and Namespace (default)

```bash
set -g @powerkit_plugin_kubernetes_show_context "true"
set -g @powerkit_plugin_kubernetes_show_namespace "true"
```

Output: `󱃾 prod/web-app`

### Context Only

```bash
set -g @powerkit_plugin_kubernetes_show_context "true"
set -g @powerkit_plugin_kubernetes_show_namespace "false"
```

Output: `󱃾 prod`

### Namespace Only

```bash
set -g @powerkit_plugin_kubernetes_show_context "false"
set -g @powerkit_plugin_kubernetes_show_namespace "true"
```

Output: `󱃾 web-app`

### Custom Separator

```bash
set -g @powerkit_plugin_kubernetes_separator " | "
```

Output: `󱃾 prod | web-app`

## Context Name Shortening

The plugin automatically shortens context names:

| Original | Shortened | Reason |
|----------|-----------|--------|
| `user@cluster` | `cluster` | Removes user prefix |
| `cluster:context` | `context` | Removes cluster prefix |
| `arn:aws:eks:region:account:cluster/name` | `name` | AWS EKS shortening |
| `gke_project_region_cluster` | `cluster` | GKE shortening |

## Production Warning

When `warn_on_prod` is enabled, contexts matching production keywords show in red:

**Default keywords**: `prod`, `production`, `prd`

Example matches:
- `prod-cluster` ✓
- `production-east` ✓
- `prd-db` ✓
- `staging-prod` ✓ (contains "prod")
- `dev-cluster` ✗

## Interactive Selectors

Keybindings require `fzf` or `gum` and `kubectl`.

### Helper: kubernetes_selector

Interactive context and namespace selector.

#### Actions

| Action | Description |
|--------|-------------|
| `context` | Select Kubernetes context (default) |
| `namespace` | Select namespace in current context |

#### Direct Execution

```bash
# Switch context
./src/helpers/kubernetes_selector.sh context

# Switch namespace
./src/helpers/kubernetes_selector.sh namespace
```

### Context Selector

```bash
set -g @powerkit_plugin_kubernetes_keybinding_context "C-k C-c"
```

- Lists all available contexts
- Switches to selected context
- Works even when cluster is unreachable
- Clears cache after switch

### Namespace Selector

```bash
set -g @powerkit_plugin_kubernetes_keybinding_namespace "C-k C-n"
```

- Lists namespaces from current cluster
- Requires cluster connectivity
- Updates current context namespace
- Clears cache after switch

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "kubernetes"
```

### Show Only When Connected

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_display_mode "connected"
```

### Always Show (Faster)

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_display_mode "always"
```

### Context Only (Save Space)

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_show_namespace "false"
```

### Custom Production Keywords

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_prod_keywords "prod,production,live,prd"
```

### Disable Production Warning

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_warn_on_prod "false"
```

### With Interactive Selectors

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_keybinding_context "C-k c"
set -g @powerkit_plugin_kubernetes_keybinding_namespace "C-k n"
```

Usage:
- Press `Ctrl+k` then `c` to switch context
- Press `Ctrl+k` then `n` to switch namespace

## Kubeconfig Detection

The plugin reads kubeconfig in this order:

1. `$KUBECONFIG` environment variable
2. `~/.kube/config` (default)

### Multiple Kubeconfig Files

```bash
# In your shell config (~/.bashrc, ~/.zshrc)
export KUBECONFIG=~/.kube/config:~/.kube/prod-config:~/.kube/dev-config
```

## Troubleshooting

### No Context Showing

1. Check if kubeconfig exists:
   ```bash
   ls -la ~/.kube/config
   echo $KUBECONFIG
   ```

2. Verify current context:
   ```bash
   kubectl config current-context
   kubectl config view --minify
   ```

3. List all contexts:
   ```bash
   kubectl config get-contexts
   ```

### Always Shows "Disconnected"

If `display_mode=connected` and always shows disconnected:

1. Test cluster connectivity:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

2. Check connectivity timeout:
   ```bash
   # Increase timeout for slow networks
   set -g @powerkit_plugin_kubernetes_connectivity_timeout "5"
   ```

3. Switch to always mode:
   ```bash
   set -g @powerkit_plugin_kubernetes_display_mode "always"
   ```

### Wrong Context/Namespace

1. Verify kubectl shows correct info:
   ```bash
   kubectl config current-context
   kubectl config view --minify | grep namespace
   ```

2. Clear cache:
   ```bash
   rm ~/.cache/tmux-powerkit/kubernetes*
   tmux refresh-client -S
   ```

### Interactive Selector Not Working

1. Check if fzf is installed:
   ```bash
   which fzf
   ```

2. Test selector manually:
   ```bash
   # Context selector
   kubectl config get-contexts -o name | fzf

   # Namespace selector
   kubectl get namespaces -o name | sed 's/namespace\///' | fzf
   ```

3. Verify keybinding syntax:
   ```bash
   # Valid formats
   "C-k c"      # Ctrl+k then c
   "C-k C-c"    # Ctrl+k then Ctrl+c
   "M-k"        # Alt+k
   ```

### Performance Issues

If connectivity checks are slow:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_kubernetes_connectivity_cache_ttl "300"
   ```

2. Use always mode:
   ```bash
   set -g @powerkit_plugin_kubernetes_display_mode "always"
   ```

## Kubeconfig File Access

The plugin can work **without kubectl**:

- Reads `~/.kube/config` directly using `awk`
- Parses current context and namespace
- Falls back to kubectl if available

This makes the plugin lightweight and fast.

## Performance Notes

- **Connected mode**: Checks connectivity every 120s (cached)
- **Always mode**: No connectivity checks (faster)
- Context/namespace read from file (very fast)
- kubectl only used for connectivity check
- Cache invalidated when kubeconfig changes (auto-detected)

## Use Cases

### Multi-Cluster Management

Track which cluster you're working on:

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_show_context "true"
```

### Production Safety

Visual warning when in production:

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_warn_on_prod "true"
# Production contexts show in red
```

### Quick Context Switching

Interactive selectors for fast switching:

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_keybinding_context "C-k c"
set -g @powerkit_plugin_kubernetes_keybinding_namespace "C-k n"
```

### Minimal Display

Show only when working with kubernetes:

```bash
set -g @powerkit_plugins "kubernetes"
set -g @powerkit_plugin_kubernetes_display_mode "connected"
```

## Environment Detection

The plugin detects environment type from context name:

| Pattern | Context Type |
|---------|--------------|
| `*prod*`, `*production*`, `*prd*` | Production |
| `*stag*`, `*staging*` | Staging |
| `*dev*`, `*development*` | Development |
| `*local*`, `*minikube*`, `*docker-desktop*`, `*kind*`, `*k3*` | Local |

This affects health level when `warn_on_prod=true`.

## Related Plugins

- [PluginTerraform](PluginTerraform) - Terraform workspace
- [PluginCloud](PluginCloud) - Cloud provider context
- [PluginGit](PluginGit) - Git branch indicator
- [PluginSsh](PluginSsh) - SSH session indicator
