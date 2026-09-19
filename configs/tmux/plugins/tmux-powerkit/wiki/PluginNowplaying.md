# Plugin: nowplaying

Display currently playing music track from various media players with customizable formatting.

## Screenshot

```
󰎈 Drake - God's Plan         # Playing
󰏤 Beethoven - Symphony No. 9  # Paused
󰎈 Taylor Swift - Anti...      # Truncated title
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `powerkit-nowplaying` binary (macOS), `playerctl` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## macOS Native Binary

This plugin uses a native macOS binary for efficient now playing detection using ScriptingBridge.

| Property | Value |
|----------|-------|
| **Binary** | `bin/powerkit-nowplaying` |
| **Source** | `src/native/macos/powerkit-nowplaying.m` |
| **Frameworks** | Foundation, ScriptingBridge |

### Automatic Download

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

### Manual Compilation

```bash
cd src/native/macos && make powerkit-nowplaying
cp powerkit-nowplaying ../../bin/
```

### Binary Features

The native binary provides:
- Direct access to Spotify and Music apps via ScriptingBridge
- Faster and more reliable than osascript
- Returns: state, artist, title, album, and app name
- Automatic player icon detection

### Fallback

If the binary is not available and you decline the download, the plugin returns `inactive` state on macOS (no fallback method available).

## Installation

```bash
# macOS - binary is downloaded automatically on first use
# Or compile manually:
cd src/native/macos && make powerkit-nowplaying
cp powerkit-nowplaying ../../bin/

# Linux (Debian/Ubuntu)
sudo apt install playerctl

# Linux (Arch)
sudo pacman -S playerctl

# Linux (Fedora)
sudo dnf install playerctl
```

## Quick Start

```bash
set -g @powerkit_plugins "nowplaying"
```

## Configuration Example

```bash
set -g @powerkit_plugins "nowplaying"

# Format string (%artist%, %title%, %album%, %app%)
set -g @powerkit_plugin_nowplaying_format "%artist% - %title%"

# Maximum display length
set -g @powerkit_plugin_nowplaying_max_length "40"
set -g @powerkit_plugin_nowplaying_truncate_suffix "..."

# Text when not playing (empty = hide plugin)
set -g @powerkit_plugin_nowplaying_not_playing ""

# Ignore specific players (comma-separated)
set -g @powerkit_plugin_nowplaying_ignore_players "chromium,firefox"

# Show info health when paused (blue color)
set -g @powerkit_plugin_nowplaying_info_when_paused "false"

# Icons
set -g @powerkit_plugin_nowplaying_icon "󰎈"       # Playing icon
set -g @powerkit_plugin_nowplaying_icon_paused "󰏤"  # Paused icon

# Cache duration (seconds)
set -g @powerkit_plugin_nowplaying_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_nowplaying_format` | string | `%artist% - %title%` | Format string with placeholders |
| `@powerkit_plugin_nowplaying_max_length` | number | `40` | Maximum display length (truncates if exceeded) |
| `@powerkit_plugin_nowplaying_truncate_suffix` | string | `...` | Suffix for truncated text |
| `@powerkit_plugin_nowplaying_not_playing` | string | `` | Text when not playing (empty = hide plugin) |
| `@powerkit_plugin_nowplaying_ignore_players` | string | `` | Comma-separated player names to ignore |
| `@powerkit_plugin_nowplaying_info_when_paused` | bool | `false` | Use info health (blue) when paused |
| `@powerkit_plugin_nowplaying_icon` | icon | `󰎈` | Icon when music is playing |
| `@powerkit_plugin_nowplaying_icon_paused` | icon | `󰏤` | Icon when music is paused |
| `@powerkit_plugin_nowplaying_cache_ttl` | number | `5` | Cache duration in seconds |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Music is playing or paused | Visible |
| `inactive` | No music playing | Hidden (unless `not_playing` is set) |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Playing or paused (default) | Green |
| `info` | Paused with `info_when_paused=true` | Blue |

## Context Values

| Context | Description |
|---------|-------------|
| `playing` | Music is currently playing |
| `paused` | Music is paused |
| `stopped` | No active playback |

## Format String

The `format` option supports these placeholders:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `%artist%` | Artist name | `Drake` |
| `%title%` | Track title | `God's Plan` |
| `%album%` | Album name | `Scorpion` |
| `%app%` | Player app name | `spotify` |

### Format Examples

| Format | Output |
|--------|--------|
| `%artist% - %title%` | `Drake - God's Plan` |
| `%title%` | `God's Plan` |
| `%title% (%artist%)` | `God's Plan (Drake)` |
| `%artist% / %title% / %album%` | `Drake / God's Plan / Scorpion` |
| `%title% [%app%]` | `God's Plan [spotify]` |

## Player Icons

The plugin automatically detects the player app and displays app-specific icons:

| Player | Icon |
|--------|------|
| Spotify |  |
| Apple Music | 󰎈 |
| YouTube |  |
| VLC |  |
| Firefox |  |
| Chrome |  |
| Safari |  |
| Other | Default icon |

## Supported Applications

### macOS (with powerkit-nowplaying binary)

- Apple Music
- Spotify

### Linux (with playerctl)

- Spotify
- VLC
- Rhythmbox
- Clementine
- Audacious
- MPD (with mpDris2)
- Chrome/Chromium (with MPRIS extension)
- Firefox (with MPRIS extension)
- Any MPRIS2-compatible player

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "nowplaying"
```

### Show Title Only

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_format "%title%"
```

### Include Album

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_format "%artist% - %title% [%album%]"
```

### Short Display with Custom Truncation

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_max_length "25"
set -g @powerkit_plugin_nowplaying_truncate_suffix "…"
```

### Show "Not Playing" Text

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_not_playing "♪ No music"
```

### Ignore Browsers

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_ignore_players "chromium,firefox"
```

### Blue Color When Paused

```bash
set -g @powerkit_plugins "nowplaying"
set -g @powerkit_plugin_nowplaying_info_when_paused "true"
```

## Truncation Behavior

When track info exceeds `max_length`:

1. Full text is truncated at word boundaries
2. Truncation suffix is appended
3. Leading/trailing separators are cleaned up

Example with `max_length="20"` and `format="%artist% - %title%"`:

| Original | Truncated |
|----------|-----------|
| `The Beatles - Hey Jude` | `The Beatles - He...` |
| `Drake - God's Plan` | `Drake - God's...` |

## Troubleshooting

### Plugin Not Showing (macOS)

1. Check if binary exists:
   ```bash
   ls -la ~/.tmux/plugins/tmux-powerkit/bin/powerkit-nowplaying
   ```

2. Compile if missing:
   ```bash
   cd ~/.tmux/plugins/tmux-powerkit/src/native/macos && make powerkit-nowplaying
   cp powerkit-nowplaying ../../bin/
   ```

3. Test the binary:
   ```bash
   ~/.tmux/plugins/tmux-powerkit/bin/powerkit-nowplaying
   ```

### Plugin Not Showing (Linux)

1. Check if playerctl detects players:
   ```bash
   playerctl -l
   ```

2. Verify music is playing:
   ```bash
   playerctl status
   playerctl metadata
   ```

3. Ensure player supports MPRIS2:
   ```bash
   dbus-send --print-reply --dest=org.freedesktop.DBus \
     /org/freedesktop/DBus org.freedesktop.DBus.ListNames
   ```

### Wrong App Showing (Linux)

Use the `ignore_players` option:

```bash
set -g @powerkit_plugin_nowplaying_ignore_players "chromium,firefox"
```

### Track Info Not Updating

- Cache TTL is 5 seconds by default
- Reduce cache for faster updates:
  ```bash
  set -g @powerkit_plugin_nowplaying_cache_ttl "2"
  ```

### Empty Artist or Title

- Some players don't provide all metadata
- Adjust format string:
  ```bash
  set -g @powerkit_plugin_nowplaying_format "%title%"
  ```

## Related Plugins

- [PluginVolume](PluginVolume) - System volume control
- [PluginAudiodevices](PluginAudiodevices) - Audio device selection
- [PluginMicrophone](PluginMicrophone) - Microphone status
