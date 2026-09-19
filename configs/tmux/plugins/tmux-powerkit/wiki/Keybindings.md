# Keybindings

PowerKit keybinding system and conflict resolution.

## Global Keybindings

PowerKit registers these default keybindings:

| Key | Action | Option |
|-----|--------|--------|
| `prefix + C-e` | Options viewer | `@powerkit_options_key` |
| `prefix + C-y` | Keybindings viewer | `@powerkit_keybindings_key` |
| `prefix + C-r` | Theme selector | `@powerkit_theme_selector_key` |
| `prefix + C-d` | Clear cache | `@powerkit_cache_clear_key` |

## Plugin Keybindings

Plugins may register additional keybindings:

| Plugin | Key | Action |
|--------|-----|--------|
| audiodevices | `M-i` | Input device selector |
| audiodevices | `M-o` | Output device selector |
| bitwarden | `C-b` | Password selector |
| bitwarden | `C-t` | TOTP selector |
| pomodoro | `C-p` | Timer control |
| terraform | `C-w` | Workspace selector |

> **Note:** Keybindings using `M-` (Meta/Alt) require terminal configuration on macOS. See [macOS Alt Key Setup](#macos-alt-key-setup).

## Configuring Keys

Change default keybindings in `tmux.conf`:

```bash
# Global keybindings
set -g @powerkit_options_key "C-o"
set -g @powerkit_keybindings_key "C-k"
set -g @powerkit_theme_selector_key "C-t"

# Plugin keybindings
set -g @powerkit_plugin_bitwarden_keybinding_password "C-p"
set -g @powerkit_plugin_pomodoro_keybinding_toggle "C-m"
```

## Conflict Detection

PowerKit detects conflicts with existing tmux keybindings at startup.

### Conflict Actions

Configure how conflicts are handled:

```bash
# warn: Show notification, still bind (default)
set -g @powerkit_keybinding_conflict_action "warn"

# skip: Don't bind if conflict exists
set -g @powerkit_keybinding_conflict_action "skip"

# force: Override existing binding
set -g @powerkit_keybinding_conflict_action "force"
```

### Conflict Notification

When `warn` is set, a toast notification shows conflicting keys at startup.

## Viewing Keybindings

Press `prefix + C-y` to open the keybindings viewer, which shows:
- All PowerKit keybindings
- Conflicting bindings
- Current assignments

## Key Notation

| Notation | Meaning |
|----------|---------|
| `C-x` | Ctrl + x |
| `M-x` | Alt/Meta + x |
| `S-x` | Shift + x |
| `F1` | Function key 1 |
| `Up` | Arrow up |

## macOS Alt Key Setup

On macOS, the Option key doesn't work as Meta/Alt by default in most terminal emulators. You need to configure your terminal to use Option as Alt/Meta for `M-` keybindings to work.

### Terminal Configuration

#### Ghostty

Add to your Ghostty config (`~/.config/ghostty/config`):

```
macos-option-as-alt = true
```

#### iTerm2

1. Go to **Preferences → Profiles → Keys**
2. Set **Left Option Key** to **Esc+**
3. Set **Right Option Key** to **Esc+** (optional)

#### Alacritty

Add to your Alacritty config (`~/.config/alacritty/alacritty.toml`):

```toml
[window]
option_as_alt = "Both"  # or "OnlyLeft" / "OnlyRight"
```

#### Kitty

Add to your Kitty config (`~/.config/kitty/kitty.conf`):

```
macos_option_as_alt yes
```

#### WezTerm

Add to your WezTerm config (`~/.wezterm.lua`):

```lua
return {
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
}
```

#### Terminal.app (macOS built-in)

1. Go to **Terminal → Settings → Profiles → Keyboard**
2. Check **Use Option as Meta key**

### Alternative: Use Different Keys

If you prefer not to change terminal settings, configure PowerKit to use `C-` (Ctrl) keybindings instead:

```bash
# Use Ctrl instead of Meta for audiodevices
set -g @powerkit_plugin_audiodevices_keybinding_input "C-M-i"
set -g @powerkit_plugin_audiodevices_keybinding_output "C-M-o"
```

## Disabling Keybindings

Set key to empty to disable:

```bash
# Disable theme selector keybinding
set -g @powerkit_theme_selector_key ""

# Disable plugin keybinding
set -g @powerkit_plugin_bitwarden_keybinding_password ""
```

## Custom Keybindings

Add your own keybindings to trigger helpers:

```bash
# In tmux.conf
bind-key C-x run-shell "~/.tmux/plugins/tmux-powerkit/src/helpers/my_helper.sh"
```

## Troubleshooting

### Keybinding Not Working

1. Check for conflicts: `prefix + C-y`
2. Verify key notation is correct
3. Ensure plugin is enabled
4. Check if action is set to `skip`

### Reset to Defaults

```bash
# Remove all PowerKit keybinding options
tmux show-options -g | grep powerkit.*key | cut -d' ' -f1 | xargs -I{} tmux set-option -gu {}
```

## Related

- [Configuration](Configuration) - All options
- [Helpers](Helpers) - Available helpers
- [Helper Contract](ContractHelper) - Helper system
