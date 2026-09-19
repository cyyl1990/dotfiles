# Developing Helpers

Guide to creating interactive helper components.

## Helper Structure

Create a file in `src/helpers/<name>.sh`:

```bash
#!/usr/bin/env bash
# =============================================================================
# Helper: <name>
# Description: <brief description>
# Type: popup
# =============================================================================

# Source helper base (handles all initialization)
# Using minimal bootstrap for faster startup
. "$(dirname "${BASH_SOURCE[0]}")/../contract/helper_contract.sh"
helper_init
# Note: ui_backend.sh is loaded by helper_contract.sh

# =============================================================================
# Metadata
# =============================================================================

helper_get_metadata() {
    helper_metadata_set "id" "<name>"
    helper_metadata_set "name" "Display Name"
    helper_metadata_set "description" "Brief description"
    helper_metadata_set "type" "popup"
}

helper_get_actions() {
    echo "select - Default action"
    echo "list - List items"
}

# =============================================================================
# Main Entry Point
# =============================================================================

helper_main() {
    local action="${1:-select}"

    case "$action" in
        select|"") _do_select ;;
        list)      _do_list ;;
        *)
            echo "Unknown action: $action" >&2
            return 1
            ;;
    esac
}

# Dispatch to handler
helper_dispatch "$@"
```

## Bootstrap Options

### `helper_init` (Recommended)

```bash
. "$(dirname "${BASH_SOURCE[0]}")/../contract/helper_contract.sh"
helper_init
```

- **Fast**: ~18ms startup time
- Loads: core modules, utils, theme (cached), ui_backend
- Use for: Most helpers (selectors, viewers, toasts with colors)

### `helper_init --full`

```bash
. "$(dirname "${BASH_SOURCE[0]}")/../contract/helper_contract.sh"
helper_init --full
```

- **Slow**: ~440ms startup time
- Loads: Everything including contracts, renderer, plugins, keybindings
- Use for: Helpers that need plugin registry or keybinding registration

> **Note**: Theme colors are available in both modes. The theme is loaded from cache (~18ms) in minimal bootstrap.

> **Note**: The helper contract automatically handles `set -e` compatibility during bootstrap. You can safely use `set -e` in your helpers.

## UI Functions

### Selection Menu

```bash
# Filter list with fzf
selected=$(helper_filter "Select item:" "$items")

# Choose from options
selected=$(helper_choose "Choose:" "Option 1" "Option 2" "Option 3")

# Multi-select
selected=$(helper_multi_select "Select items:" "$items")
```

### Confirmation

```bash
if helper_confirm "Delete file?"; then
    rm "$file"
fi
```

### Input

```bash
# Text input
name=$(helper_input "Enter name:")

# Hidden input (password)
pass=$(helper_password "Enter password:")
```

### Display

```bash
# Toast notification (styles: info, warning, error, success)
toast "Operation complete!" "info"

# Popup window
helper_popup "Title" "Content to display"

# Pager for long content
helper_pager "Log Output" "$log_content"
```

### Clipboard

```bash
# Copy to clipboard
helper_copy "$value"

# Copy and notify
helper_copy_notify "$value" "Copied!"
```

## Complete Example

```bash
#!/usr/bin/env bash
# =============================================================================
# Helper: theme_selector
# Description: Interactive theme selection
# Type: popup
# =============================================================================

. "$(dirname "${BASH_SOURCE[0]}")/../contract/helper_contract.sh"
helper_init

helper_get_metadata() {
    helper_metadata_set "id" "theme_selector"
    helper_metadata_set "name" "Theme Selector"
    helper_metadata_set "description" "Select and apply themes"
    helper_metadata_set "type" "popup"
}

helper_get_actions() {
    echo "select - Browse and apply themes (default)"
    echo "preview - List available themes"
}

_get_themes() {
    local theme_dir="$POWERKIT_ROOT/src/themes"
    for theme in "$theme_dir"/*/; do
        [[ -d "$theme" ]] || continue
        basename "$theme"
    done
}

_get_variants() {
    local theme="$1"
    local theme_dir="$POWERKIT_ROOT/src/themes/$theme"
    for variant in "$theme_dir"/*.sh; do
        [[ -f "$variant" ]] || continue
        basename "$variant" .sh
    done
}

_apply_theme() {
    local theme="$1"
    local variant="$2"

    tmux set-option -g @powerkit_theme "$theme"
    tmux set-option -g @powerkit_theme_variant "$variant"

    # Trigger reload
    tmux refresh-client -S

    toast "Theme: $theme/$variant" "info"
}

_do_select() {
    local themes theme variants variant

    # Select theme
    themes=$(_get_themes)
    theme=$(helper_filter "Select theme:" "$themes")
    [[ -z "$theme" ]] && return 1

    # Select variant
    variants=$(_get_variants "$theme")
    variant=$(helper_filter "Select variant:" "$variants")
    [[ -z "$variant" ]] && return 1

    _apply_theme "$theme" "$variant"
}

_do_preview() {
    local themes
    themes=$(_get_themes)
    helper_pager "Available Themes" "$themes"
}

helper_main() {
    local action="${1:-select}"

    case "$action" in
        select|"") _do_select ;;
        preview)   _do_preview ;;
        *)
            echo "Unknown action: $action" >&2
            return 1
            ;;
    esac
}

helper_dispatch "$@"
```

## Triggering Helpers

### Via Keybinding

```bash
# In plugin's plugin_setup_keybindings()
tmux bind-key "C-t" run-shell "${POWERKIT_ROOT}/src/helpers/theme_selector.sh"
```

### Via Command

```bash
# Direct execution
./src/helpers/theme_selector.sh select

# With action
./src/helpers/theme_selector.sh preview
```

## Helper Actions

Use actions to support multiple operations:

```bash
helper_main() {
    case "${1:-default}" in
        select) _do_select ;;
        add) _do_add ;;
        remove) _do_remove ;;
        list) _do_list ;;
        *) _do_default ;;
    esac
}
```

## Error Handling

```bash
_do_action() {
    local result

    result=$(risky_operation 2>&1) || {
        toast "Error: $result" "error"
        return 1
    }

    toast "Success!" "info"
}
```

## Testing

```bash
# Test execution
./src/helpers/my_helper.sh

# Test specific action
./src/helpers/my_helper.sh preview

# Debug mode
POWERKIT_DEBUG=true ./src/helpers/my_helper.sh
```

## Best Practices

1. **Use `helper_init`**: Prefer minimal bootstrap for faster startup
2. **Default action**: Always handle missing action
3. **Error feedback**: Use `toast` with "error" style for errors
4. **Cancellation**: Handle empty selection gracefully
5. **Clipboard**: Offer copy option when appropriate
6. **Documentation**: Document available actions in `helper_get_actions()`
7. **Avoid `[[ ]] &&` with `set -e`**: Use `if/then` instead for compatibility

## Related

- [Helper Contract](ContractHelper) - Contract specification
- [Keybindings](Keybindings) - Trigger via keys
- [Helpers](Helpers) - Available helpers
