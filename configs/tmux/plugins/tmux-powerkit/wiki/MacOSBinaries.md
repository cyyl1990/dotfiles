# macOS Native Binaries

PowerKit includes native macOS binaries for efficient metric collection. These binaries use Apple's private frameworks and APIs to gather system information that would be slow or impossible to obtain through shell commands.

## Overview

| Binary | Plugin | Framework | Purpose |
|--------|--------|-----------|---------|
| `powerkit-temperature` | [temperature](PluginTemperature) | IOKit | CPU/GPU temperature via SMC |
| `powerkit-gpu` | [gpu](PluginGpu) | IOKit | GPU utilization metrics |
| `powerkit-microphone` | [microphone](PluginMicrophone) | CoreAudio | Microphone mute status |
| `powerkit-nowplaying` | [nowplaying](PluginNowplaying) | ScriptingBridge | Now playing media info |
| `powerkit-brightness` | [brightness](PluginBrightness) | DisplayServices | Screen brightness level |

## Why Native Binaries?

Shell-based approaches for these metrics have significant limitations on macOS:

| Metric | Shell Approach | Problems | Native Solution |
|--------|---------------|----------|-----------------|
| Temperature | `osx-cpu-temp` | Requires third-party install, slow | Direct SMC access via IOKit |
| GPU | `ioreg` parsing | Complex, unreliable for M-series | Direct IOKit queries |
| Microphone | `osascript` | Slow AppleScript execution | CoreAudio API |
| Now Playing | `osascript` | Slow, requires app-specific scripts | ScriptingBridge |
| Brightness | `ioreg` | Stale values on Apple Silicon | DisplayServices API |

## Installation

### Automatic Download (Recommended)

Binaries are **not included in the repository** - they are downloaded on-demand from GitHub Releases when you enable a plugin that requires them.

**How it works:**

1. PowerKit detects which binaries are missing during startup
2. A **single popup** appears listing **all** missing binaries
3. You can choose to:
   - **[Y]es**: Download all binaries
   - **[S]elect**: Choose which binaries to download individually
   - **[N]o**: Skip (won't prompt again for 24h)
4. Downloaded binaries are stored in `bin/` directory
5. Your decision is cached for 24 hours

**No manual installation required!**

### Clearing Download Decisions

If you declined to download binaries and want to be prompted again:

```bash
# Clear all binary decisions
rm -f ~/.cache/tmux-powerkit/data/binary_decision_*

# Clear tracking files
rm -f /tmp/powerkit_missing_binaries /tmp/powerkit_binary_pending_all

# Reload tmux to trigger prompt
tmux source ~/.tmux.conf
```

Or run the prompt manually:

```bash
~/.tmux/plugins/tmux-powerkit/bin/powerkit-binary-prompt \
    "powerkit-gpu:gpu powerkit-temperature:temperature"
```

### Manual Download

If automatic download fails, you can manually download binaries from:

```
https://github.com/fabioluciano/tmux-powerkit/releases/latest
```

Download the appropriate binary for your architecture:
- `powerkit-*-darwin-arm64` for Apple Silicon (M1/M2/M3)
- `powerkit-*-darwin-amd64` for Intel Macs

Place in `~/.tmux/plugins/tmux-powerkit/bin/` and make executable:

```bash
chmod +x ~/.tmux/plugins/tmux-powerkit/bin/powerkit-*
```

### Building from Source

Source code is available in `src/native/macos/`:

```bash
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos

# Build all binaries
make all

# Build specific binary
make powerkit-temperature
make powerkit-gpu
make powerkit-microphone
make powerkit-nowplaying
make powerkit-brightness

# Clean build artifacts
make clean

# Copy to bin directory
cp powerkit-* ../../bin/
```

### Build Requirements

- Xcode Command Line Tools
- macOS SDK 10.15+

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

---

## Binary Details

### powerkit-temperature

Reads CPU and GPU temperatures from the System Management Controller (SMC).

**Source:** `src/native/macos/powerkit-temperature.m`

**Frameworks:**
- Foundation
- IOKit

**Usage:**
```bash
./powerkit-temperature [source]
```

**Arguments:**
| Argument | Description |
|----------|-------------|
| (none) | Auto-detect highest CPU temperature |
| `cpu` | CPU cluster temperature |
| `gpu` | GPU temperature |
| `auto` | Same as no argument |

**Output:**
```
45.2
```

**SMC Keys:**

| Chip Type | CPU Key | GPU Key |
|-----------|---------|---------|
| Apple Silicon (M1/M2/M3) | `Tp0f` | `Tg0j` |
| Intel | `TC0P` | `TG0D` |

**Example:**
```bash
# Auto-detect
./powerkit-temperature
# Output: 48.5

# CPU specific
./powerkit-temperature cpu
# Output: 52.1

# GPU specific
./powerkit-temperature gpu
# Output: 45.8
```

---

### powerkit-gpu

Reads GPU utilization metrics using IOKit.

**Source:** `src/native/macos/powerkit-gpu.m`

**Frameworks:**
- Foundation
- IOKit

**Usage:**
```bash
./powerkit-gpu
```

**Output:**
```
Device Utilization %:42
```

**Notes:**
- Works with both integrated and discrete GPUs
- On Apple Silicon, reports unified GPU utilization
- On Intel Macs with discrete GPU, reports discrete GPU when active

**Example:**
```bash
./powerkit-gpu
# Output: Device Utilization %:42
```

---

### powerkit-microphone

Detects microphone mute status using CoreAudio.

**Source:** `src/native/macos/powerkit-microphone.m`

**Frameworks:**
- Foundation
- CoreAudio
- AudioToolbox

**Usage:**
```bash
./powerkit-microphone
```

**Output:**
```
muted
```
or
```
unmuted
```

**Notes:**
- Checks the system-wide default input device
- Returns "muted" if input volume is 0 or mute is enabled
- Returns "unmuted" otherwise

**Example:**
```bash
./powerkit-microphone
# Output: unmuted
```

---

### powerkit-nowplaying

Gets currently playing media information using ScriptingBridge.

**Source:** `src/native/macos/powerkit-nowplaying.m`

**Frameworks:**
- Foundation
- ScriptingBridge

**Usage:**
```bash
./powerkit-nowplaying
```

**Output:**
```
artist|||track|||album
```

Fields are separated by `|||` delimiter.

**Supported Applications:**
- Apple Music
- Spotify
- Other apps that support macOS Media Player APIs

**Notes:**
- Returns empty fields if no media is playing
- Handles special characters in track/artist names
- Falls back gracefully if music apps aren't running

**Example:**
```bash
./powerkit-nowplaying
# Output: The Beatles|||Hey Jude|||Past Masters

# No music playing:
# Output: ||||||
```

---

## Fallback Behavior

Each plugin has fallback behavior when native binaries are unavailable:

| Plugin | Fallback Method |
|--------|-----------------|
| temperature | `osx-cpu-temp`, `smctemp`, `iStats` |
| gpu | Returns `inactive` state (no fallback) |
| microphone | Returns `inactive` state (no fallback) |
| nowplaying | Returns `inactive` state (no fallback) |
| brightness | `ioreg` (may have stale values on Apple Silicon) |

Plugins without fallbacks will prompt you to download the binary when first used.

---

## Troubleshooting

### Binary Not Executable

```bash
chmod +x ~/.tmux/plugins/tmux-powerkit/bin/powerkit-*
```

### Binary Crashes

1. Check macOS version compatibility
2. Rebuild from source:
   ```bash
   cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
   make clean && make all
   cp powerkit-* ../../bin/
   ```

### Permission Denied

Some binaries may require additional permissions:

1. **Temperature:** May need Full Disk Access on some systems
2. **Microphone:** May trigger microphone access prompt

### Wrong Architecture

If you see "bad CPU type" errors:

```bash
# Check binary architecture
file ~/.tmux/plugins/tmux-powerkit/bin/powerkit-temperature

# Rebuild for your architecture
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
make clean && make all
cp powerkit-* ../../bin/
```

### Download Failed

If automatic download fails:

1. Check your internet connection
2. Verify GitHub releases are accessible:
   ```bash
   curl -I https://github.com/fabioluciano/tmux-powerkit/releases/latest
   ```
3. Try manual download from releases page
4. Or build from source (see above)

### Popup Not Appearing

If the download popup doesn't appear:

```bash
# Clear any stale state
rm -f /tmp/powerkit_missing_binaries /tmp/powerkit_binary_pending_all
rm -f ~/.cache/tmux-powerkit/data/binary_decision_*

# Ensure binaries are missing
rm -f ~/.tmux/plugins/tmux-powerkit/bin/powerkit-{gpu,temperature,microphone,nowplaying,brightness}

# Reload tmux
tmux source ~/.tmux.conf
```

### Closed Popup by Accident

If you closed the popup with Ctrl+C before making a choice:
- The popup should appear again on next tmux refresh (no decision was saved)
- If it doesn't, clear the tracking files as shown above

### SMC Access Issues (Temperature)

On some systems, SMC access may be restricted:

1. Check System Integrity Protection (SIP) status:
   ```bash
   csrutil status
   ```

2. The binary uses documented IOKit APIs and should work with SIP enabled

---

## Security Considerations

### Code Signing

The pre-built binaries are unsigned. macOS Gatekeeper may block them on first run:

1. Right-click the binary and select "Open"
2. Or allow in System Preferences → Security & Privacy

### Source Code Review

All source code is available in `src/native/macos/` for review:
- `powerkit-temperature.m`
- `powerkit-gpu.m`
- `powerkit-microphone.m`
- `powerkit-nowplaying.m`
- `powerkit-brightness.m`

### Building Your Own

For maximum security, build the binaries yourself:

```bash
cd ~/.tmux/plugins/tmux-powerkit/src/native/macos
make clean && make all
cp powerkit-* ../../bin/
```

---

## Development

### Adding New Binaries

1. Create source file in `src/native/macos/`:
   ```objective-c
   // powerkit-example.m
   #import <Foundation/Foundation.h>

   int main(int argc, char *argv[]) {
       @autoreleasepool {
           // Your code here
           printf("result\n");
       }
       return 0;
   }
   ```

2. Add to `src/native/macos/Makefile`:
   ```makefile
   powerkit-example: powerkit-example.m
   	$(CC) $(CFLAGS) -framework Foundation -o $@ $<
   ```

3. Build:
   ```bash
   cd src/native/macos
   make powerkit-example
   cp powerkit-example ../../bin/
   ```

4. Update `.releaserc` to include in GitHub releases

### Testing

```bash
cd bin

# Test each binary
./powerkit-temperature
./powerkit-gpu
./powerkit-microphone
./powerkit-nowplaying
./powerkit-brightness
```

---

## Related

- [PluginTemperature](PluginTemperature) - Temperature monitoring
- [PluginGpu](PluginGpu) - GPU utilization
- [PluginMicrophone](PluginMicrophone) - Microphone status
- [PluginNowplaying](PluginNowplaying) - Now playing media
- [Troubleshooting](Troubleshooting) - General troubleshooting
