# Caching System

PowerKit uses a multi-layer caching system to optimize performance while ensuring data freshness.

## Overview

The status bar renders every few seconds (configured by `status-interval`). Without caching, each render would:
- Source 42+ plugin files
- Execute external commands (brew, curl, kubectl, etc.)
- Parse and process output

The caching system reduces this overhead by storing computed data and checking cache validity before performing expensive operations.

## Cache Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Render Cycle                           │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────────┐                                      │
│  │  Memory Cache     │ ← Per-cycle (fastest, no disk I/O)   │
│  │  _MEMORY_CACHE[]  │                                      │
│  └─────────┬─────────┘                                      │
│            │ miss                                           │
│            ▼                                                │
│  ┌───────────────────┐                                      │
│  │  Render Cache     │ ← Per-plugin TTL (disk-backed)       │
│  │  plugin_*_data    │                                      │
│  └─────────┬─────────┘                                      │
│            │ miss                                           │
│            ▼                                                │
│  ┌───────────────────┐                                      │
│  │  Operation Cache  │ ← Plugin-specific (long TTL)         │
│  │  (e.g., packages) │                                      │
│  └─────────┬─────────┘                                      │
│            │ miss                                           │
│            ▼                                                │
│  ┌───────────────────┐                                      │
│  │  External Command │ ← Actual execution                   │
│  │  (brew, curl...)  │                                      │
│  └───────────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
```

## Cache Layers

### Layer 1: Per-Cycle Memory Cache

**Purpose**: Avoid disk reads within a single render cycle.

**TTL**: Current render cycle only (reset at start of each render).

**Implementation**: In-memory associative array `_MEMORY_CACHE`.

```bash
# Called at start of each render in powerkit-render
cache_reset_cycle

# Internally, this resets:
_CYCLE_TIMESTAMP=0   # Forces new timestamp
_MEMORY_CACHE=()     # Clears memory cache
```

**How it works**:
1. First access to a cache key reads from disk and stores in memory
2. Subsequent accesses in the same cycle return memory value
3. Memory cache is cleared at start of next render cycle

### Layer 2: Plugin Render Cache

**Purpose**: Cache plugin output data between render cycles.

**TTL**: Per-plugin, typically 5-60 seconds (configurable via `cache_ttl` option).

**Cache Key**: `plugin_<name>_data`

**Data Format**: `icon<US>content<US>state<US>health` (US = Unit Separator, ASCII 31)

```bash
# Plugin declares its cache TTL
plugin_declare_options() {
    declare_option "cache_ttl" "number" "30" "Cache duration in seconds"
}

# Lifecycle checks cache BEFORE sourcing plugin
collect_plugin_render_data() {
    local cache_key="plugin_${name}_data"
    local ttl=$(get_option "cache_ttl")

    # Check cache first - if valid, skip plugin sourcing entirely
    cached_data=$(cache_get "$cache_key" "$ttl")
    if [[ -n "$cached_data" ]]; then
        printf '%s' "$cached_data"
        return 0
    fi

    # Cache miss - source plugin and collect fresh data
    . "$plugin_file"
    plugin_collect
    # ... store in cache
}
```

**Performance Optimization**: The TTL value itself is cached (`plugin_<name>_ttl`) with a 24-hour TTL. This allows checking cache validity without sourcing the plugin file.

### Layer 3: Plugin-Specific Operation Cache

**Purpose**: Cache results of expensive operations separately from render data.

**TTL**: Long (e.g., 1 hour for `packages`).

**Use Case**: Operations like `brew outdated` take 2-5 seconds. Running this every render cycle would be unacceptable.

**Example (packages plugin)**:

```bash
plugin_declare_options() {
    # Short TTL for render cache (allows frequent invalidation checks)
    declare_option "cache_ttl" "number" "60" "Render cache duration"

    # Long TTL for expensive brew outdated operation
    declare_option "packages_cache_ttl" "number" "3600" "Package check cache"
}

plugin_collect() {
    # Check if packages were upgraded (invalidates cache)
    _invalidate_if_upgraded "$backend"

    # Try long-TTL cache first
    packages_cache_ttl=$(get_option "packages_cache_ttl")
    cached=$(cache_get "$_PACKAGES_CACHE_KEY" "$packages_cache_ttl")

    if [[ -n "$cached" ]]; then
        plugin_data_set "update_count" "$cached"
        return 0
    fi

    # Cache miss - run expensive operation
    count=$(_count_updates_brew)  # 2-5 seconds
    cache_set "$_PACKAGES_CACHE_KEY" "$count"
    plugin_data_set "update_count" "$count"
}
```

### Layer 4: Rendered Output Cache

**Purpose**: Cache the final rendered status bar output for instant display.

**TTL**: Matches `status-interval` (default: 5 seconds).

**Cache Key**: `rendered_<side>` (e.g., `rendered_right`)

**How it works**:
1. When tmux calls `#(powerkit-render)`, check if rendered output is cached
2. If cached and fresh → return immediately (prevents "not ready" message)
3. If stale or missing → show loading placeholder, render in background
4. Background render updates cache for next cycle

This prevents the tmux "not ready" message that appears when `#()` commands take too long to execute.

### Layer 5: Theme Color Cache

**Purpose**: Cache computed theme colors with variants.

**TTL**: 24 hours.

**Cache Key**: `theme_colors__<theme>__<variant>` (e.g., `theme_colors__tokyo-night__night`)

**Contains**: All 22 base colors + 6 variants per color (132 total values).

```bash
# Theme loading checks cache first
load_theme() {
    local cache_key="theme_colors__${theme}__${variant}"

    if cached=$(cache_get "$cache_key" 86400); then
        deserialize_theme_colors "$cached"
        return 0
    fi

    # Cache miss - load theme file and generate variants
    . "$theme_file"
    generate_color_variants

    # Cache for 24 hours
    cache_set "$cache_key" "$(serialize_theme_colors)"
}
```

## Lazy Loading (Stale-While-Revalidate)

PowerKit implements a **Stale-While-Revalidate** strategy for plugin data collection. This ensures the status bar never blocks waiting for slow operations like API calls or external commands.

### How It Works

```
                    Cache Age
    ├────────────────┼────────────────┼────────────────┤
    0               TTL            TTL×3            ∞
    │                │                │                │
    │   FRESH        │    STALE       │   VERY OLD     │
    │   (return)     │ (return+bg)    │   (block)      │
    │                │                │                │
```

| State | Condition | Behavior | Visual |
|-------|-----------|----------|--------|
| **FRESH** | age ≤ TTL | Return cached data immediately | Normal colors |
| **STALE WINDOW** | TTL < age ≤ TTL×3 | Return cache + spawn background refresh | Normal colors |
| **VERY OLD** | age > TTL×3 | Synchronous (blocking) refresh | Normal colors |
| **MISSING** | No cache | Synchronous (blocking) refresh | Loading placeholder |
| **COLLECTION FAILED** | API/command failed | Return previous cache | `-darker` colors |

**Note:** The visual stale indicator (`-darker` colors) is **only** shown when collection actually fails, not during normal cache aging. This prevents plugins from constantly appearing "stale" when their TTL is close to the tmux `status-interval`.

### Why TTL×3?

- **TTL** = ideal refresh interval (e.g., 300s for weather)
- **TTL×3** = maximum acceptable staleness (e.g., 900s)
- Ensures data eventually refreshes even if background tasks fail

### Configuration

```bash
# Enable/disable lazy loading (default: true)
set -g @powerkit_lazy_loading "true"

# Stale multiplier (default: 3)
set -g @powerkit_stale_multiplier "3"

# Visual stale indicator color variant (default: -darker)
# Applied to background colors when displaying stale data
# Options: -darker, -darkest, -lighter, -lightest
set -g @powerkit_stale_color_variant "-darkest"
```

### Visual Stale Indication

PowerKit provides visual feedback (darker colors) **only when data collection actually fails**, not during normal cache aging. This is an important architectural distinction:

- **Normal aging**: Cache is older than TTL but background refresh is working → Normal colors
- **Collection failure**: API timeout, command error, network issue → Darker colors

**When stale indicator appears:**

1. `plugin_collect()` returns non-zero (failure)
2. Lifecycle preserves previous cache but marks output with `stale=1`
3. Renderer applies `@powerkit_stale_color_variant` (default: `-darker`) to backgrounds
4. User sees slightly dimmer colors, indicating a problem occurred

**Lifecycle Output Format:**

```
icon<US>content<US>state<US>health<US>stale
```

Where:
- `<US>` = Unit Separator (ASCII 31, `\x1f`)
- `stale` = `0` (fresh) or `1` (stale/cached)

**When stale=1 is set:**

- `plugin_collect()` returned non-zero (failure)
- Previous valid cache exists and is within stale window (TTL×3)
- Examples: API timeout, command error, network unreachable

**When stale=1 is NOT set:**

- Normal cache aging (TTL < age ≤ TTL×3) with successful background refresh
- Fresh data (age ≤ TTL)
- Synchronous collection (very old or missing cache)

**Color transformation:**

```
Normal (stale=0):
  content_bg: ok-base (#9ece6a)
  icon_bg: ok-base-lighter (#b0e08a)

Stale (stale=1):
  content_bg: ok-base-darker (#7ca555)
  icon_bg: ok-base-darker (#7ca555)
```

This provides subtle visual feedback without disrupting the status bar appearance.

### Performance Impact

| Scenario | Time | Behavior |
|----------|------|----------|
| FRESH cache | ~20ms | Instant return |
| STALE cache | ~40ms | Return stale + background refresh |
| MISSING/VERY OLD | 5-30s | Blocks (only on first load or very old data) |

### Loading Placeholder

When no cached data is available (first startup or after cache clear), PowerKit shows an animated loading placeholder:

```
 Loading...
```

The loading placeholder:
- Uses theme colors (respects your selected theme)
- Displays animated spinner
- Uses configured edge separator style

### Background Refresh

Background refresh uses lock files to prevent concurrent refreshes:

```bash
# Lock files are stored alongside cache
~/.cache/tmux-powerkit/data/.lock_plugin_<name>

# Lock timeout: 60 seconds (stale locks are automatically cleaned)
```

---

## Cache Location

All cache files are stored in:

```
~/.cache/tmux-powerkit/data/
```

Or if `$XDG_CACHE_HOME` is set:

```
$XDG_CACHE_HOME/tmux-powerkit/data/
```

## Cache Invalidation

### Time-Based (TTL)

Most common invalidation method. Each cache entry has a TTL, and entries older than TTL are considered invalid.

```bash
# Check if cache is still valid
cache_valid "key" 60  # Returns 0 if age < 60 seconds

# Get cached value only if valid
cache_get "key" 60    # Returns value or empty string
```

### Event-Based

Some plugins need to invalidate cache based on external events.

**Example (packages plugin)**: Detects when `brew upgrade` was run by monitoring filesystem modification times.

```bash
_invalidate_if_upgraded() {
    local backend="$1"

    # For brew: check Cellar/linked directory modification time
    local brew_prefix="$(brew --prefix)"
    local log_file="$brew_prefix/var/homebrew/linked"

    # Get log modification time
    local log_mtime=$(stat -f %m "$log_file")

    # Get cache age
    local cache_age=$(cache_age "$_PACKAGES_CACHE_KEY")

    # If log was modified after cache was created, invalidate
    if (( log_age < cache_age )); then
        cache_clear "$_PACKAGES_CACHE_KEY"
        cache_clear "plugin_packages_data"
    fi
}
```

### Manual Invalidation

Users can clear cache manually:

```bash
# Clear all cache
Prefix + <cache_clear_key>  # Default: Ctrl+d

# Or via command line
rm -rf ~/.cache/tmux-powerkit/data/*
tmux refresh-client
```

## Cache API

### Core Functions

| Function | Description |
|----------|-------------|
| `cache_get "key" "ttl"` | Get value if age < TTL |
| `cache_set "key" "value"` | Store value |
| `cache_valid "key" "ttl"` | Check if entry is valid |
| `cache_age "key"` | Get age in seconds |
| `cache_clear "key"` | Remove specific entry |
| `cache_clear_prefix "prefix"` | Remove entries by prefix |
| `cache_clear_all` | Remove all entries |
| `cache_reset_cycle` | Reset per-render memory cache |

### Helper Functions

| Function | Description |
|----------|-------------|
| `cache_get_or_compute "key" "ttl" cmd args...` | Get cached or compute |
| `cache_list` | Debug: list all entries with ages |
| `get_cache_dir` | Get cache directory path |

## Performance Tips

### For Plugin Developers

1. **Set appropriate `cache_ttl`**:
   - Static data (hostname): 300-600 seconds
   - Slow-changing data (battery): 30-60 seconds
   - Fast-changing data (CPU): 5-10 seconds

2. **Use separate caches for expensive operations**:
   ```bash
   # Bad: Single cache for everything
   plugin_collect() {
       expensive_operation  # Runs every cache_ttl seconds
   }

   # Good: Separate cache for expensive operation
   plugin_collect() {
       cached=$(cache_get "expensive_data" 3600)
       if [[ -n "$cached" ]]; then
           plugin_data_set "data" "$cached"
           return 0
       fi
       # ... run expensive operation rarely
   }
   ```

3. **Implement invalidation triggers**:
   ```bash
   # Detect when state changed externally
   _check_if_changed() {
       local current_state=$(quick_state_check)
       local cached_state=$(cache_get "last_state" 86400)
       if [[ "$current_state" != "$cached_state" ]]; then
           cache_clear "expensive_data"
       fi
       cache_set "last_state" "$current_state"
   }
   ```

### For Users

1. **Adjust `status-interval`** in tmux.conf:
   ```bash
   # Default is 15 seconds, can increase for slower updates
   set -g status-interval 5
   ```

2. **Clear cache after configuration changes**:
   ```bash
   # After modifying plugin options
   rm -rf ~/.cache/tmux-powerkit/data/plugin_*
   tmux refresh-client
   ```

3. **Monitor cache for debugging**:
   ```bash
   # List all cache entries
   ls -la ~/.cache/tmux-powerkit/data/

   # Watch cache updates
   watch -n1 'ls -la ~/.cache/tmux-powerkit/data/ | tail -20'
   ```

## Configuration Options

### Global

| Option | Default | Description |
|--------|---------|-------------|
| `@powerkit_cache_clear_key` | `C-d` | Keybinding to clear all cache |

### Per-Plugin

| Option | Default | Description |
|--------|---------|-------------|
| `cache_ttl` | `30` | Render cache TTL in seconds |

Some plugins have additional cache options:
- `packages`: `packages_cache_ttl` (default: 3600)
- `kubernetes`: `connectivity_cache_ttl` (default: 120)

## Troubleshooting

### Plugin shows stale data

1. Clear the plugin's cache:
   ```bash
   rm ~/.cache/tmux-powerkit/data/plugin_<name>_*
   tmux refresh-client
   ```

2. Check if plugin has event-based invalidation (e.g., `packages` should detect `brew upgrade`)

3. Reduce `cache_ttl` in tmux.conf:
   ```bash
   set -g @powerkit_plugin_<name>_cache_ttl "10"
   ```

### Status bar is slow

1. Check which plugins are slow:
   ```bash
   time POWERKIT_ROOT=/path/to/tmux-powerkit ./bin/powerkit-render
   ```

2. Increase cache TTL for slow plugins

3. Disable plugins you don't need

### Cache files growing large

Cache files are small (typically < 1KB each). If growing large:

```bash
# Check cache size
du -sh ~/.cache/tmux-powerkit/

# Clear and let rebuild
rm -rf ~/.cache/tmux-powerkit/data/*
```

## Related

- [Architecture](Architecture) - System overview
- [Developing Plugins](DevelopingPlugins) - Plugin development guide
- [Configuration](Configuration) - Configuration options
- [Troubleshooting](Troubleshooting) - Common issues
