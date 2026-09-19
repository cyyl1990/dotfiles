# Helper Contract

The Helper Contract defines how helpers provide interactive UI elements.

## Overview

Helpers are interactive components that respond to user input. They can display menus, popups, toasts, or execute commands. Helpers use standardized UI functions for consistent behavior.

## Purpose

Provide consistent interactive experiences:
- Menus for selection
- Popups for information display
- Toasts for notifications
- Commands for actions

## Responsibilities

Helpers MUST:
- Source `helper_contract.sh` and call `helper_init`
- Implement `helper_main()` as entry point
- Use provided UI functions for display
- Handle dispatch via `helper_dispatch()`
- Return appropriate exit codes

Helpers MUST NOT:
- Implement UI rendering directly
- Modify plugin data
- Access internal plugin state
- Source `ui_backend.sh` directly (loaded by contract)

## Helper Types

| Type | Description | Display |
|------|-------------|---------|
| `popup` | Interactive popup window | tmux popup |
| `menu` | Selection menu | fzf or similar |
| `command` | Execute action | No display |
| `toast` | Brief notification | tmux message |

## Required Functions

| Function | Description |
|----------|-------------|
| `helper_main()` | Entry point, receives action as argument |

## Optional Functions

| Function | Description |
|----------|-------------|
| `helper_get_metadata()` | Set helper id, name, description, type |
| `helper_get_actions()` | List available actions with descriptions |

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

### Selection

```bash
# Filter list with search
helper_filter "prompt" "item1\nitem2\nitem3"

# Choose from options
helper_choose "prompt" "option1" "option2" "option3"

# Confirm action
helper_confirm "Are you sure?" && do_action
```

### Display

```bash
# Show popup
helper_popup "title" "content"

# Show toast notification (styles: info, warning, error, success)
toast "Message to display" "info"

# Show in pager
helper_pager "title" "long content..."
```

### Input

```bash
# Get text input
result=$(helper_input "Enter value:")

# Get password (hidden input)
result=$(helper_password "Enter password:")
```

## Standard Dispatch

```bash
helper_main() {
    local action="${1:-default}"

    case "$action" in
        select|"") _do_select ;;
        view)      _do_view ;;
        *)
            echo "Unknown action: $action" >&2
            return 1
            ;;
    esac
}

# Dispatch to handler (no helper name argument needed)
helper_dispatch "$@"
```

## Example Implementation

```bash
#!/usr/bin/env bash
# =============================================================================
# Helper: example_selector
# Description: Example selector helper
# Type: popup
# =============================================================================

# Source helper contract (handles all initialization)
. "$(dirname "${BASH_SOURCE[0]}")/../contract/helper_contract.sh"
helper_init
# Note: ui_backend.sh is loaded by helper_contract.sh

# =============================================================================
# Metadata
# =============================================================================

helper_get_metadata() {
    helper_metadata_set "id" "example_selector"
    helper_metadata_set "name" "Example Selector"
    helper_metadata_set "description" "Example selector helper"
    helper_metadata_set "type" "popup"
}

helper_get_actions() {
    echo "select - Select an item (default)"
    echo "view - View all items"
}

# =============================================================================
# Internal Functions
# =============================================================================

_get_items() {
    echo "item1"
    echo "item2"
    echo "item3"
}

_do_select() {
    local items selected
    items=$(_get_items)

    selected=$(helper_filter "Select item:" "$items")
    [[ -z "$selected" ]] && return 1

    toast "Selected: $selected" "info"
    echo "$selected"
}

_do_view() {
    local items
    items=$(_get_items)
    helper_pager "Available Items" "$items"
}

# =============================================================================
# Main Entry Point
# =============================================================================

helper_main() {
    local action="${1:-select}"

    case "$action" in
        select|"") _do_select ;;
        view)      _do_view ;;
        *)
            echo "Unknown action: $action" >&2
            return 1
            ;;
    esac
}

# Dispatch to handler
helper_dispatch "$@"
```

## Plugin-Associated Helpers

Some helpers are associated with specific plugins and documented in their plugin pages:

| Helper | Plugin |
|--------|--------|
| `audio_device_selector` | [audiodevices](PluginAudiodevices) |
| `bitwarden_password_selector` | [bitwarden](PluginBitwarden) |
| `bitwarden_totp_selector` | [bitwarden](PluginBitwarden) |
| `jira_issue_selector` | [jira](PluginJira) |
| `kubernetes_selector` | [kubernetes](PluginKubernetes) |
| `pomodoro_timer` | [pomodoro](PluginPomodoro) |
| `terraform_workspace_selector` | [terraform](PluginTerraform) |

## Global Helpers

System-wide helpers not associated with specific plugins are documented in [Helpers](Helpers).

## Related

- [Helpers](Helpers) - Global helpers
- [Developing Helpers](DevelopingHelpers) - Create helpers
- [Keybindings](Keybindings) - Trigger helpers via keybindings
