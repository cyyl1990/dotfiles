# Plugin: weather

Display current weather conditions from Open Meteo with customizable location, units, and format.

## Screenshot

```
☀️ 15°C            # Dynamic icon mode (default)
󰖐 15°C             # Static icon mode
☀️ 15°C Clear      # With condition text
🌧️ 8°C ↗5km/h     # Temperature with wind
❄️ -5°C 65%        # Negative temperature with humidity
```

## Requirements

| Property | Value |
|----------|-------|
| **Platform** | macOS, Linux, BSD, WSL |
| **Dependencies** | `curl` |
| **Content Type** | dynamic |
| **Presence** | conditional |

## Installation

```bash
# macOS (Homebrew)
brew install curl

# Linux (usually pre-installed)
sudo apt install curl      # Debian/Ubuntu
sudo dnf install curl      # Fedora
sudo pacman -S curl        # Arch
```

## Quick Start

```bash
# Enable plugin (auto-detects location)
set -g @powerkit_plugins "weather"
```

## Configuration Example

```bash
# Enable plugin
set -g @powerkit_plugins "weather"

# Location (empty for auto-detect, or city name)
set -g @powerkit_plugin_weather_location ""

# Units: m (metric/Celsius), u (US/Fahrenheit), M (SI/Kelvin)
set -g @powerkit_plugin_weather_units "m"

# Format string (%t=temp, %c=condition icon, %C=condition text, %w=wind, %h=humidity)
set -g @powerkit_plugin_weather_format "%t"

# Language code (optional)
set -g @powerkit_plugin_weather_language ""

# Hide + sign on positive temperatures (default: true)
set -g @powerkit_plugin_weather_hide_plus_sign "true"

# Icon (used when icon_mode is static)
set -g @powerkit_plugin_weather_icon "󰖐"

# Icon mode: static (use icon option) or dynamic (use weather condition symbol from API)
set -g @powerkit_plugin_weather_icon_mode "dynamic"

# Cache duration (seconds) - weather updates slowly
set -g @powerkit_plugin_weather_cache_ttl "1800"

# Only show on threshold (not applicable for weather)
set -g @powerkit_plugin_weather_show_only_on_threshold "false"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_weather_location` | string | `` | Location (city name, empty for auto-detect via IP) |
| `@powerkit_plugin_weather_units` | string | `m` | Units: `m` (metric/°C), `u` (US/°F), `M` (SI/m/s) |
| `@powerkit_plugin_weather_format` | string | `compact` | Format preset or custom string (see Format Presets) |
| `@powerkit_plugin_weather_language` | string | `` | Language code for location names (`pt`, `es`, `fr`, `de`, etc.) |
| `@powerkit_plugin_weather_hide_plus_sign` | bool | `true` | Hide `+` sign on positive temperatures |
| `@powerkit_plugin_weather_icon` | icon | `󰖐` | Plugin icon (used when icon_mode is static) |
| `@powerkit_plugin_weather_icon_mode` | string | `dynamic` | Icon mode: `static` or `dynamic` (weather condition symbol) |
| `@powerkit_plugin_weather_cache_ttl` | number | `1800` | Weather cache duration in seconds (30 min) |
| `@powerkit_plugin_weather_geocoding_cache_ttl` | number | `86400` | Geocoding cache duration in seconds (24 hours) |
| `@powerkit_plugin_weather_max_requests_per_hour` | number | `60` | API rate limiting (safety limit, defaults to 60) |
| `@powerkit_plugin_weather_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded (N/A) |

## Format Presets

| Preset | Resolves To | Example Output |
|--------|-------------|----------------|
| `compact` | `%t %c` | `15°C ☀️` |
| `full` | `%t %c H:%h` | `15°C ☀️ H:65%` |
| `minimal` | `%t` | `15°C` |
| `detailed` | `%l: %t %c` | `London: 15°C ☀️` |
| (custom) | Pass-through | Your custom format |

## Icon Modes

| Mode | Description | Example |
|------|-------------|---------|
| `dynamic` | Uses weather condition symbol from API (☀️, 🌧️, ❄️, etc.) | `☀️ 15°C` |
| `static` | Uses the configured icon option | `󰖐 15°C` |

## States

| State | Condition | Visibility |
|-------|-----------|------------|
| `active` | Weather data fetched successfully | Visible |
| `inactive` | Cannot fetch weather (network/API error) | Hidden |

## Health Levels

| Level | Condition | Color |
|-------|-----------|-------|
| `ok` | Weather data available | Green |

## Context Values

| Context | Description |
|---------|-------------|
| `available` | Weather data successfully retrieved |
| `unavailable` | Network error or API unavailable |

## Format Codes

Open Meteo supports various format codes for customizing weather display:

| Code | Description | Example | Availability |
|------|-------------|---------|--------------|
| `%t` | Temperature with unit | `15°C` | Always available |
| `%c` | Weather condition icon | `☀️` or `🌧️` | Always available |
| `%C` | Weather condition text | `Clear`, `Cloudy` | Always available |
| `%w` | Wind speed and compass direction | `↗5km/h` | Always available |
| `%h` | Humidity percentage | `65%` | Always available |
| `%p` | Precipitation in mm | `0.1mm` | Always available |
| `%l` | Location name | `London, UK` | Always available |
| `%P` | Pressure (hPa) | `1015hPa` | **Not available** |
| `%m` | Moon phase | `🌓` | **Not available** |

### Combining Format Codes

```bash
# Temperature only
set -g @powerkit_plugin_weather_format "%t"
# Output: 15°C

# Temperature with condition
set -g @powerkit_plugin_weather_format "%c %t"
# Output: ☀️ 15°C

# Full weather info
set -g @powerkit_plugin_weather_format "%c %t %C"
# Output: ☀️ 15°C Clear

# Temperature with wind and humidity
set -g @powerkit_plugin_weather_format "%t %w %h"
# Output: 15°C ↗5km/h 65%
```

## Unit Systems

| Unit | Code | Temperature | Wind | Precipitation |
|------|------|-------------|------|---------------|
| Metric | `m` | Celsius (°C) | km/h | mm |
| US/Imperial | `u` | Fahrenheit (°F) | mph | in |
| SI | `M` | Kelvin (K) | m/s | mm |

## Language Support

Open Meteo Geocoding API supports 27+ languages for location names. Weather descriptions use WMO (World Meteorological Organization) codes and are displayed in English.

| Language | Code | Location Names Example |
|----------|------|--------------------------|
| English | `` (default) | `London, United Kingdom` |
| Portuguese | `pt` | `Lisboa, Portugal` |
| Spanish | `es` | `Madrid, España` |
| French | `fr` | `Paris, France` |
| German | `de` | `Berlin, Deutschland` |
| Italian | `it` | `Roma, Italia` |
| Russian | `ru` | `Москва, Россия` |
| Chinese | `zh` | `北京, 中国` |
| Japanese | `ja` | `東京, 日本` |
| Korean | `ko` | `서울, 한국` |
| Arabic | `ar` | `القاهرة, مصر` |
| Turkish | `tr` | `İstanbul, Türkiye` |
| Polish | `pl` | `Warszawa, Polska` |
| Dutch | `nl` | `Amsterdam, Nederland` |
| Swedish | `sv` | `Stockholm, Sverige` |
| Norwegian | `no` | `Oslo, Norge` |
| Danish | `da` | `København, Danmark` |
| Finnish | `fi` | `Helsinki, Suomi` |
| Czech | `cs` | `Praha, Česko` |
| Hungarian | `hu` | `Budapest, Magyarország` |
| Romanian | `ro` | `București, România` |
| Greek | `el` | `Αθήνα, Ελλάδα` |
| Hebrew | `he` | `תל אביב, ישראל` |
| Hindi | `hi` | `दिल्ली, भारत` |
| Thai | `th` | `กรุงเทพ, ไทย` |
| Vietnamese | `vi` | `Hà Nội, Việt Nam` |
| Indonesian | `id` | `Jakarta, Indonesia` |
| Malay | `ms` | `Kuala Lumpur, Malaysia` |

**Note**: Weather descriptions always appear in English (based on WMO weather code standards).

## Examples

### Minimal Configuration (Auto-Detect Location)

```bash
set -g @powerkit_plugins "weather"
```

Output: `☀️ 15°C`

### Specific Location

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_location "London"
```

Output: `☀️ 12°C`

### Fahrenheit Units

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_units "u"
```

Output: `☀️ 59°F`

### Static Icon Mode

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_icon_mode "static"
set -g @powerkit_plugin_weather_icon "󰖐"
```

Output: `󰖐 15°C`

### Show Plus Sign on Positive Temperatures

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_hide_plus_sign "false"
```

Output: `☀️ +15°C`

### With Weather Condition Text

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_format "%t %C"
```

Output: `☀️ 15°C Clear`

### Full Weather Display

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_format "%t %C"
```

Output: `☀️ 15°C Clear`

### With Wind and Humidity

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_format "%t %w %h"
```

Output: `☀️ 15°C ↗5km/h 65%`

### Portuguese Language

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_format "%t %C"
set -g @powerkit_plugin_weather_language "pt"
```

Output: `☀️ 15°C Limpo`

### Frequent Updates

```bash
set -g @powerkit_plugins "weather"
set -g @powerkit_plugin_weather_cache_ttl "900"  # 15 minutes
```

## Location Formats

The location option accepts the following formats:

| Format | Example |
|--------|---------|
| City name | `London` |
| City, State | `Paris, Texas` |
| City, Country | `Paris, France` |
| Empty (auto-detect) | `` |

**Note**: Geocoding is handled automatically via Open Meteo Geocoding API. Location names are converted to coordinates in the background with 24-hour caching.

## Troubleshooting

### Weather Not Showing

1. Check network connectivity:
   ```bash
   curl -I https://api.open-meteo.com/v1/forecast
   ```

2. Verify curl is installed:
   ```bash
   which curl
   curl --version
   ```

3. Test Open Meteo API manually:
   ```bash
   # Auto-detect location based on IP
   curl "https://geocoding-api.open-meteo.com/v1/search?count=1&language=en&format=json"

   # Get weather for a specific location (Paris)
   curl "https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&current=temperature_2m,weather_code,is_day&temperature_unit=celsius"
   ```

### Wrong Location Detected

Auto-detection uses your IP address. To force a specific location:

```bash
set -g @powerkit_plugin_weather_location "Paris, France"
```

The location is geocoded (converted to coordinates) automatically. You can use city names with optional state/country:
- `London`
- `Paris, France`
- `Paris, Texas`

### Slow Loading

Open Meteo typically responds in under 2 seconds. To improve performance:

1. Increase weather cache duration:
   ```bash
   set -g @powerkit_plugin_weather_cache_ttl "3600"  # 1 hour
   ```

2. Increase geocoding cache (locations don't move):
   ```bash
   set -g @powerkit_plugin_weather_geocoding_cache_ttl "604800"  # 7 days
   ```

3. Check your internet connection

### Special Characters Not Displaying

Ensure your terminal supports Unicode and has proper font:
- Use a Nerd Font or font with emoji support
- Check terminal encoding is UTF-8

### API Rate Limiting

Open Meteo is free with no rate limits for reasonable usage. However, the plugin has built-in safety limits:

If you hit rate limits:
- Increase `cache_ttl` to reduce requests
- Adjust `max_requests_per_hour` setting if needed
- Avoid refreshing tmux status too frequently (use `set -g status-interval 30`)

### Timeout Errors

Connection timeout is 5 seconds. If your connection is slow:
- Increase cache TTL to reduce API calls
- Check your internet connection stability
- Try manually testing the API endpoints above

### Missing Weather Data (%P or %m)

Open Meteo does not provide atmospheric pressure or moon phase data. These placeholders will be removed from output:
- Use `%p` for precipitation instead of `%P` for pressure
- Moon phase (%m) is not available

### Location Not Found

If a location isn't found:
1. Try a more specific format: `City, Country` or `City, State, Country`
2. Check spelling and capitalization
3. Try an alternative name for the location
4. Verify the location exists in Open Meteo's database

The plugin caches geocoding results for 24 hours. To clear the cache:
```bash
rm -rf ~/.cache/tmux-powerkit/data/geocode*
```

Then reload tmux:
```bash
tmux source ~/.tmux.conf
```

## Data Source

This plugin uses the [Open Meteo API](https://open-meteo.com/):
- Free and open source
- No API key required
- High-quality weather data
- Supports worldwide locations
- Aggressive caching reduces API calls

### API Endpoints Used

1. **Geocoding API**: Converts location names to coordinates
   - Endpoint: `https://geocoding-api.open-meteo.com/v1/search`
   - Cache: 24 hours (locations don't move)
   - IP-based fallback for auto-detection

2. **Weather API**: Retrieves current weather
   - Endpoint: `https://api.open-meteo.com/v1/forecast`
   - Cache: 30 minutes (configurable)
   - Uses WMO weather code standards

### Performance

- Typical API response time: < 2 seconds
- Geocoding results cached for 24 hours
- Weather results cached for 30 minutes (default)
- Rate limiting: 60 requests per hour (default, adjustable)

## Migration from wttr.in

This plugin was migrated from wttr.in to Open Meteo in January 2025. Key differences:

### Features Maintained

- ✓ Auto-detection of location via IP
- ✓ City name support with intelligent geocoding
- ✓ All format string options (except %P and %m)
- ✓ Multiple unit systems (metric, US, SI)
- ✓ 27+ languages for location names
- ✓ Dynamic weather icons based on WMO codes
- ✓ Caching and rate limiting

### Features No Longer Available

- ✗ Moon phase (%m) - not available in Open Meteo
- ✗ Atmospheric pressure (%P) - not in current API variables
- ✗ Airport codes - only city names accepted

### Improvements

- ✓ Faster response times (typically < 2 seconds)
- ✓ Better geocoding with fallback chain
- ✓ More aggressive caching (24h for locations)
- ✓ No external IP service dependency
- ✓ Built-in rate limiting safety

### Backward Compatibility

All existing configurations continue to work unchanged. The plugin automatically handles location geocoding in the background, so your `@powerkit_plugin_weather_location` settings remain valid.

## Related Plugins

- [PluginDatetime](PluginDatetime) - Date and time display
- [PluginTimezones](PluginTimezones) - Multiple timezone display
- [PluginExternalIp](PluginExternalIp) - Public IP address
