# Plugin: volume

Display system volume level with mute indicator and multi-backend audio support.

## Screenshot

```
 75%     # Normal volume - green/ok
 15%     # Low volume - green/ok
 MUTE    # Muted - red/error
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `osascript` (macOS), `wpctl`/`pactl`/`pamixer`/`amixer` (Linux) |
| **Content Type** | dynamic |
| **Presence** | always |

## Installation

```bash
# macOS - osascript is built-in

# Linux - PipeWire (modern, recommended)
sudo apt install pipewire wireplumber

# Linux - PulseAudio
sudo apt install pulseaudio

# Linux - pamixer (PulseAudio/PipeWire wrapper)
sudo apt install pamixer

# Linux - ALSA (legacy)
sudo apt install alsa-utils
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "volume"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "volume"

# Display options
set -g @powerkit_plugin_volume_show_percentage "true"

# Icons
set -g @powerkit_plugin_volume_icon "󰕾"
set -g @powerkit_plugin_volume_icon_medium "󰖀"
set -g @powerkit_plugin_volume_icon_low "󰕿"
set -g @powerkit_plugin_volume_icon_muted "󰝟"

# Thresholds for icon selection
set -g @powerkit_plugin_volume_low_threshold "30"
set -g @powerkit_plugin_volume_medium_threshold "70"

# Cache duration (seconds)
set -g @powerkit_plugin_volume_cache_ttl "5"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_volume_show_percentage` | bool | `true` | Show percentage symbol (%) |
| `@powerkit_plugin_volume_icon` | icon | `󰕾` | Volume high icon (>70%) |
| `@powerkit_plugin_volume_icon_medium` | icon | `󰖀` | Volume medium icon (30-70%) |
| `@powerkit_plugin_volume_icon_low` | icon | `󰕿` | Volume low icon (<30%) |
| `@powerkit_plugin_volume_icon_muted` | icon | `󰝟` | Volume muted icon |
| `@powerkit_plugin_volume_low_threshold` | number | `30` | Low volume threshold percentage |
| `@powerkit_plugin_volume_medium_threshold` | number | `70` | Medium volume threshold percentage |
| `@powerkit_plugin_volume_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_volume_show_only_on_threshold` | bool | `false` | Only show when below/above thresholds |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Audio system available | Visible |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Volume above 0% and not muted | Green |
| `error` | Volume is muted | Red |

## Context Values

| Context | Description |
|---------|-------------|
| `muted` | Audio is muted |
| `low` | Volume ≤ 30% |
| `medium` | Volume 30-70% |
| `high` | Volume > 70% |

## Audio Backend Detection

The plugin automatically detects and uses the best available audio backend:

| Backend | Priority | Command | Platform |
|---------|----------|---------|----------|
| macOS | 1 | `osascript` | macOS only |
| PipeWire | 2 | `wpctl` | Linux (modern) |
| PulseAudio | 3 | `pactl` | Linux |
| pamixer | 4 | `pamixer` | Linux (wrapper) |
| ALSA | 5 | `amixer` | Linux (legacy) |

## Icon Selection

Icons change based on volume level:

| Range | Icon | Context |
|-------|------|---------|
| 0% or muted | 󰝟 | `muted` |
| 1-30% | 󰕿 | `low` |
| 31-70% | 󰖀 | `medium` |
| 71-100% | 󰕾 | `high` |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "volume"
```

### Without Percentage Symbol

```bash
set -g @powerkit_plugins "volume"
set -g @powerkit_plugin_volume_show_percentage "false"
```

### Custom Thresholds

```bash
set -g @powerkit_plugins "volume"
set -g @powerkit_plugin_volume_low_threshold "20"
set -g @powerkit_plugin_volume_medium_threshold "60"
```

### Custom Icons

```bash
set -g @powerkit_plugins "volume"
set -g @powerkit_plugin_volume_icon "🔊"
set -g @powerkit_plugin_volume_icon_medium "🔉"
set -g @powerkit_plugin_volume_icon_low "🔈"
set -g @powerkit_plugin_volume_icon_muted "🔇"
```

## Troubleshooting

### Volume Not Showing

1. Check available audio backends:
   ```bash
   # macOS
   osascript -e 'output volume of (get volume settings)'

   # Linux - PipeWire
   wpctl get-volume @DEFAULT_AUDIO_SINK@

   # Linux - PulseAudio
   pactl get-sink-volume @DEFAULT_SINK@

   # Linux - pamixer
   pamixer --get-volume

   # Linux - ALSA
   amixer sget Master
   ```

2. Install audio backend:
   ```bash
   # Ubuntu/Debian with PipeWire
   sudo apt install pipewire wireplumber

   # Ubuntu/Debian with PulseAudio
   sudo apt install pulseaudio
   ```

### Wrong Volume Level

- Some systems have multiple audio sinks. The plugin uses the default sink.
- Check your default audio device:
  ```bash
  # PipeWire
  wpctl status

  # PulseAudio
  pactl info | grep "Default Sink"
  ```

### Mute State Not Detected

- Ensure your audio backend properly reports mute state
- Try a different backend if available

### Linux Permissions

On some distributions, you may need to be in the `audio` group:
```bash
sudo usermod -aG audio $USER
# Log out and back in
```

## Platform-Specific Notes

### macOS
- Uses AppleScript for volume control
- Always available, no dependencies needed
- Reports system volume (not app-specific)

### Linux
- Multiple backend support for compatibility
- PipeWire recommended for modern systems
- ALSA works but may have limited features

## Related Plugins

- [PluginAudiodevices](PluginAudiodevices) - Audio device selector
- [PluginMicrophone](PluginMicrophone) - Microphone mute status
- [PluginNowplaying](PluginNowplaying) - Currently playing music
