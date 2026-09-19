# Plugins

PowerKit includes **43 native plugins** plus support for **external plugins** that allow you to add custom content from shell commands.

## Quick Start

```bash
# Enable plugins (comma-separated)
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname,git"
```

---

## Native Plugins

### System Monitoring (13 plugins)

Plugins for monitoring system resources and hardware status.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [battery](PluginBattery) | Battery level with charge state | All | pmset/upower |
| [cpu](PluginCpu) | CPU usage with thresholds | All | sysctl/top |
| [memory](PluginMemory) | Memory usage with thresholds | All | vm_stat/free |
| [swap](PluginSwap) | Swap memory usage with thresholds | All | sysctl/vm_stat/proc |
| [disk](PluginDisk) | Disk usage with thresholds | All | df |
| [loadavg](PluginLoadavg) | System load average | All | uptime |
| [uptime](PluginUptime) | System uptime | All | uptime |
| [temperature](PluginTemperature) | CPU temperature | macOS | powerkit-temperature |
| [fan](PluginFan) | Fan speed monitoring | All | hwmon/osx-cpu-temp |
| [gpu](PluginGpu) | GPU usage and temperature | All | nvidia-smi/sysfs/powerkit-gpu |
| [iops](PluginIops) | Disk I/O operations | All | iostat |
| [hostname](PluginHostname) | System hostname | All | - |
| [volume](PluginVolume) | System volume level | macOS | osascript |

### Network (7 plugins)

Plugins for network monitoring and connectivity status.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [netspeed](PluginNetspeed) | Upload/download speed | All | ifstat/netstat |
| [wifi](PluginWifi) | WiFi SSID and signal strength | All | airport/nmcli |
| [vpn](PluginVpn) | VPN connection status | All | tun/tap interfaces |
| [ping](PluginPing) | Network latency with thresholds | All | ping |
| [external_ip](PluginExternalip) | Public IP address | All | ipify API |
| [ssh](PluginSsh) | SSH session indicator | All | - |
| [weather](PluginWeather) | Weather from wttr.in | All | wttr.in API |

### Media & Audio (7 plugins)

Plugins for media playback and audio control.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [nowplaying](PluginNowplaying) | Current music track | macOS | powerkit-nowplaying |
| [audiodevices](PluginAudiodevices) | Audio output device | macOS | SwitchAudioSource |
| [camera](PluginCamera) | Camera usage indicator | macOS | lsof |
| [microphone](PluginMicrophone) | Microphone mute status | macOS | powerkit-microphone |
| [bluetooth](PluginBluetooth) | Bluetooth status and devices | All | blueutil/bluetoothctl |
| [brightness](PluginBrightness) | Screen brightness | Linux | sysfs/brightnessctl |

### Development (10 plugins)

Plugins for development tools and services.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [git](PluginGit) | Branch and modified files | All | git |
| [github](PluginGithub) | Notifications, PRs, issues | All | gh CLI |
| [gitlab](PluginGitlab) | Merge requests, todos | All | glab CLI |
| [bitbucket](PluginBitbucket) | Pull requests count | All | API |
| [jira](PluginJira) | Assigned issues count | All | API |
| [kubernetes](PluginKubernetes) | Context and namespace | All | kubectl |
| [terraform](PluginTerraform) | Workspace indicator | All | terraform |
| [cloud](PluginCloud) | Cloud provider profile | All | AWS/Azure/GCP |
| [cloudstatus](PluginCloudstatus) | Service status monitoring | All | status APIs |
| [packages](PluginPackages) | Pending package updates | All | brew/apt/yum/pacman |

### Productivity (5 plugins)

Plugins for time management and productivity.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [datetime](PluginDatetime) | Date/time with 15 format presets | All | - |
| [timezones](PluginTimezones) | Multi-timezone display | All | - |
| [pomodoro](PluginPomodoro) | Timer with work/break phases | All | - |
| [bitwarden](PluginBitwarden) | Vault lock status | All | bw CLI |
| [smartkey](PluginSmartkey) | Custom environment variable display | All | - |

### Financial (2 plugins)

Plugins for financial data monitoring.

| Plugin | Description | Platform | Documentation |
|--------|-------------|----------|---------------|
| [crypto](PluginCrypto) | Cryptocurrency prices | All | CoinGecko API |
| [stocks](PluginStocks) | Stock prices | All | Yahoo Finance API |

---

## Platform-Specific Plugins

### Linux Only

- `brightness` - Screen brightness (sysfs/brightnessctl/light/xbacklight)

### Cross-Platform (with macOS native binaries)

These plugins work on both macOS and Linux. On macOS, they require native binaries (downloaded on-demand):

| Plugin | macOS Backend | Linux Backend |
|--------|---------------|---------------|
| `temperature` | powerkit-temperature | /sys/class/hwmon |
| `microphone` | powerkit-microphone | pactl/amixer |
| `nowplaying` | powerkit-nowplaying | playerctl |
| `gpu` | powerkit-gpu | nvidia-smi/sysfs |

### Cross-Platform (with platform backends)

These plugins use different tools on each platform:

| Plugin | macOS Backend | Linux Backend |
|--------|---------------|---------------|
| `volume` | osascript | pactl/amixer |
| `camera` | lsof | /sys/class/video4linux |
| `audiodevices` | SwitchAudioSource | pactl |
| `fan` | osx-cpu-temp/iStats | hwmon/dell_smm/thinkpad |
| `bluetooth` | blueutil | bluetoothctl |
| `wifi` | airport | nmcli/iwconfig |
| `battery` | pmset | upower/sysfs |
| `swap` | sysctl/vm_stat | /proc/meminfo |

### Fully Cross-Platform

All other plugins work identically on both macOS and Linux.

---

## External Plugins

External plugins allow you to add custom content to the status bar using shell commands. They integrate seamlessly with native plugins and support full theming.

### Format

```bash
external("icon"|"content"|"accent"|"accent_icon"|"ttl")
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `icon` | Nerd Font icon to display | `"󰊠"`, `""`, `"󰔟"` |
| `content` | Static text or shell command | `"Hello"`, `"$(whoami)"`, `"#(date)"` |
| `accent` | Background color for content | `"info-base"`, `"ok-base"`, `"#7aa2f7"` |
| `accent_icon` | Background color for icon | `"info-base-lighter"`, `"ok-base-lighter"` |
| `ttl` | Cache duration in seconds | `"60"`, `"300"`, `"0"` (no cache) |

### Content Types

| Type | Syntax | Description |
|------|--------|-------------|
| Static text | `"Hello World"` | Displayed as-is |
| Command substitution | `"$(command)"` | Executed by shell, cached |
| tmux format | `"#(command)"` | Converted to `$()` internally |

### Color Options

You can use any of these color values:

- **Theme colors**: `ok-base`, `info-base`, `warning-base`, `error-base`, `window-active-base`
- **Color variants**: `ok-base-lighter`, `info-base-darker`, `window-active-base-lightest`, etc.
- **Hex colors**: `"#7aa2f7"`, `"#bb9af7"`, `"#f7768e"`

### Examples

```bash
# Show current user with green background
external(""|"$(whoami)"|"ok-base"|"ok-base-lighter"|"3600")

# Show uptime with blue background
external("󰔟"|"$(uptime -p | sed 's/up //')"|"info-base"|"info-base-lighter"|"60")

# Static message with purple background
external("󰍡"|"Production"|"window-active-base"|"window-active-base-lighter"|"0")

# Git branch (alternative to git plugin)
external(""|"$(git branch --show-current 2>/dev/null || echo 'N/A')"|"warning-base"|"warning-base-lighter"|"30")

# Docker container count
external("󰡨"|"$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')"|"info-base"|"info-base-lighter"|"30")

# Node.js version
external("󰎙"|"$(node -v 2>/dev/null || echo 'N/A')"|"ok-base"|"ok-base-lighter"|"3600")

# Current Kubernetes namespace
external("󱃾"|"$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)"|"info-base"|"info-base-lighter"|"60")
```

### Usage in Plugin List

External plugins are added to `@powerkit_plugins` alongside native plugins:

```bash
# Mix native and external plugins
set -g @powerkit_plugins "cpu,memory,external(\"󰊠\"|\"$(hostname -s)\"|\"info-base\"|\"info-base-lighter\"|\"3600\"),git"

# Multiple external plugins
set -g @powerkit_plugins "datetime,external(\"󰀄\"|\"$(whoami)\"|\"ok-base\"|\"ok-base-lighter\"|\"3600\"),external(\"󰔟\"|\"$(uptime -p)\"|\"info-base\"|\"info-base-lighter\"|\"60\"),hostname"
```

### Tips

1. **Use appropriate TTL**: For static info like hostname, use high TTL (3600+). For dynamic data, use lower TTL (30-60).

2. **Test commands first**: Run your commands in terminal to ensure they work before adding to config.

3. **Handle errors**: Use `|| echo 'fallback'` to provide fallback values when commands fail.

4. **Keep it short**: Status bar space is limited. Truncate long outputs in your commands.

5. **Escape quotes**: Use `\"` for quotes inside the external plugin definition.

---

## Plugin Configuration

Each native plugin supports individual configuration via `@powerkit_plugin_<name>_<option>`. Common options include:

| Option | Description |
|--------|-------------|
| `icon` | Custom icon for the plugin |
| `cache_ttl` | Cache duration in seconds |
| `warning_threshold` | Threshold for warning state |
| `critical_threshold` | Threshold for error state |
| `show_only_on_threshold` | Only show when threshold exceeded |

See individual plugin documentation for specific options.

---

## Related

- [Configuration](Configuration) - All configuration options
- [Developing Plugins](DevelopingPlugins) - Create custom plugins
- [Plugin Contract](ContractPlugin) - How plugins work internally
- [macOS Binaries](MacOSBinaries) - Native binary downloads
