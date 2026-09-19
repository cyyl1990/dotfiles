# Plugin: datetime

Display current date/time with advanced formatting options and timezone support.

## Screenshot

```
 14:30          # time format
 24/12          # date format
 24/12 14:30    # datetime format (default)
 Tue, 24 Dec 14:30  # full format
 W52 24/12 14:30    # with week number
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, BSD, WSL |
| **Dependencies** | None (uses built-in `date` command) |
| **Content Type** | dynamic |
| **Presence** | always |

## Installation

No dependencies required - uses system `date` command.

## Quick Start

```bash
# Enable plugin
set -g @powerkit_plugins "datetime"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "datetime"

# Format (preset or custom strftime)
set -g @powerkit_plugin_datetime_format "datetime"

# Secondary timezone
set -g @powerkit_plugin_datetime_timezone "America/New_York"

# Show ISO week number
set -g @powerkit_plugin_datetime_show_week "false"

# Separator between elements
set -g @powerkit_plugin_datetime_separator " "

# Icon
set -g @powerkit_plugin_datetime_icon ""

# Cache duration (seconds)
set -g @powerkit_plugin_datetime_cache_ttl "5"

# Only show on threshold (not applicable for datetime - always visible)
set -g @powerkit_plugin_datetime_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_datetime_format` | string | `datetime` | Format preset or custom strftime |
| `@powerkit_plugin_datetime_timezone` | string | `` | Secondary timezone to display (e.g., `America/New_York`) |
| `@powerkit_plugin_datetime_show_week` | bool | `false` | Show ISO week number prefix |
| `@powerkit_plugin_datetime_separator` | string | ` ` | Separator between datetime elements |
| `@powerkit_plugin_datetime_icon` | icon | `` | Plugin icon |
| `@powerkit_plugin_datetime_cache_ttl` | number | `5` | Cache duration in seconds |
| `@powerkit_plugin_datetime_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded (N/A for datetime) |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Always active | Always visible |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Always | Green |

## Context Values

| Context | Description | Time Range |
|---------|-------------|------------|
| `morning` | Morning hours | 06:00 - 11:59 |
| `afternoon` | Afternoon hours | 12:00 - 17:59 |
| `evening` | Evening hours | 18:00 - 21:59 |
| `night` | Night hours | 22:00 - 05:59 |

## Format Presets

### Time Formats

| Preset | Example | Description |
|--------|---------|-------------|
| `time` | `14:30` | 24-hour time |
| `time-seconds` | `14:30:45` | 24-hour with seconds |
| `time-12h` | `02:30 PM` | 12-hour with AM/PM |
| `time-12h-seconds` | `02:30:45 PM` | 12-hour with seconds and AM/PM |

### Date Formats

| Preset | Example | Description |
|--------|---------|-------------|
| `date` | `24/12` | Day/Month (EU format) |
| `date-us` | `12/24` | Month/Day (US format) |
| `date-full` | `24/12/2024` | Full date (EU) |
| `date-full-us` | `12/24/2024` | Full date (US) |
| `date-iso` | `2024-12-24` | ISO 8601 date |

### Combined Formats

| Preset | Example | Description |
|--------|---------|-------------|
| `datetime` | `24/12 14:30` | Date + time (EU, default) |
| `datetime-us` | `12/24 02:30 PM` | Date + time (US 12h) |
| `weekday` | `Tue 14:30` | Short weekday + time |
| `weekday-full` | `Tuesday 14:30` | Full weekday + time |
| `full` | `Tue, 24 Dec 14:30` | Weekday, date, time |
| `full-date` | `Tue, 24 Dec 2024` | Weekday + full date |
| `iso` | `2024-12-24T14:30:45` | ISO 8601 datetime |

## Custom Format

Use any valid strftime format string:

```bash
# Custom format examples
set -g @powerkit_plugin_datetime_format "%Y-%m-%d %H:%M"       # 2024-12-24 14:30
set -g @powerkit_plugin_datetime_format "%A, %B %d"             # Tuesday, December 24
set -g @powerkit_plugin_datetime_format "%I:%M %p"              # 02:30 PM
set -g @powerkit_plugin_datetime_format "%a %d %b %Y %H:%M:%S"  # Tue 24 Dec 2024 14:30:45
```

### Common strftime Specifiers

| Code | Example | Description |
|------|---------|-------------|
| `%Y` | `2024` | Four-digit year |
| `%y` | `24` | Two-digit year |
| `%m` | `12` | Month (01-12) |
| `%B` | `December` | Full month name |
| `%b` | `Dec` | Short month name |
| `%d` | `24` | Day of month (01-31) |
| `%A` | `Tuesday` | Full weekday name |
| `%a` | `Tue` | Short weekday name |
| `%H` | `14` | Hour 24-hour (00-23) |
| `%I` | `02` | Hour 12-hour (01-12) |
| `%M` | `30` | Minute (00-59) |
| `%S` | `45` | Second (00-59) |
| `%p` | `PM` | AM/PM |

## Examples

### Minimal Configuration

```bash
set -g @powerkit_plugins "datetime"
```

### 12-Hour Format

```bash
set -g @powerkit_plugins "datetime"
set -g @powerkit_plugin_datetime_format "time-12h"
```

### ISO Format with Week Number

```bash
set -g @powerkit_plugins "datetime"
set -g @powerkit_plugin_datetime_format "iso"
set -g @powerkit_plugin_datetime_show_week "true"
```

### Multi-Timezone Display

```bash
set -g @powerkit_plugins "datetime"
set -g @powerkit_plugin_datetime_format "time"
set -g @powerkit_plugin_datetime_timezone "America/New_York"
set -g @powerkit_plugin_datetime_separator " | "
```

Output: ` 20:30 | 14:30` (Local | NYC)

### Full Weekday Format

```bash
set -g @powerkit_plugins "datetime"
set -g @powerkit_plugin_datetime_format "full"
```

Output: ` Tue, 24 Dec 14:30`

### Custom Format

```bash
set -g @powerkit_plugins "datetime"
set -g @powerkit_plugin_datetime_format "%H:%M:%S"
```

Output: ` 14:30:45`

## Troubleshooting

### Wrong Timezone

Check your system timezone:
```bash
# View current timezone
date +%Z

# List available timezones
ls /usr/share/zoneinfo/

# Set system timezone (Linux)
sudo timedatectl set-timezone America/New_York

# Set system timezone (macOS)
sudo systemsetup -settimezone America/New_York
```

### Custom Format Not Working

- Verify strftime format syntax is correct
- Test format directly: `date +"your-format"`
- Some format codes may not be supported on all platforms

### Week Number Shows Wrong Value

Different systems use different week numbering standards:
- ISO week (`%V`): Week 01 is the first week with Thursday
- Simple week (`%W`): Week 01 is the first week with Monday
- Plugin attempts `%V` first, falls back to `%W`

## Related Plugins

- [PluginTimezones](PluginTimezones) - Display multiple timezones simultaneously
- [PluginUptime](PluginUptime) - System uptime display
- [PluginPomodoro](PluginPomodoro) - Pomodoro timer
