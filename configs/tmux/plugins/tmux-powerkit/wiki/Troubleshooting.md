# Troubleshooting

Common issues and solutions for PowerKit.

## Table of Contents

- [Bash Version Issues](#bash-version-issues)
- [Installation Issues](#installation-issues)
- [Display Issues](#display-issues)
- [Performance Issues](#performance-issues)
- [Keybinding Issues](#keybinding-issues)
- [Plugin Issues](#plugin-issues)
- [Theme Issues](#theme-issues)
- [Cache Issues](#cache-issues)
- [Debugging](#debugging)

---

## Bash Version Issues

PowerKit requires **Bash 5.0+** (5.1+ recommended for optimal performance).

### Wrong Bash Version

**Symptoms:**
- Errors about `$EPOCHSECONDS` not being recognized
- Errors about `${var,,}` bad substitution
- Status bar not loading or showing errors

**Solutions:**

1. **Check your Bash version:**
   ```bash
   bash --version
   # Should be 5.0 or higher
   ```

2. **macOS: Install Bash 5+ via Homebrew:**
   ```bash
   brew install bash

   # Verify Homebrew Bash
   /opt/homebrew/bin/bash --version  # Apple Silicon
   /usr/local/bin/bash --version     # Intel Mac
   ```

3. **Linux: Update Bash:**
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install bash

   # Fedora
   sudo dnf install bash

   # Arch
   sudo pacman -S bash
   ```

4. **Verify tmux uses correct Bash:**
   PowerKit automatically detects Homebrew Bash on macOS. If issues persist:
   ```bash
   # Check which bash tmux is using
   tmux display -p '#{default-shell}'

   # Or check in a tmux pane
   echo $BASH_VERSION
   ```

### Bash 5.1 Features Not Working

**Symptoms:**
- No performance improvement with Bash 5.1+
- `assoc_expand_once` warnings

**Solutions:**

1. **Verify Bash 5.1+:**
   ```bash
   bash -c 'echo ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}'
   # Should show 5.1 or higher
   ```

2. **Check if assoc_expand_once is available:**
   ```bash
   bash -c 'shopt -s assoc_expand_once && echo "OK"'
   ```

---

## Installation Issues

### Plugin Not Loading

**Symptoms:**
- Status bar is empty or shows default tmux format
- No PowerKit elements visible

**Solutions:**

1. **Verify TPM installation:**
   ```bash
   ls ~/.tmux/plugins/tpm
   ```

2. **Check if PowerKit is installed:**
   ```bash
   ls ~/.tmux/plugins/tmux-powerkit
   ```

3. **Verify tmux.conf configuration:**
   ```bash
   grep -E "powerkit|tpm" ~/.tmux.conf
   ```

4. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

5. **Install plugins with TPM:**
   - Press `prefix + I` (capital I) to install plugins

### Missing Icons/Characters

**Symptoms:**
- Icons appear as boxes, question marks, or weird characters
- Separators don't display correctly

**Solutions:**

1. **Install a Nerd Font:**
   ```bash
   # macOS
   brew tap homebrew/cask-fonts
   brew install font-jetbrains-mono-nerd-font

   # Linux
   # Download from https://www.nerdfonts.com/font-downloads
   ```

2. **Configure your terminal to use the Nerd Font:**
   - iTerm2: Preferences → Profiles → Text → Font
   - Terminal.app: Preferences → Profiles → Font
   - Alacritty: Add to `alacritty.yml`:
     ```yaml
     font:
       normal:
         family: "JetBrainsMono Nerd Font"
     ```

3. **Verify font installation:**
   ```bash
   echo -e "\uf240 \ue0b0 \ue0b2"
   # Should show: battery icon, right arrow, left arrow
   ```

### POWERKIT_ROOT Not Set

**Symptoms:**
- Error messages about POWERKIT_ROOT
- Plugins fail to load

**Solutions:**

1. **Set POWERKIT_ROOT in shell config:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit"
   ```

2. **Or set in tmux.conf:**
   ```bash
   set-environment -g POWERKIT_ROOT "$HOME/.tmux/plugins/tmux-powerkit"
   ```

---

## Display Issues

### Status Bar Empty

**Symptoms:**
- Status bar shows nothing or default format
- PowerKit not rendering

**Solutions:**

1. **Check if plugins are configured:**
   ```bash
   tmux show-option -g @powerkit_plugins
   ```

2. **Add plugins to configuration:**
   ```bash
   set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname,git"
   ```

3. **Test render script manually:**
   ```bash
   POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit" \
     ~/.tmux/plugins/tmux-powerkit/bin/powerkit-render
   ```

### Colors Not Showing

**Symptoms:**
- Status bar is black and white
- No color differentiation

**Solutions:**

1. **Enable 256 colors in tmux:**
   ```bash
   # In tmux.conf
   set -g default-terminal "screen-256color"
   set -ga terminal-overrides ",*256col*:Tc"
   ```

2. **Verify terminal supports true color:**
   ```bash
   echo -e "\033[38;2;255;100;0mTrueColor Test\033[0m"
   # Should show orange text
   ```

3. **Check TERM environment variable:**
   ```bash
   echo $TERM
   # Should be xterm-256color, screen-256color, or similar
   ```

### Wrong Separators

**Symptoms:**
- Separators showing wrong characters
- Powerline glyphs not aligned

**Solutions:**

1. **Use a compatible Nerd Font**
2. **Try different separator styles:**
   ```bash
   set -g @powerkit_separator_style "rounded"
   # Options: normal, rounded, flame, pixel, honeycomb, none
   ```

3. **Check for font rendering issues:**
   - Some fonts have different glyph widths
   - Try a different Nerd Font

---

## Performance Issues

### Slow Status Bar Updates

**Symptoms:**
- Status bar takes a long time to update
- tmux feels sluggish

**Solutions:**

1. **Reduce number of plugins:**
   ```bash
   # Use only essential plugins
   set -g @powerkit_plugins "datetime,battery"
   ```

2. **Increase cache TTL for slow plugins:**
   ```bash
   set -g @powerkit_plugin_weather_cache_ttl "3600"   # 1 hour
   set -g @powerkit_plugin_github_cache_ttl "300"     # 5 minutes
   ```

3. **Increase status-interval:**
   ```bash
   set -g @powerkit_status_interval "10"  # Update every 10 seconds
   ```

4. **Disable network-dependent plugins:**
   - weather, github, gitlab, stocks, crypto

5. **Use `show_only_on_threshold` option:**
   ```bash
   set -g @powerkit_plugin_cpu_show_only_on_threshold "true"
   ```

### High CPU Usage

**Symptoms:**
- tmux using excessive CPU
- System feels slow

**Solutions:**

1. **Identify slow plugins:**
   ```bash
   time POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit" \
     ~/.tmux/plugins/tmux-powerkit/bin/powerkit-plugin cpu
   ```

2. **Check for network timeouts:**
   - Network plugins may hang waiting for responses
   - Increase timeouts or reduce cache refresh

3. **Clear cache:**
   - Press `prefix + Alt+x` (default keybinding)
   - Or manually: `rm -rf ~/.cache/tmux-powerkit/`

---

## Keybinding Issues

### Meta/Alt Keys Not Working on macOS

**Symptoms:**
- Keybindings using `M-` (Meta/Alt) don't work
- Pressing Option + key types special characters instead

**Cause:**

On macOS, the Option key sends special Unicode characters by default instead of acting as Meta/Alt. Terminal emulators need explicit configuration to use Option as Meta.

**Solutions:**

Configure your terminal emulator:

| Terminal | Configuration |
|----------|--------------|
| **Ghostty** | `macos-option-as-alt = true` in config |
| **iTerm2** | Preferences → Profiles → Keys → Left/Right Option Key → Esc+ |
| **Alacritty** | `option_as_alt = "Both"` in `[window]` section |
| **Kitty** | `macos_option_as_alt yes` in config |
| **WezTerm** | `send_composed_key_when_left_alt_is_pressed = false` in Lua config |
| **Terminal.app** | Settings → Profiles → Keyboard → Use Option as Meta key |

See [Keybindings - macOS Alt Key Setup](Keybindings#macos-alt-key-setup) for detailed configuration examples.

**Alternative:** Use Ctrl-based keybindings instead:

```bash
set -g @powerkit_plugin_audiodevices_keybinding_input "C-S-i"
```

### Keybinding Conflicts

**Symptoms:**
- PowerKit keybinding doesn't work
- Conflict notification at startup

**Solutions:**

1. **View conflicts:**
   - Press `prefix + C-y` to open keybindings viewer
   - Check the conflicts section

2. **Change conflicting keybinding:**
   ```bash
   set -g @powerkit_plugin_<plugin>_keybinding_<action> "new-key"
   ```

3. **Change conflict action:**
   ```bash
   # Skip PowerKit binding if conflict exists
   set -g @powerkit_keybinding_conflict_action "skip"
   ```

---

## Plugin Issues

### Plugin Shows "N/A"

**Symptoms:**
- Plugin displays "N/A" instead of data
- Plugin is visible but no useful information

**Solutions:**

1. **Check plugin dependencies:**
   ```bash
   # Test plugin directly
   POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit" \
     ~/.tmux/plugins/tmux-powerkit/bin/powerkit-plugin <plugin_name>
   ```

2. **Install missing dependencies:**
   - See individual plugin documentation for requirements

3. **Check platform support:**
   - Some plugins are macOS or Linux only

### Plugin Not Showing

**Symptoms:**
- Plugin configured but not visible
- No errors, just missing

**Solutions:**

1. **Check if plugin is in the list:**
   ```bash
   tmux show-option -g @powerkit_plugins
   ```

2. **Verify plugin state:**
   - Conditional plugins hide when `state=inactive`
   - Example: battery plugin hides on desktops without battery

3. **Check `show_when` or `show_only_on_threshold` options:**
   ```bash
   # Some plugins hide by default
   set -g @powerkit_plugin_wifi_show_when "always"
   ```

### Plugin Shows Wrong Data

**Symptoms:**
- Incorrect values displayed
- Data doesn't match system state

**Solutions:**

1. **Clear plugin cache:**
   - Press `prefix + Alt+x`
   - Or: `rm ~/.cache/tmux-powerkit/data/<plugin_name>_*`

2. **Test data collection:**
   ```bash
   # Test the underlying command
   # Example for CPU:
   top -l 1 | grep "CPU usage"  # macOS
   cat /proc/stat               # Linux
   ```

3. **Check for permission issues:**
   - Some plugins need special permissions
   - Example: temperature on Linux may need root

---

## Theme Issues

### Theme Not Applied

**Symptoms:**
- Default colors showing instead of theme
- Colors don't match expected theme

**Solutions:**

1. **Verify theme configuration:**
   ```bash
   tmux show-option -g @powerkit_theme
   tmux show-option -g @powerkit_theme_variant
   ```

2. **Check theme exists:**
   ```bash
   ls ~/.tmux/plugins/tmux-powerkit/src/themes/
   ```

3. **Clear theme cache:**
   ```bash
   rm ~/.cache/tmux-powerkit/data/theme_colors__*
   ```

4. **Reload tmux:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Custom Theme Not Loading

**Symptoms:**
- Custom theme file ignored
- Default theme used instead

**Solutions:**

1. **Check custom theme path:**
   ```bash
   set -g @powerkit_custom_theme_path "/path/to/my-theme.sh"
   ```

2. **Verify theme file is valid:**
   ```bash
   bash -n /path/to/my-theme.sh
   ```

3. **Check required colors are defined:**
   - See [Theme Contract](ContractTheme) for required colors

---

## Cache Issues

PowerKit uses a multi-layer caching system. See [Caching System](Caching) for detailed documentation.

### Stale Data

**Symptoms:**
- Old data showing despite changes
- Plugin not updating

**Solutions:**

1. **Clear all cache:**
   - Press `prefix + Alt+x`
   - Or: `rm -rf ~/.cache/tmux-powerkit/`

2. **Reduce cache TTL:**
   ```bash
   set -g @powerkit_plugin_<name>_cache_ttl "30"
   ```

3. **Force refresh:**
   ```bash
   tmux refresh-client -S
   ```

4. **Check for event-based invalidation:**
   - Some plugins (like `packages`) have automatic invalidation
   - See individual plugin documentation

### Cache Directory Full

**Symptoms:**
- Disk space warnings
- Cache growing indefinitely

**Solutions:**

1. **Clear cache directory:**
   ```bash
   rm -rf ~/.cache/tmux-powerkit/
   ```

2. **Set up periodic cleanup:**
   ```bash
   # Add to crontab
   0 0 * * * rm -rf ~/.cache/tmux-powerkit/data/*
   ```

### Cache Not Working

**Symptoms:**
- Slow status bar updates
- Same data collected repeatedly

**Solutions:**

1. **Check cache directory permissions:**
   ```bash
   ls -la ~/.cache/tmux-powerkit/
   ```

2. **Verify cache is being written:**
   ```bash
   watch -n1 'ls -la ~/.cache/tmux-powerkit/data/ | tail -10'
   ```

3. **Ensure POWERKIT_ROOT is set correctly:**
   ```bash
   tmux show-environment POWERKIT_ROOT
   ```

---

## Debugging

### Enable Debug Logging

```bash
# Enable debug mode
export POWERKIT_DEBUG=true

# View logs
tail -f ~/.cache/tmux-powerkit/logs/powerkit.log
```

### Test Individual Plugin

```bash
POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit" \
  ~/.tmux/plugins/tmux-powerkit/bin/powerkit-plugin battery
```

### Test Full Render

```bash
POWERKIT_ROOT="$HOME/.tmux/plugins/tmux-powerkit" \
  ~/.tmux/plugins/tmux-powerkit/bin/powerkit-render
```

### View Current Options

- Press `prefix + C-e` (default keybinding)
- Shows all PowerKit options and values

### View Keybindings

- Press `prefix + C-y` (default keybinding)
- Shows all PowerKit keybindings

---

## Getting Help

1. **Check plugin documentation:**
   - Each plugin has its own wiki page with troubleshooting

2. **Search existing issues:**
   - [GitHub Issues](https://github.com/fabioluciano/tmux-powerkit/issues)

3. **Create a new issue:**
   - Include tmux version: `tmux -V`
   - Include shell: `echo $SHELL`
   - Include OS: `uname -a`
   - Include relevant config from `~/.tmux.conf`

---

## Related

- [Installation](Installation) - Setup guide
- [Configuration](Configuration) - All options
- [Architecture](Architecture) - How PowerKit works
- [Caching System](Caching) - Cache architecture and optimization
