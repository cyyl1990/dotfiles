# Plugin Contract

The Plugin Contract defines how plugins provide data and semantics for the status bar.

## Overview

Plugins are responsible for collecting data and reporting semantic meaning. They do NOT make visual decisions. The renderer determines colors, formatting, and presentation based on plugin-reported state and health.

## Purpose

Separate data collection from visual presentation, enabling:
- Theme changes without plugin modifications
- Consistent visual behavior across plugins
- Clear boundaries of responsibility

## Responsibilities

Plugins MUST:
- Collect data using `plugin_data_set()`
- Report state: `inactive|active|degraded|failed`
- Report health: `ok|good|info|warning|error`
- Return plain text in `plugin_render()`
- Return appropriate icon in `plugin_get_icon()`

Plugins MUST NOT:
- Decide colors or use color options
- Apply tmux formatting codes
- Build segments
- Access other plugins' data

## Required Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `plugin_collect()` | void | Collect data, store via `plugin_data_set()` |
| `plugin_get_state()` | `inactive\|active\|degraded\|failed` | Plugin operational state |
| `plugin_get_health()` | `ok\|good\|info\|warning\|error` | Data health level |
| `plugin_render()` | string | Plain text content (NO formatting) |
| `plugin_get_icon()` | string | Icon character |

## Functions with Defaults

These functions have default implementations. Override only if needed:

| Function | Default | Override When |
|----------|---------|---------------|
| `plugin_get_content_type()` | `"dynamic"` | Plugin data is static (hostname, uptime) |
| `plugin_get_presence()` | `"conditional"` | Plugin should always be visible |
| `plugin_get_context()` | (empty) | Plugin has contextual states |
| `plugin_check_dependencies()` | `return 0` | Plugin requires commands/binaries |
| `plugin_get_metadata()` | (no-op) | Plugin needs custom metadata |

## Optional Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `plugin_declare_options()` | void | Declare configurable options |
| `plugin_setup_keybindings()` | void | Register keybindings |
| `plugin_should_be_active()` | exit code | Quick context check for conditional plugins |

## Valid Values

### State

| Value | Description |
|-------|-------------|
| `inactive` | Plugin has no data or is disabled |
| `active` | Plugin is working normally |
| `degraded` | Plugin working with reduced functionality |
| `failed` | Plugin encountered an error |

### Health

| Value | Description | Example |
|-------|-------------|---------|
| `ok` | Normal, healthy state | CPU idle, memory normal |
| `good` | Better than ok, positive state | Authenticated, connected, synced |
| `info` | Informational, attention-worthy | Charging, VPN active |
| `warning` | Approaching threshold, needs attention | Battery low, high CPU |
| `error` | Critical, threshold exceeded | Battery critical, auth failed |

### Content Type

| Value | Description |
|-------|-------------|
| `static` | Content rarely changes (hostname, uptime) |
| `dynamic` | Content changes frequently (cpu, memory) |

### Presence

| Value | Description |
|-------|-------------|
| `always` | Always visible in status bar |
| `conditional` | Hidden when inactive |

## Helper Functions

The plugin contract provides helper functions for common patterns:

### Dependency Checking

```bash
# Required dependency (fails if missing)
require_cmd "curl" || return 1

# Optional dependency (logs warning, doesn't fail)
require_cmd "jq" 1

# At least one of these
require_any_cmd "nvidia-smi" "rocm-smi" || return 1

# Check multiple at once
check_dependencies "curl" "jq" || return 1
```

### Threshold Health Evaluation

```bash
# Evaluate health based on value and thresholds
# Usage: evaluate_threshold_health value warn_threshold crit_threshold [invert]
plugin_get_health() {
    local value=$(plugin_data_get "value")
    local warn=$(get_option "warning_threshold")
    local crit=$(get_option "critical_threshold")
    evaluate_threshold_health "$value" "$warn" "$crit"
}

# For inverted thresholds (like battery - lower is worse)
plugin_get_health() {
    local value=$(plugin_data_get "value")
    evaluate_threshold_health "$value" "30" "15" 1  # invert=1
}
```

### Platform-Specific Execution

```bash
# Execute platform-specific command
run_for_platform "macos_cmd" "linux_cmd"

# Get platform-specific value
value=$(get_platform_value "en0" "eth0")
```

### Data Validation

```bash
# Check valid state/health values
is_valid_state "active"   # returns 0 (true)
is_valid_health "warning" # returns 0 (true)
```

## Stale-While-Revalidate Support

The lifecycle automatically handles data freshness. When `plugin_collect()` fails, the lifecycle preserves previous cache and marks the output as "stale", triggering visual indication (darker colors).

### How It Works

1. `plugin_collect()` returns `1` on failure (e.g., API timeout)
2. Lifecycle preserves existing cached data
3. Output is marked with `stale=1` (5th field in lifecycle output)
4. Renderer applies `-darker` color variant for visual feedback

### Plugin Implementation

```bash
plugin_collect() {
    local result
    result=$(fetch_api_data) || return 1  # Return 1 on failure
    plugin_data_set "value" "$result"
}
```

### Lifecycle Output Format

```
icon<US>content<US>state<US>health<US>stale
```

Where:
- `<US>` = Unit Separator (ASCII 31, `\x1f`)
- `stale` = `0` (fresh data) or `1` (cached/stale data)

### Visual Indication

When `stale=1`, the renderer applies `@powerkit_stale_color_variant` (default: `-darker`) to background colors:

| Data State | Background Colors |
|------------|-------------------|
| Fresh (stale=0) | Normal theme colors |
| Stale (stale=1) | `-darkest` variant applied |

This provides visual feedback that cached data is being displayed while fresh data is being fetched in the background.

## Context-Dependent Plugins

Some conditional plugins depend on **external context** (like the current directory) rather than just cached data. For these plugins, cached data may be valid but the plugin should be hidden because the context has changed.

### The Problem

When switching between panes with different contexts (e.g., from a git repository to a non-git directory), the plugin's cached data is still valid, but the plugin should disappear. Without special handling, the plugin would show stale data from the previous context.

### The Solution: `plugin_should_be_active()`

Implement this optional function to perform a **quick context check** before cached data is returned:

```bash
# Quick context check - called BEFORE returning cached data
plugin_should_be_active() {
    local path
    path=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
    [[ -n "$path" ]] && git -C "$path" rev-parse --is-inside-work-tree &>/dev/null
}
```

### When to Implement

| Implement | Don't Implement |
|-----------|-----------------|
| Plugin visibility depends on PWD | Plugin state depends on system-wide data |
| Plugin should disappear on context switch | Plugin is `always` presence |
| Examples: git, terraform | Examples: cpu, memory, battery |

### Requirements

- **MUST be fast** - This runs on every render when cache is valid
- **MUST NOT call `plugin_data_set()`** - Read-only context check
- **SHOULD check only minimal context** - Keep it lightweight
- **Returns 0** if plugin should be active, **1** if inactive

### Plugins Using This Pattern

- **git** - Checks if current directory is a git repository
- **terraform** - Checks if current directory has `.tf` files

## Example Implementation

```bash
#!/usr/bin/env bash
# Plugin: example

. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

plugin_check_dependencies() {
    require_cmd "some_command" || return 1
    return 0
}

plugin_declare_options() {
    declare_option "warning_threshold" "number" "70" "Warning threshold"
    declare_option "critical_threshold" "number" "90" "Critical threshold"
    declare_option "icon" "icon" $'\uf0e7' "Default icon"
}

plugin_collect() {
    local value
    value=$(some_command 2>/dev/null)
    plugin_data_set "value" "$value"
}

plugin_get_content_type() { printf 'dynamic'; }
plugin_get_presence() { printf 'conditional'; }

plugin_get_state() {
    local value
    value=$(plugin_data_get "value")
    [[ -n "$value" ]] && printf 'active' || printf 'inactive'
}

plugin_get_health() {
    local value warn crit
    value=$(plugin_data_get "value")
    warn=$(get_option "warning_threshold")
    crit=$(get_option "critical_threshold")

    if (( value >= crit )); then
        printf 'error'
    elif (( value >= warn )); then
        printf 'warning'
    else
        printf 'ok'
    fi
}

plugin_render() {
    local value
    value=$(plugin_data_get "value")
    printf '%s%%' "${value:-0}"
}

plugin_get_icon() {
    printf '%s' "$(get_option 'icon')"
}
```

## Related

- [Architecture](Architecture) - System overview
- [Developing Plugins](DevelopingPlugins) - Step-by-step guide
- [Theme Contract](ContractTheme) - Color definitions
