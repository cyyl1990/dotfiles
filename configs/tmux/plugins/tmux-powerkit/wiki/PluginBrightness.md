# Plugin: brightness

Display screen brightness level with multi-monitor support and context-aware icons.

## Screenshot

```
 65%    # Medium brightness
 25%    # Low brightness
 95%    # High brightness
 50% | 80%  # Multiple displays
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS (Intel & Apple Silicon), Linux |
| **Dependencies** | Native helper `powerkit-brightness` (macOS, recommended), `ioreg` (macOS fallback), `brightnessctl`/`light`/`xbacklight` (Linux optional), `/sys/class/backlight` (Linux) |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

### macOS (Recommended)

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

**No manual installation required!**

### macOS (Manual Compilation)

If you prefer to compile manually:

```bash
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
make powerkit-brightness
cp powerkit-brightness ../../bin/
```

**Requirements:** Xcode Command Line Tools (`xcode-select --install`)

### macOS (Fallback)

If the native helper is not available, the plugin falls back to `ioreg` (may have stale values on Apple Silicon).

### Linux

```bash
# Debian/Ubuntu
sudo apt install brightnessctl

# Arch
sudo pacman -S brightnessctl

# Fedora
sudo dnf install brightnessctl
```

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "brightness"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "brightness"

# Display selection
set -g @powerkit_plugin_brightness_display "builtin"  # builtin, external, all, or display ID
set -g @powerkit_plugin_brightness_separator " | "

# Display options
set -g @powerkit_plugin_brightness_show_percentage "true"

# Icons (context-aware based on brightness level)
set -g @powerkit_plugin_brightness_icon ""           # High brightness (>70%)
set -g @powerkit_plugin_brightness_icon_medium ""    # Medium brightness (30-70%)
set -g @powerkit_plugin_brightness_icon_low ""       # Low brightness (<30%)

# Cache duration (seconds)
set -g @powerkit_plugin_brightness_cache_ttl "5"

# Show only on threshold (if brightness is low/high)
set -g @powerkit_plugin_brightness_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_brightness_display` | string | `builtin` | Display selection: `builtin`, `external`, `all`, or display ID |
| `@powerkit_plugin_brightness_separator` | string | ` \| ` | Separator when showing multiple displays |
| `@powerkit_plugin_brightness_show_percentage` | bool | `true` | Show percentage symbol (%) |
| `@powerkit_plugin_brightness_icon` | icon | `` | Icon for high brightness (>70%) |
| `@powerkit_plugin_brightness_icon_medium` | icon | `` | Icon for medium brightness (30-70%) |
| `@powerkit_plugin_brightness_icon_low` | icon | `` | Icon for low brightness (<30%) |
| `@powerkit_plugin_brightness_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_brightness_show_only_on_threshold` | bool | `false` | Only show when warning or critical threshold exceeded |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Brightness value available | Visible |
| `inactive` | No brightness control detected | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Always | Green |

## Context Values

| Context | Description | Brightness Range |
|---------|-------------|------------------|
| `low` | Low brightness | < 30% |
| `medium` | Medium brightness | 30-70% |
| `high` | High brightness | > 70% |

## Platform-Specific Notes

### macOS (Native Helper - Recommended)

The plugin includes a native Objective-C helper (`bin/powerkit-brightness`) that uses the DisplayServices private framework for reliable brightness reading. The binary is downloaded automatically from GitHub Releases on first use.

**Features:**
- Accurate real-time values on Apple Silicon
- Lists all connected displays with their type (builtin/external)
- No external dependencies

**Output format:**
```
<display_id>:<type>:<brightness>
```

Example:
```
1:builtin:69
2:external:-1
3:external:-1
```

> **Note:** External monitors using DDC/CI return `-1` as they don't support the DisplayServices API. For DDC/CI monitors, consider using tools like `ddcctl` or MonitorControl.

### macOS (ioreg Fallback)

If the native helper is not available, the plugin falls back to `ioreg`:
- Reads from `AppleARMBacklight` (Apple Silicon) or `IODisplayParameters` (Intel)
- May report stale/cached values on Apple Silicon
- Works with internal displays only

### Linux

Multiple detection methods (in order of preference):

1. **sysfs** (`/sys/class/backlight`) - Most reliable, no tools needed
2. **brightnessctl** - User-friendly CLI tool
3. **light** - Alternative CLI tool
4. **xbacklight** - X11-based (legacy)

## Native Helper (powerkit-brightness)

### About

The `powerkit-brightness` is a native macOS utility written in Objective-C that provides reliable brightness reading using the DisplayServices private framework. This is the recommended method for Apple Silicon Macs where `ioreg` may return stale/cached values.

The binary is **downloaded automatically** from GitHub Releases when you first enable this plugin on macOS. A confirmation dialog will ask if you want to download it.

### Source Code

The source code is located at `src/native/macos/powerkit-brightness.m`:

```objc
#import <Foundation/Foundation.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#import <ApplicationServices/ApplicationServices.h>

// DisplayServices private framework declaration
extern int DisplayServicesGetBrightness(CGDirectDisplayID display, float *brightness);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CGDirectDisplayID displays[16];
        uint32_t displayCount = 0;
        
        CGError err = CGGetActiveDisplayList(16, displays, &displayCount);
        if (err != kCGErrorSuccess || displayCount == 0) {
            return 1;
        }
        
        for (uint32_t i = 0; i < displayCount; i++) {
            CGDirectDisplayID displayID = displays[i];
            float brightness = -1;
            int gotBrightness = 0;
            
            BOOL isBuiltin = CGDisplayIsBuiltin(displayID);
            const char *type = isBuiltin ? "builtin" : "external";
            
            int dsResult = DisplayServicesGetBrightness(displayID, &brightness);
            if (dsResult == 0 && brightness >= 0) {
                gotBrightness = 1;
            }
            
            if (gotBrightness) {
                int percentage = (int)(brightness * 100 + 0.5);
                printf("%u:%s:%d\n", displayID, type, percentage);
            } else {
                printf("%u:%s:-1\n", displayID, type);
            }
        }
    }
    return 0;
}
```

### Compiling

**Prerequisites:**
- Xcode Command Line Tools: `xcode-select --install`

**Using Makefile (recommended):**

```bash
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
make powerkit-brightness
cp powerkit-brightness ../../bin/
```

**Manual compilation:**

```bash
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
clang -framework Foundation -framework IOKit -framework ApplicationServices \
      -F /System/Library/PrivateFrameworks -framework DisplayServices \
      powerkit-brightness.m -o powerkit-brightness
cp powerkit-brightness ../../bin/
```

### Testing

```bash
# Run the helper directly
~/.tmux/plugins/tmux-powerkit/bin/powerkit-brightness

# Expected output (example):
# 1:builtin:69
# 2:external:-1
# 3:external:-1
```

### Output Format

Each line represents a display:
- **Field 1**: Display ID (CGDirectDisplayID)
- **Field 2**: Display type (`builtin` or `external`)
- **Field 3**: Brightness percentage (0-100) or `-1` if not available

### Limitations

- **External monitors**: DDC/CI monitors don't support DisplayServices API and will return `-1`
- **Private framework**: Uses DisplayServices which is a private Apple framework (may change in future macOS versions)
- **macOS only**: This helper is specific to macOS

## Display Selection

| Mode | Description | Example |
|------|-------------|---------|
| `builtin` | Built-in display only (default) | ` 65%` |
| `external` | External monitors only (if supported) | ` 80%` |
| `all` | All displays with brightness control | ` 65% \| 80%` |
| `<id>` | Specific display by ID | ` 75%` |

> **Note:** External monitor brightness is only available if the monitor supports software brightness control via DisplayServices API.

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "brightness"
```

### Show All Displays

```bash
set -g @powerkit_plugins "brightness"
set -g @powerkit_plugin_brightness_display "all"
set -g @powerkit_plugin_brightness_separator " · "
```

### External Display Only

```bash
set -g @powerkit_plugins "brightness"
set -g @powerkit_plugin_brightness_display "external"
```

### Custom Icons

```bash
set -g @powerkit_plugins "brightness"
set -g @powerkit_plugin_brightness_icon "☀"
set -g @powerkit_plugin_brightness_icon_medium "⛅"
set -g @powerkit_plugin_brightness_icon_low "🌙"
```

### No Percentage Symbol

```bash
set -g @powerkit_plugins "brightness"
set -g @powerkit_plugin_brightness_show_percentage "false"
```

## Troubleshooting

### Brightness Not Detected (macOS)

1. Check if the binary exists:
   ```bash
   ls -la ~/.tmux/plugins/tmux-powerkit/bin/powerkit-brightness
   ```

2. Compile the native helper if missing:
   ```bash
   cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
   make powerkit-brightness
   cp powerkit-brightness ../../bin/
   ```

3. Test the helper directly:
   ```bash
   ~/.tmux/plugins/tmux-powerkit/bin/powerkit-brightness
   ```

4. If compilation fails, ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

4. Check fallback ioreg values:
   ```bash
   ioreg -c AppleARMBacklight -r
   ioreg -r -k IODisplayParameters
   ```

### Brightness Not Detected (Linux)

1. Check for backlight devices:
   ```bash
   ls /sys/class/backlight/
   ```

2. Try brightnessctl:
   ```bash
   brightnessctl get
   ```

3. Verify permissions (sysfs usually requires no special permissions):
   ```bash
   cat /sys/class/backlight/*/brightness
   ```

### Stale Values (macOS Apple Silicon)

- The `ioreg` fallback may cache values on Apple Silicon
- Use the native helper for real-time accurate readings (downloaded automatically or compile manually):
  ```bash
  cd ~/.tmux/plugins/tmux-powerkit/src/native/macos && make powerkit-brightness
  cp powerkit-brightness ../../bin/
  ```

### External Monitor Not Showing Brightness

External monitors using DDC/CI don't support the DisplayServices API. The helper will list them with brightness `-1`.

For DDC/CI monitor brightness control, consider:
- [ddcctl](https://github.com/kfix/ddcctl) - Command line tool
- [MonitorControl](https://github.com/MonitorControl/MonitorControl) - Menu bar app

### Multiple Displays

- The native helper lists all displays with their type (`builtin` or `external`)
- Only displays with software brightness control will show values
- Use `display="all"` to show all available brightness values
- Linux shows first active backlight device only (sysfs limitation)

## Related Plugins

- [PluginVolume](PluginVolume) - System volume control
- [PluginBattery](PluginBattery) - Battery level monitoring
- [PluginCamera](PluginCamera) - Camera usage indicator
- [PluginMicrophone](PluginMicrophone) - Microphone mute status
