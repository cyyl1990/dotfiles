# Plugin: microphone

Display microphone activity status with mute detection on macOS and Linux.

## Screenshots

```
 ON
 MUTED
 75%
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | macOS: `powerkit-microphone` binary, Linux: `pactl` or `amixer` (optional) |
| Content Type | dynamic |
| Presence | conditional (hidden when inactive) |

## macOS Native Binary

This plugin uses a native macOS binary for efficient microphone status detection using CoreAudio APIs.

| Property | Value |
|----------|-------|
| **Binary** | `bin/powerkit-microphone` |
| **Source** | `src/native/macos/powerkit-microphone.m` |
| **Frameworks** | Foundation, CoreAudio, AudioToolbox |

### Automatic Download

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

### Manual Compilation

```bash
cd src/native/macos && make powerkit-microphone
cp powerkit-microphone ../../bin/
```

### Fallback

If the binary is not available and you decline the download, the plugin returns `inactive` state on macOS (no fallback method available).

### Binary Features

The native binary provides:
- Active microphone usage detection (`-a`)
- Mute status detection (`-m`)
- Input volume level (`-v`)
- List all input devices (`-l`)

## Quick Start

```bash
# Add to your tmux configuration
set -g @powerkit_plugins "microphone"

# Reload tmux configuration
tmux source-file ~/.tmux.conf
```

## Configuration Example

```bash
set -g @powerkit_plugins "microphone"

# Display options
set -g @powerkit_plugin_microphone_show_volume "false"

# Icons
set -g @powerkit_plugin_microphone_icon ""
set -g @powerkit_plugin_microphone_icon_muted ""

# Cache
set -g @powerkit_plugin_microphone_cache_ttl "2"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_microphone_show_volume` | bool | `false` | Show input volume level |
| `@powerkit_plugin_microphone_icon` | icon | `` | Microphone on icon |
| `@powerkit_plugin_microphone_icon_muted` | icon | `` | Microphone muted icon |
| `@powerkit_plugin_microphone_cache_ttl` | number | `2` | Cache duration in seconds |

## States

| State | Condition |
|-------|-----------|
| `active` | Microphone is being used or available |
| `inactive` | Microphone not in use (plugin hidden) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Microphone active and unmuted |
| `warning` | Microphone active but muted |
| `info` | Microphone available but not in use |

## Context Values

| Context | Description |
|---------|-------------|
| `muted` | Microphone is muted (volume = 0) |
| `unmuted` | Microphone is active and unmuted |

## Examples

### Basic Setup

```bash
set -g @powerkit_plugins "microphone"
```

### Show Volume Level

```bash
set -g @powerkit_plugins "microphone"
set -g @powerkit_plugin_microphone_show_volume "true"
```

### Custom Icons

```bash
set -g @powerkit_plugins "microphone"
set -g @powerkit_plugin_microphone_icon ""
set -g @powerkit_plugin_microphone_icon_muted ""
```

### Faster Updates

```bash
set -g @powerkit_plugins "microphone"
set -g @powerkit_plugin_microphone_cache_ttl "1"
```

## Platform-Specific Behavior

### macOS

Uses `osascript` to read input volume:
```bash
osascript -e "input volume of (get volume settings)"
```

Detection:
- **Volume = 0**: Muted
- **Volume > 0**: Unmuted

The plugin always shows on macOS when input volume is available (simplified behavior).

### Linux

Uses PulseAudio/PipeWire (via `pactl`) or ALSA (via `amixer`) to detect microphone status.

Detection methods:
1. **pactl**: Check source outputs for active capture
2. **lsof**: Check `/dev/snd/*` for capture devices
3. **Process detection**: Check for common mic-using processes (zoom, teams, discord, etc.)

Mute detection:
- **pactl**: `pactl get-source-mute`
- **amixer**: `amixer get Capture | grep [off]`

## Display Format

| Condition | Output |
|-----------|--------|
| Muted | `MUTED` |
| Active with volume display | `75%` |
| Active without volume | `ON` |
| Inactive | (hidden) |

## Troubleshooting

### Plugin Not Showing (macOS)

1. Check if osascript works:
   ```bash
   osascript -e "input volume of (get volume settings)"
   ```

2. Verify input device is configured:
   - System Preferences > Sound > Input
   - Select an input device

3. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin microphone
   ```

### Plugin Not Showing (Linux)

1. Check if pactl is available:
   ```bash
   which pactl
   pactl list short sources
   ```

2. Verify microphone is active:
   ```bash
   pactl list short source-outputs
   ```

3. Check for mic-using processes:
   ```bash
   lsof /dev/snd/* | grep -E "pcmC[0-9]+D[0-9]+c"
   ```

4. Test plugin directly:
   ```bash
   POWERKIT_ROOT="/path/to/tmux-powerkit" ./bin/powerkit-plugin microphone
   ```

### Always Shows as Muted

**macOS**:
1. Check actual input volume:
   ```bash
   osascript -e "input volume of (get volume settings)"
   ```

2. Adjust input volume in System Preferences > Sound > Input

**Linux**:
1. Check mute status:
   ```bash
   pactl get-source-mute @DEFAULT_SOURCE@
   ```

2. Unmute:
   ```bash
   pactl set-source-mute @DEFAULT_SOURCE@ 0
   ```

### Not Detecting Microphone Usage (Linux)

The plugin checks for active capture in this order:

1. **PulseAudio source outputs** (most reliable)
2. **lsof on audio devices** (checks device access)
3. **Process names** (checks known applications)

If none work, install pactl:
```bash
# Ubuntu/Debian
sudo apt install pulseaudio-utils

# Fedora
sudo dnf install pulseaudio-utils

# Arch
sudo pacman -S pulseaudio
```

### Performance Issues

If the plugin causes lag:

1. Increase cache TTL:
   ```bash
   set -g @powerkit_plugin_microphone_cache_ttl "5"
   ```

2. Check if detection commands are slow:
   ```bash
   time pactl list short source-outputs
   time lsof /dev/snd/*
   ```

## Known Limitations

### macOS
- Cannot reliably detect actual microphone usage without SIP bypass
- Plugin shows whenever input volume is available
- No per-application usage detection

### Linux
- Requires PulseAudio/PipeWire for best results
- ALSA-only systems have limited detection
- Process-based detection is approximate

## Common Use Cases

### Video Conferencing

Monitor mic status during calls:
```bash
set -g @powerkit_plugins "microphone,camera"
```

### Recording

Confirm mic is active and unmuted:
```bash
set -g @powerkit_plugins "microphone"
set -g @powerkit_plugin_microphone_show_volume "true"
```

### Privacy Monitoring

Quickly see if mic is in use:
```bash
set -g @powerkit_plugins "microphone,camera"
```

## Related Plugins

- [PluginCamera](PluginCamera) - Camera usage indicator
- [PluginVolume](PluginVolume) - System volume control
- [PluginAudiodevices](PluginAudiodevices) - Audio output device
