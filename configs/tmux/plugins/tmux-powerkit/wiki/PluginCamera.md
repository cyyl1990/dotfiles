# Plugin: camera

Display camera usage indicator for privacy awareness.

## Screenshot

```
 ON      # Camera active - blue/info
(hidden)  # Camera inactive - not shown
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux |
| **Dependencies** | Built-in (macOS), `lsof` (Linux, optional) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS - no dependencies needed (uses built-in camera daemons)

# Linux (Debian/Ubuntu)
sudo apt install lsof

# Linux (Fedora)
sudo dnf install lsof

# Linux (Arch)
sudo pacman -S lsof
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "camera"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "camera"

# Icon
set -g @powerkit_plugin_camera_icon "󰄀"

# Cache duration (seconds) - check frequently for privacy
set -g @powerkit_plugin_camera_cache_ttl "2"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_camera_icon` | icon | `󰄀` | Camera active icon |
| `@powerkit_plugin_camera_cache_ttl` | number | `2` | Cache duration in seconds |
| `@powerkit_plugin_camera_show_only_on_threshold` | bool | `false` | Not applicable for this plugin |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Camera is in use | Visible |
| `inactive` | Camera is not in use | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `info` | Camera is active (informational indicator) | Blue |

Note: Camera activity uses `info` health level to provide a neutral visual indicator without implying a problem.

## Context Values

The plugin does not return context values (empty string).

## Detection Methods

### macOS

Monitors camera-related system processes:

| Process | Description |
|---------|-------------|
| `VDCAssistant` | Video Digitizer Camera Assistant |
| `appleh16camerad` | Apple H16 Camera Daemon |
| `cameracaptured` | Camera Capture Daemon |
| `UVCAssistant` | USB Video Class Assistant |

Detection criteria:
- Process must be running
- CPU usage ≥ 1% (indicates active use)

### Linux

Checks device files for camera access:

```bash
# Method 1: lsof
lsof /dev/video*

# Method 2: fuser (fallback)
fuser /dev/video*
```

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "camera"
```

### Privacy-Focused Status Bar

Combine with microphone for complete privacy awareness:

```bash
set -g @powerkit_plugins "camera,microphone"
```

### Custom Icon

```bash
set -g @powerkit_plugins "camera"
set -g @powerkit_plugin_camera_icon "📷"
```

### Faster Detection

Reduce cache TTL for near real-time updates:

```bash
set -g @powerkit_plugins "camera"
set -g @powerkit_plugin_camera_cache_ttl "1"
```

Note: Lower cache TTL increases CPU usage slightly.

## Use Cases

### Privacy Awareness

Visual indicator during video calls:

```bash
set -g @powerkit_plugins "camera,microphone"
# Shows when camera and/or mic are active
```

### Remote Work

Know when your camera is on during meetings:

```bash
set -g @powerkit_plugins "camera,datetime"
# Camera indicator appears during video calls
```

### Recording Indicator

Monitor when screen recording or video capture is active:

```bash
set -g @powerkit_plugins "camera"
# Appears when recording software uses camera
```

## Troubleshooting

### Camera Always Shows as Active

If the indicator persists even when no apps are using the camera:

**macOS:**

1. Check running camera processes:
   ```bash
   ps aux | grep -i camera
   ps aux | grep VDCAssistant
   ```

2. Force quit camera processes:
   ```bash
   sudo killall VDCAssistant
   sudo killall AppleCameraAssistant
   ```

3. Check which apps have camera access:
   - System Settings → Privacy & Security → Camera

**Linux:**

1. Check device usage:
   ```bash
   lsof /dev/video0
   fuser -v /dev/video0
   ```

2. Identify the process:
   ```bash
   lsof /dev/video* | grep -v COMMAND
   ```

### Camera Never Shows as Active

**macOS:**

1. Verify camera processes start when using camera:
   ```bash
   # Open Photo Booth or FaceTime
   # Then check:
   ps aux | grep VDCAssistant
   ```

2. The plugin requires CPU usage ≥1% for detection:
   ```bash
   # Check CPU usage of camera processes
   top -l 1 | grep -i camera
   ```

**Linux:**

1. Check if lsof is installed:
   ```bash
   which lsof
   ```

2. Install if missing:
   ```bash
   sudo apt install lsof
   ```

3. Verify camera device exists:
   ```bash
   ls -l /dev/video*
   ```

4. Test camera access:
   ```bash
   # Install v4l-utils
   sudo apt install v4l-utils
   v4l2-ctl --list-devices
   ```

### Permission Issues (Linux)

If lsof requires elevated permissions:

```bash
# Add user to video group
sudo usermod -aG video $USER

# Log out and back in
```

## Platform Differences

| Platform | Detection | Accuracy | Notes |
|----------|-----------|----------|-------|
| macOS | Process monitoring | High | Checks CPU usage to avoid false positives |
| Linux | Device file access | Medium | Requires lsof or fuser |

## Performance Notes

- **macOS**: Lightweight process monitoring
- **Linux**: lsof adds minimal overhead
- Default cache TTL is 2 seconds
- Frequent polling (low cache TTL) increases CPU usage slightly

## Privacy Considerations

- Plugin only detects camera usage, doesn't control it
- Provides passive monitoring for awareness
- No data is logged or transmitted
- Purely local detection

## Limitations

### macOS
- May not detect all third-party camera apps
- Some camera processes may be low CPU when idle but still active
- Background camera access might not be detected

### Linux
- Requires lsof or fuser for reliable detection
- Some containerized applications may not be detected
- Virtual camera devices (v4l2loopback) may show as active

## Applications That Trigger Detection

### macOS
- FaceTime
- Photo Booth
- Zoom, Teams, Slack (video calls)
- OBS Studio
- QuickTime Player (video recording)
- Safari/Chrome (WebRTC)

### Linux
- Cheese (webcam app)
- Zoom, Teams (video calls)
- Firefox/Chrome (WebRTC)
- OBS Studio
- ffmpeg/v4l2 capture tools

## Related Plugins

- [PluginMicrophone](PluginMicrophone) - Microphone mute status
- [PluginBluetooth](PluginBluetooth) - Bluetooth device status
- [PluginAudiodevices](PluginAudiodevices) - Audio device selector
