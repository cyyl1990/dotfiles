# Architecture

PowerKit uses a contract-based architecture with strict separation of concerns.

## Design Principles

1. **Separation of Concerns**: Data collection is separate from visual presentation
2. **Contract-Based**: All components follow defined contracts
3. **Plugin Independence**: Plugins don't know about each other
4. **Theme Independence**: Themes only define colors, not logic
5. **Renderer Ownership**: Only the renderer decides visual presentation

## Runtime Requirements

PowerKit requires **Bash 5.0+** (5.1+ recommended) for optimal performance.

### Bash Features Used

| Version | Features | Usage |
|---------|----------|-------|
| **5.0+** (required) | `$EPOCHSECONDS`, `$EPOCHREALTIME` | Eliminates external `date +%s` calls |
| **5.0+** (required) | `${var,,}`, `${var^^}` | Case conversion without `tr` |
| **5.1+** (recommended) | `assoc_expand_once` | Optimizes associative array access |

### Performance Impact

The Bash 5.0+ features eliminate numerous external process calls:

| Feature | Before | After |
|---------|--------|-------|
| Timestamp | `$(date +%s)` | `$EPOCHSECONDS` |
| High-res time | `$(date +%s%N)` | `$EPOCHREALTIME` |
| Lowercase | `$(echo "$var" \| tr '[:upper:]' '[:lower:]')` | `${var,,}` |
| Uppercase | `$(echo "$var" \| tr '[:lower:]' '[:upper:]')` | `${var^^}` |

### Bash 5.1 Optimization

When Bash 5.1+ is detected, PowerKit enables `assoc_expand_once` to prevent double expansion of associative array keys, improving performance in hot paths like cache lookups and plugin lifecycle.

```bash
# Enabled automatically in bootstrap.sh when Bash 5.1+ is detected
shopt -s assoc_expand_once
```

## Module Structure

```
src/
├── core/           # Core framework
├── contract/       # Contract definitions
│   ├── plugin_contract.sh   # Plugin interface
│   ├── session_contract.sh  # Session interface
│   ├── window_contract.sh   # Window interface
│   ├── pane_contract.sh     # Pane interface (borders, flash, sync)
│   ├── theme_contract.sh    # Theme interface
│   └── helper_contract.sh   # Helper interface
├── renderer/       # Visual rendering
│   ├── entities/   # Entity renderers (session, windows, plugins)
│   ├── compositor.sh     # Layout composition
│   ├── styles.sh         # Message styles
│   ├── separator.sh      # Powerline separators
│   ├── segment_builder.sh # Plugin segments
│   └── color_resolver.sh  # Color resolution
├── plugins/        # Status bar plugins
├── helpers/        # Interactive UI helpers
├── themes/         # Color definitions
└── utils/          # Utility functions
    ├── platform.sh       # OS/distro detection
    ├── strings.sh        # String manipulation
    ├── numbers.sh        # Numeric utilities
    ├── filesystem.sh     # File operations
    ├── hooks.sh          # Tmux hooks management
    └── ...
```

## Component Responsibilities

### Core (`src/core/`)

Orchestration and infrastructure:
- **bootstrap.sh**: Module loading and initialization
- **lifecycle.sh**: Plugin lifecycle phases
- **datastore.sh**: Plugin data storage
- **cache.sh**: TTL-based caching
- **options.sh**: Option management
- **logger.sh**: Logging system
- **binary_manager.sh**: macOS native binary download manager

### Plugins (`src/plugins/`)

Data collection and semantics:
- Collect data via `plugin_data_set()`
- Report state: `inactive|active|degraded|failed`
- Report health: `ok|good|info|warning|error`
- Return plain text in `plugin_render()`
- **Never** decide colors or formatting

### Renderer (`src/renderer/`)

Visual presentation:
- Resolve colors based on state/health
- Build segments with separators
- Apply tmux formatting codes
- **Never** collect data or run commands

#### Entity-Based Architecture

The renderer uses an entity-based architecture where each status bar component is an independent entity:

| Entity | Location | Responsibility |
|--------|----------|----------------|
| **session** | `entities/session.sh` | Session indicator (icon + name) |
| **windows** | `entities/windows.sh` | Window list formatting |
| **plugins** | `entities/plugins.sh` | Plugin segments (delegates to segment_builder) |

Each entity implements:
- `{entity}_render(side)` - Returns formatted content
- `{entity}_get_bg()` - Returns background color for separator transitions

#### Compositor

The compositor (`compositor.sh`) orchestrates entity placement:
- Reads `@powerkit_bar_layout` (single/double)
- Reads `@powerkit_status_order` (session,plugins or plugins,session)
- Calls each entity's render function
- Inserts separators between entities
- Applies final layout to tmux

#### Key Modules

| Module | Purpose |
|--------|---------|
| `renderer.sh` | High-level orchestration |
| `compositor.sh` | Layout composition |
| `styles.sh` | Pane borders, messages, clock |
| `segment_builder.sh` | Plugin segment building |
| `separator.sh` | Powerline separator glyphs |
| `color_resolver.sh` | State/health to color mapping |

### Themes (`src/themes/`)

Color definitions only:
- Declare 22 base colors
- Auto-generated variants (lighter/darker)
- **Never** contain logic or functions

## Data Flow

```
Bootstrap → Discover Plugins → Load Options
     ↓
For each plugin:
     ↓
plugin_collect() → plugin_data_set()
     ↓
plugin_get_state() + plugin_get_health()
     ↓
Lifecycle: Output format (5 fields)
  icon<US>content<US>state<US>health<US>stale
     ↓
Renderer: resolve_plugin_colors_full(state, health, context, stale)
  - If stale=1: Apply -darker variant to backgrounds
     ↓
plugin_render() → text only
     ↓
Renderer: build_segment(text, colors, icon)
     ↓
Output: #[fg=...,bg=...]text
```

### Stale Data Indication

The lifecycle tracks data freshness and marks output with a `stale` flag (5th field):

| Field | Value | Meaning |
|-------|-------|---------|
| `stale` | `0` | Fresh data (normal colors) |
| `stale` | `1` | Cached/stale data (darker colors) |

When `stale=1`, the renderer applies `@powerkit_stale_color_variant` (default: `-darker`) to background colors, providing visual feedback that cached data is displayed.

## Plugin Lifecycle

1. **BOOTSTRAP**: Load core modules
2. **DISCOVER**: Parse `@powerkit_plugins`
3. **VALIDATE**: Check contract compliance
4. **INITIALIZE**: Call `declare_options`, `setup_keybindings`
5. **COLLECT**: Cache check → `plugin_check_dependencies()` → `plugin_collect()` → store data
6. **RESOLVE**: Get state/health/context
7. **RENDER**: Build segments with colors/icons
8. **OUTPUT**: Apply to tmux status bar

## macOS Binary System

Some plugins require native macOS binaries for hardware access. These binaries are **not in the repository** - they are downloaded on-demand from GitHub releases.

### Flow

```
Plugin startup:
  plugin_check_dependencies()
       ↓
  require_macos_binary("powerkit-gpu", "gpu")
       ↓
  Binary exists? → Yes → Continue
       ↓ No
  Track in _MISSING_BINARIES_FILE
       ↓
After all plugins collected:
  binary_prompt_missing()
       ↓
  Show single popup with all missing binaries
       ↓
  User chooses: Yes/Select/No
       ↓
  Download from GitHub releases
       ↓
  Store decision in cache (24h TTL)
```

### Affected Plugins

| Plugin | Binary | Purpose |
|--------|--------|---------|
| gpu | `powerkit-gpu` | GPU utilization via IOKit |
| temperature | `powerkit-temperature` | CPU temp via SMC |
| microphone | `powerkit-microphone` | Mic mute via CoreAudio |
| nowplaying | `powerkit-nowplaying` | Media info via ScriptingBridge |
| brightness | `powerkit-brightness` | Brightness via DisplayServices |

See [macOS Binaries](MacOSBinaries) for detailed documentation.

## Color Resolution

```
Plugin reports:
  state="active", health="warning"
          ↓
color_palette.sh:
  health="warning" → base="warning-base"
          ↓
color_generator.sh:
  content_bg = warning-base
  icon_bg = warning-base-lighter
  content_fg = warning-base-darkest
          ↓
segment_builder.sh:
  #[fg=#...,bg=#...]icon #[fg=#...,bg=#...]text
```

## Caching Strategy

PowerKit uses a multi-layer caching system:

- **Per-cycle memory cache**: In-memory for single render cycle (fastest)
- **Plugin render cache**: Per-plugin TTL, typically 5-60 seconds
- **Operation cache**: Plugin-specific for expensive operations (e.g., 1 hour for `packages`)
- **Theme cache**: 24 hours for computed theme colors

See [Caching System](Caching) for detailed documentation.

## Related

- [Plugin Contract](ContractPlugin) - Plugin interface
- [Session Contract](ContractSession) - Session interface
- [Window Contract](ContractWindow) - Window interface
- [Pane Contract](ContractPane) - Pane interface (borders, flash, sync)
- [Theme Contract](ContractTheme) - Theme interface
- [Developing Plugins](DevelopingPlugins) - Create plugins
- [Caching System](Caching) - Cache architecture and optimization
- [macOS Binaries](MacOSBinaries) - Native binary download system
