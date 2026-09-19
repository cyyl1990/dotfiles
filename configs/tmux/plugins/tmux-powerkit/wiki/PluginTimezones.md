# Plugin: timezones

Display time in multiple time zones.

## Screenshot

```
󰥔 NYC 09:30 | LON 14:30 | TKY 23:30
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | None (uses TZ environment variable) |
| Content Type | dynamic |
| Presence | always |

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "timezones"
set -g @powerkit_plugin_timezones_zones "America/New_York,Europe/London,Asia/Tokyo"
```

## Configuration Example

```bash
set -g @powerkit_plugins "timezones"

# Timezones to display (comma-separated)
set -g @powerkit_plugin_timezones_zones "America/New_York,Europe/London,Asia/Tokyo"

# Time format (strftime format)
set -g @powerkit_plugin_timezones_format "%H:%M"

# Show 3-letter label
set -g @powerkit_plugin_timezones_show_label "true"

# Separator between timezones
set -g @powerkit_plugin_timezones_separator " | "

# Icon
set -g @powerkit_plugin_timezones_icon "󰥔"

# Cache duration
set -g @powerkit_plugin_timezones_cache_ttl "60"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_timezones_zones` | string | `` | Comma-separated list of timezones |
| `@powerkit_plugin_timezones_format` | string | `%H:%M` | Time format (strftime) |
| `@powerkit_plugin_timezones_show_label` | bool | `true` | Show timezone label |
| `@powerkit_plugin_timezones_separator` | string | ` \| ` | Separator between timezones |
| `@powerkit_plugin_timezones_icon` | icon | `󰥔` | Plugin icon |
| `@powerkit_plugin_timezones_cache_ttl` | number | `60` | Cache duration in seconds |
| `@powerkit_plugin_timezones_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Common Time Formats

| Format | Example | Description |
|--------|---------|-------------|
| `%H:%M` | `14:30` | 24-hour time |
| `%I:%M %p` | `02:30 PM` | 12-hour with AM/PM |
| `%H:%M:%S` | `14:30:45` | With seconds |
| `%a %H:%M` | `Mon 14:30` | With day name |
| `%m/%d %H:%M` | `12/24 14:30` | With date |

## Common Timezones

| Region | Timezone | Label |
|--------|----------|-------|
| **Americas** | | |
| New York | `America/New_York` | NYC |
| Los Angeles | `America/Los_Angeles` | LAX |
| Chicago | `America/Chicago` | CHI |
| Toronto | `America/Toronto` | TOR |
| Sao Paulo | `America/Sao_Paulo` | SAO |
| **Europe** | | |
| London | `Europe/London` | LON |
| Paris | `Europe/Paris` | PAR |
| Berlin | `Europe/Berlin` | BER |
| Amsterdam | `Europe/Amsterdam` | AMS |
| **Asia** | | |
| Tokyo | `Asia/Tokyo` | TKY |
| Shanghai | `Asia/Shanghai` | SHA |
| Singapore | `Asia/Singapore` | SIN |
| Mumbai | `Asia/Kolkata` | MUM |
| Dubai | `Asia/Dubai` | DXB |
| **Pacific** | | |
| Sydney | `Australia/Sydney` | SYD |
| Auckland | `Pacific/Auckland` | AKL |
| **UTC** | | |
| UTC | `UTC` | UTC |

## States

| State | Condition |
|-------|-----------|
| `active` | Zones are configured and displaying |
| `degraded` | No zones configured (needs setup) |
| `inactive` | No timezone data available |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Zones configured and working |
| `error` | No zones configured |

## Context Values

| Context | Condition |
|---------|-----------|
| `configured` | Zones are set up |
| `not_configured` | No zones defined |

## Display Examples

**With labels:**
```
󰥔 NYC 09:30 | LON 14:30 | TKY 23:30
```

**Without labels:**
```
󰥔 09:30 | 14:30 | 23:30
```

**12-hour format:**
```
󰥔 NYC 09:30 AM | LON 02:30 PM | TKY 11:30 PM
```

**With day:**
```
󰥔 Mon 09:30 | Mon 14:30 | Tue 00:30
```

## Label Generation

When `show_label` is enabled, the plugin extracts the city name from the timezone and shows the first 3 characters in uppercase:
- `America/New_York` -> `NEW`
- `Europe/London` -> `LON`
- `Asia/Tokyo` -> `TOK`

## Use Cases

### Remote Team Coordination
```bash
# Show team member locations
set -g @powerkit_plugin_timezones_zones "America/New_York,Europe/London,Asia/Kolkata"
set -g @powerkit_plugin_timezones_show_label "true"
```

### Market Hours
```bash
# Show financial market times
set -g @powerkit_plugin_timezones_zones "America/New_York,Europe/London,Asia/Tokyo,Asia/Hong_Kong"
set -g @powerkit_plugin_timezones_format "%H:%M"
```

### Travel Planning
```bash
# Show home and destination times
set -g @powerkit_plugin_timezones_zones "America/Los_Angeles,Europe/Paris"
set -g @powerkit_plugin_timezones_show_label "true"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Wrong time shown | Verify timezone string is correct (case-sensitive) |
| Plugin not showing | Ensure `zones` option is set |
| Format not working | Check strftime format syntax |
| Label wrong | Label is auto-generated from city name |

## Finding Timezone Names

```bash
# List all available timezones
timedatectl list-timezones        # Linux
ls /usr/share/zoneinfo            # macOS/Linux

# Current timezone
date +%Z
```

## Related Plugins

- [PluginDatetime](PluginDatetime) - Local date and time
