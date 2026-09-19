# PowerKit

Welcome to the PowerKit documentation. PowerKit is a comprehensive tmux status bar framework that provides 43 native plugins, external plugin support, 32 themes, and a contract-based architecture for extensibility.

## What is PowerKit?

PowerKit transforms your tmux status bar into an informative dashboard with real-time system metrics, development tool integrations, and productivity features. It uses a modern contract-based architecture that separates data collection from visual presentation.

## Requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| tmux | 3.0+ | 3.2+ recommended |
| Bash | 5.0+ | 5.1+ recommended for optimal performance |
| Font | Nerd Font | For icons and separators |

> **macOS users:** macOS ships with Bash 3.x. Install Bash 5+ with `brew install bash`.

## Quick Navigation

### Getting Started
- [Installation](Installation) - Setup guide for TPM and manual installation
- [Quick Start](Quick-Start) - Get up and running in minutes
- [Configuration](Configuration) - All configuration options
- [Options Reference](assets/powerkit-options.conf) - Complete tmux.conf template

### Architecture
- [Architecture Overview](Architecture) - How PowerKit works internally
- [Caching System](Caching) - Multi-layer cache for performance

### Contracts
- [Plugin Contract](ContractPlugin) - How plugins provide data and semantics
- [Theme Contract](ContractTheme) - How themes define colors
- [Helper Contract](ContractHelper) - How helpers provide UI interactions
- [Session Contract](ContractSession) - Session state representation
- [Window Contract](ContractWindow) - Window state representation
- [Pane Contract](ContractPane) - Pane borders, flash effect, and sync indicator

### Development
- [Developing Plugins](DevelopingPlugins) - Create your own plugins
- [Developing Helpers](DevelopingHelpers) - Create interactive menus
- [Developing Themes](DevelopingThemes) - Create custom themes
- [Keybindings](Keybindings) - Keybinding system and conflict resolution

### Reference
- [Plugins](Plugins) - All 43 native plugins + external plugins
- [Available Themes](Themes) - All 32 themes with 56 variants
- [Global Helpers](Helpers) - System-wide helpers
- [macOS Native Binaries](MacOSBinaries) - Native binaries for efficient metrics

### Help
- [Troubleshooting](Troubleshooting) - Common issues and solutions

### Plugins Overview

See the [Plugins](Plugins) page for complete documentation including external plugins.

| Category | Plugins |
|----------|---------|
| System | [battery](PluginBattery), [cpu](PluginCpu), [memory](PluginMemory), [swap](PluginSwap), [disk](PluginDisk), [loadavg](PluginLoadavg), [uptime](PluginUptime), [temperature](PluginTemperature), [fan](PluginFan), [gpu](PluginGpu), [iops](PluginIops), [hostname](PluginHostname), [volume](PluginVolume) |
| Network | [netspeed](PluginNetspeed), [wifi](PluginWifi), [vpn](PluginVpn), [ping](PluginPing), [external_ip](PluginExternalip), [ssh](PluginSsh), [weather](PluginWeather) |
| Media | [brightness](PluginBrightness), [nowplaying](PluginNowplaying), [audiodevices](PluginAudiodevices), [camera](PluginCamera), [microphone](PluginMicrophone), [bluetooth](PluginBluetooth) |
| Development | [git](PluginGit), [github](PluginGithub), [gitlab](PluginGitlab), [bitbucket](PluginBitbucket), [jira](PluginJira), [kubernetes](PluginKubernetes), [terraform](PluginTerraform), [cloud](PluginCloud), [cloudstatus](PluginCloudstatus), [packages](PluginPackages) |
| Productivity | [datetime](PluginDatetime), [timezones](PluginTimezones), [pomodoro](PluginPomodoro), [bitwarden](PluginBitwarden), [smartkey](PluginSmartkey) |
| Financial | [crypto](PluginCrypto), [stocks](PluginStocks) |
| External | Custom plugins via `external("icon"\|"content"\|"accent"\|"accent_icon"\|"ttl")` |

## Support

- [GitHub Issues](https://github.com/fabioluciano/tmux-powerkit/issues)
- [GitHub Discussions](https://github.com/fabioluciano/tmux-powerkit/discussions)
