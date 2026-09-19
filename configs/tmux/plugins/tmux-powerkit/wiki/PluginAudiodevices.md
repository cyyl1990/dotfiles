# Plugin: audiodevices

Display and switch between audio input/output devices with interactive selector.

## Screenshot

```
  AirPods Pro                   # Output only
  Built-in Microphone           # Input only
  AirPods Pro | USB Microphone  # Both input and output
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | `SwitchAudioSource` (macOS), `pactl` (Linux PulseAudio) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS
brew install switchaudio-osx

# Linux - pactl is usually pre-installed with PulseAudio
# If missing:
# Debian/Ubuntu
sudo apt install pulseaudio-utils

# Fedora
sudo dnf install pulseaudio-utils

# Arch
sudo pacman -S pulseaudio
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "audiodevices"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "audiodevices"

# Display mode
set -g @powerkit_plugin_audiodevices_display_mode "both"  # off, input, output, both

# Device name truncation
set -g @powerkit_plugin_audiodevices_max_length "20"
set -g @powerkit_plugin_audiodevices_truncate_suffix "..."
set -g @powerkit_plugin_audiodevices_separator " | "

# Show device type icons
set -g @powerkit_plugin_audiodevices_show_device_icons "true"

# Icons
set -g @powerkit_plugin_audiodevices_icon ""          # Plugin icon
set -g @powerkit_plugin_audiodevices_input_icon ""    # Input device icon
set -g @powerkit_plugin_audiodevices_output_icon ""   # Output device icon

# Keybindings for device selectors
set -g @powerkit_plugin_audiodevices_keybinding_input "C-i"
set -g @powerkit_plugin_audiodevices_keybinding_output "C-o"

# Cache duration (seconds)
set -g @powerkit_plugin_audiodevices_cache_ttl "10"

# Show only on threshold (not applicable for audiodevices)
set -g @powerkit_plugin_audiodevices_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_audiodevices_display_mode` | string | `both` | Display mode: `off`, `input`, `output`, `both` |
| `@powerkit_plugin_audiodevices_max_length` | number | `20` | Maximum device name length |
| `@powerkit_plugin_audiodevices_truncate_suffix` | string | `...` | Truncation suffix |
| `@powerkit_plugin_audiodevices_separator` | string | ` \| ` | Separator between input/output |
| `@powerkit_plugin_audiodevices_show_device_icons` | bool | `true` | Show input/output icons in front of device names |
| `@powerkit_plugin_audiodevices_icon` | icon | `` | Plugin icon |
| `@powerkit_plugin_audiodevices_input_icon` | icon | `` | Input device icon |
| `@powerkit_plugin_audiodevices_output_icon` | icon | `` | Output device icon |
| `@powerkit_plugin_audiodevices_keybinding_input` | key | `C-i` | Keybinding for input device selector |
| `@powerkit_plugin_audiodevices_keybinding_output` | key | `C-o` | Keybinding for output device selector |
| `@powerkit_plugin_audiodevices_cache_ttl` | number | `10` | Cache duration in seconds |
| `@powerkit_plugin_audiodevices_show_only_on_threshold` | bool | `false` | Only show when warning or critical threshold exceeded |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Audio system available and display_mode not "off" | Visible |
| `inactive` | Audio system not available or display_mode is "off" | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Always | Green |

## Context Values

| Context | Description |
|---------|-------------|
| `input_only` | Showing input device only |
| `output_only` | Showing output device only |
| `both_devices` | Showing both input and output |
| `disabled` | Display mode is "off" |

## Display Modes

| Mode | Description | Example |
|------|-------------|---------|
| `output` | Show output device only | ` AirPods Pro` |
| `input` | Show input device only | ` Built-in Microphone` |
| `both` | Show both input and output | ` AirPods Pro \| Built-in Mic` |
| `off` | Plugin hidden | (hidden) |

## Interactive Selectors

### Output Device Selector

**Keybinding**: `prefix + C-o` (default)

Opens an interactive fuzzy finder to switch audio output device.

Features:
- Lists all available output devices
- Shows current device
- Instant switching
- No confirmation required

### Input Device Selector

**Keybinding**: `prefix + C-i` (default)

Opens an interactive fuzzy finder to switch audio input device.

Features:
- Lists all available input devices
- Shows current device
- Instant switching
- No confirmation required

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "audiodevices"
```

### Output Only

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_display_mode "output"
```

### Input Only

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_display_mode "input"
```

### Custom Keybindings

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_keybinding_input "C-M-i"
set -g @powerkit_plugin_audiodevices_keybinding_output "C-M-o"
```

### Short Device Names

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_max_length "15"
set -g @powerkit_plugin_audiodevices_truncate_suffix "…"
```

### Without Device Type Icons

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_show_device_icons "false"
```

### Custom Separator

```bash
set -g @powerkit_plugins "audiodevices"
set -g @powerkit_plugin_audiodevices_separator " • "
```

## Platform Support

### macOS

- Requires **SwitchAudioSource**
- Supports all macOS audio devices
- Works with built-in, USB, and Bluetooth devices
- Instant device switching
- Reliable device names

### Linux (PulseAudio)

- Uses `pactl` (built-in with PulseAudio)
- Supports all PulseAudio devices
- Works with ALSA, USB, and Bluetooth devices
- May show technical device names
- Some devices may have long names (use `max_length` to truncate)

## Common Device Examples

| Device Type | macOS Name | Linux Name (typical) |
|-------------|------------|----------------------|
| Built-in speakers | `MacBook Pro Speakers` | `Built-in Audio Analog Stereo` |
| Built-in mic | `MacBook Pro Microphone` | `Built-in Audio Digital Stereo (IEC958)` |
| AirPods | `John's AirPods Pro` | `AirPods Pro` |
| USB headset | `USB Audio Device` | `USB Audio Device Analog Stereo` |
| HDMI audio | `LG TV` | `HDA NVidia Digital Stereo (HDMI)` |

## Troubleshooting

### Plugin Not Showing

1. Check if audio system is available:
   ```bash
   # macOS
   SwitchAudioSource -a

   # Linux
   pactl list sinks short
   pactl list sources short
   ```

2. Verify display_mode is not "off":
   ```bash
   tmux show-options -g | grep audiodevices_display_mode
   ```

3. Check if dependencies are installed:
   ```bash
   # macOS
   which SwitchAudioSource

   # Linux
   which pactl
   ```

### Device Selector Not Working

1. Verify keybinding is set:
   ```bash
   tmux list-keys | grep audiodevices
   ```

2. Check if helper script exists:
   ```bash
   ls -la ~/.config/tmux/plugins/tmux-powerkit/src/helpers/audio_device_selector.sh
   ```

3. Test manually:
   ```bash
   # macOS
   SwitchAudioSource -t output
   SwitchAudioSource -t input

   # Linux
   pactl list sinks | grep "Name:"
   pactl set-default-sink <sink-name>
   ```

### Wrong Device Name

- Linux may show technical names
- Use `max_length` to truncate:
  ```bash
  set -g @powerkit_plugin_audiodevices_max_length "20"
  ```

### Device Not Switching

1. Check if device is available:
   ```bash
   # macOS
   SwitchAudioSource -a -t output

   # Linux
   pactl list sinks short
   ```

2. Try switching manually:
   ```bash
   # macOS
   SwitchAudioSource -s "Device Name"

   # Linux
   pactl set-default-sink <sink-name>
   ```

### Bluetooth Device Missing

- Ensure Bluetooth device is connected and paired
- On macOS, device must be connected before it appears
- On Linux, PulseAudio module for Bluetooth must be loaded:
  ```bash
  pactl load-module module-bluetooth-discover
  ```

## Related Plugins

- [PluginVolume](PluginVolume) - System volume control
- [PluginNowplaying](PluginNowplaying) - Currently playing music
- [PluginMicrophone](PluginMicrophone) - Microphone mute status
- [PluginBluetooth](PluginBluetooth) - Bluetooth device status
