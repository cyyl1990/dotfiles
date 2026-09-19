# Developing Plugins

Step-by-step guide to creating PowerKit plugins.

## Plugin Structure

Create a file in `src/plugins/<name>.sh`:

```bash
#!/usr/bin/env bash
# Plugin: <name>
# Description: <brief description>

POWERKIT_ROOT="${POWERKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

# Contract implementation here...
```

## Step 1: Dependencies (Optional)

By default, plugins have no dependency requirements. Only implement `plugin_check_dependencies()` if your plugin requires specific commands:

```bash
plugin_check_dependencies() {
    # Required dependency
    require_cmd "curl" || return 1

    # Optional dependency (doesn't fail)
    require_cmd "jq" 1

    # One of these required
    require_any_cmd "nvidia-smi" "rocm-smi" || return 1

    return 0
}
```

### macOS Native Binaries

For plugins requiring native macOS binaries (hardware access, system APIs):

```bash
plugin_check_dependencies() {
    # Require native binary (downloaded on-demand from GitHub releases)
    require_macos_binary "powerkit-gpu" "gpu" || return 1

    return 0
}
```

When the binary is missing:
1. It's tracked for batch prompting
2. A popup shows all missing binaries after plugin initialization
3. User decides whether to download
4. Decision is cached for 24h

See [macOS Binaries](MacOSBinaries) for details on creating native binaries.

## Step 2: Options

Declare configurable options:

```bash
plugin_declare_options() {
    # Option types: string, number, bool, color, icon, key, path, enum
    declare_option "icon" "icon" $'\uf0e7' "Plugin icon"
    declare_option "warning_threshold" "number" "70" "Warning threshold"
    declare_option "critical_threshold" "number" "90" "Critical threshold"
    declare_option "cache_ttl" "number" "60" "Cache duration in seconds"
    declare_option "format" "string" "{value}%" "Display format"
}
```

## Step 3: Data Collection

Collect data and store it:

```bash
plugin_collect() {
    local value

    # External command
    value=$(some_command 2>/dev/null)

    # API call
    # value=$(curl -s "api.example.com/data" | jq -r '.value')

    # Store data
    plugin_data_set "value" "$value"
    plugin_data_set "timestamp" "$(date +%s)"
}
```

### Handling API Failures (Stale-While-Revalidate)

For plugins that depend on external APIs or commands that may fail, **return `1` from `plugin_collect()`** to trigger the stale-while-revalidate behavior:

```bash
plugin_collect() {
    local result
    result=$(safe_curl "$api_url" 5) || return 1  # Return 1 on failure

    # If we get here, API call succeeded
    plugin_data_set "value" "$result"
}
```

When `plugin_collect()` returns `1`:
1. The lifecycle preserves the previous cached data
2. The output is marked as `stale=1`
3. The renderer applies darker colors as visual feedback
4. Users see slightly dimmed plugin indicating cached data is displayed

This is ideal for:
- Weather APIs (may timeout or rate-limit)
- GitHub/GitLab APIs (may be unreachable)
- Any external service that might fail intermittently

## Step 4: Content Type and Presence (Optional)

These functions have defaults. Override only if your plugin differs from the default behavior:

```bash
# Default: 'dynamic' - Override for plugins with static data (hostname)
plugin_get_content_type() {
    printf 'static'  # Only implement if NOT dynamic
}

# Default: 'conditional' - Override for plugins that should always show
plugin_get_presence() {
    printf 'always'  # Only implement if NOT conditional
}
```

**Note:** Most plugins use the defaults (`dynamic` + `conditional`), so you can skip implementing these functions entirely.

## Step 5: State and Health

```bash
plugin_get_state() {
    local value
    value=$(plugin_data_get "value")

    if [[ -z "$value" ]]; then
        printf 'inactive'
    elif [[ "$value" == "error" ]]; then
        printf 'failed'
    else
        printf 'active'
    fi
}

# Health values: ok, good, info, warning, error
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
```

### Using the Threshold Helper

For standard threshold-based health, use the helper function:

```bash
plugin_get_health() {
    local value=$(plugin_data_get "value")
    local warn=$(get_option "warning_threshold")
    local crit=$(get_option "critical_threshold")

    # Returns: ok, warning, or error based on thresholds
    evaluate_threshold_health "$value" "$warn" "$crit"
}

# For inverted thresholds (lower is worse, like battery)
plugin_get_health() {
    local value=$(plugin_data_get "value")
    evaluate_threshold_health "$value" "30" "15" 1  # invert=1
}
```

## Step 6: Context (Optional)

Provide additional context:

```bash
plugin_get_context() {
    local status
    status=$(plugin_data_get "status")

    # Return context flags
    [[ "$status" == "charging" ]] && printf 'charging'
}
```

## Step 7: Render

Return plain text only:

```bash
plugin_render() {
    local value format
    value=$(plugin_data_get "value")
    format=$(get_option "format")

    # Simple substitution
    printf '%s' "${format//\{value\}/$value}"
}
```

## Step 8: Icon

Return icon based on state (not health):

```bash
plugin_get_icon() {
    local value context
    value=$(plugin_data_get "value")
    context=$(plugin_get_context)

    # Context-based icon
    if [[ "$context" == "charging" ]]; then
        printf '%s' "$(get_option 'icon_charging')"
        return
    fi

    # Value-based icon
    if (( value < 20 )); then
        printf '%s' "$(get_option 'icon_low')"
    else
        printf '%s' "$(get_option 'icon')"
    fi
}
```

## Step 9: Keybindings (Optional)

```bash
plugin_setup_keybindings() {
    local key
    key=$(get_option "keybinding_action")

    [[ -z "$key" ]] && return 0

    tmux bind-key "$key" run-shell "${POWERKIT_ROOT}/src/helpers/my_helper.sh"
}
```

## Step 10: Context Check (Optional)

For **conditional plugins that depend on external context** (like the current directory), implement `plugin_should_be_active()` to ensure the plugin disappears immediately when switching contexts:

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
| Plugin depends on current directory | Plugin uses system-wide data |
| Plugin should disappear on pane switch | Plugin uses `always` presence |
| Examples: git, terraform | Examples: cpu, memory, battery |

### Requirements

- **MUST be fast** - Runs on every render when cache is valid
- **MUST NOT modify state** - Read-only context check
- **Returns 0** if should be active, **1** if should be inactive

Without this function, conditional plugins may show stale data when switching between panes with different contexts (e.g., showing git info when in a non-git directory).

## Complete Example

### Minimal Plugin (using defaults)

```bash
#!/usr/bin/env bash
# Plugin: minimal
# Description: Minimal plugin using contract defaults

POWERKIT_ROOT="${POWERKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

# No plugin_check_dependencies() needed - default returns 0
# No plugin_get_content_type() needed - default is 'dynamic'
# No plugin_get_presence() needed - default is 'conditional'

plugin_declare_options() {
    declare_option "icon" "icon" $'\uf0e7' "Plugin icon"
}

plugin_collect() {
    plugin_data_set "value" "$(some_cmd 2>/dev/null)"
}

plugin_get_state() {
    [[ -n "$(plugin_data_get 'value')" ]] && printf 'active' || printf 'inactive'
}

plugin_get_health() { printf 'ok'; }

plugin_render() {
    printf '%s' "$(plugin_data_get 'value')"
}

plugin_get_icon() {
    printf '%s' "$(get_option 'icon')"
}
```

### Full Plugin (with all features)

```bash
#!/usr/bin/env bash
# Plugin: example
# Description: Plugin demonstrating all contract features

POWERKIT_ROOT="${POWERKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

plugin_check_dependencies() {
    require_cmd "example_cmd" || return 1
    return 0
}

plugin_declare_options() {
    declare_option "icon" "icon" $'\uf0e7' "Default icon"
    declare_option "warning_threshold" "number" "70" "Warning level"
    declare_option "critical_threshold" "number" "90" "Critical level"
    declare_option "cache_ttl" "number" "30" "Cache TTL"
}

plugin_collect() {
    local value
    value=$(example_cmd --get-value 2>/dev/null)
    plugin_data_set "value" "${value:-0}"
}

# Override defaults only if needed:
# plugin_get_content_type() { printf 'static'; }  # for static data
# plugin_get_presence() { printf 'always'; }      # to always show

plugin_get_state() {
    local value=$(plugin_data_get "value")
    [[ -n "$value" ]] && printf 'active' || printf 'inactive'
}

plugin_get_health() {
    local value=$(plugin_data_get "value")
    local warn=$(get_option "warning_threshold")
    local crit=$(get_option "critical_threshold")

    (( value >= crit )) && { printf 'error'; return; }
    (( value >= warn )) && { printf 'warning'; return; }
    printf 'ok'
}

plugin_render() {
    printf '%s%%' "$(plugin_data_get 'value')"
}

plugin_get_icon() {
    printf '%s' "$(get_option 'icon')"
}
```

## Testing

```bash
# Validate syntax
bash -n src/plugins/example.sh

# Test plugin execution
POWERKIT_ROOT="$(pwd)" ./bin/powerkit-plugin example

# Validate contract compliance
./tests/test_contracts.sh
```

## Common Mistakes

1. **Adding colors**: Never use `#[fg=...]` in render
2. **Health-based icons**: Icons should reflect data, not health
3. **Slow collection**: Use caching for external commands
4. **Missing return**: Always return proper state/health

## Related

- [Plugin Contract](ContractPlugin) - Contract specification
- [Architecture](Architecture) - System overview
- [Configuration](Configuration) - Option types
- [macOS Binaries](MacOSBinaries) - Native binary system
