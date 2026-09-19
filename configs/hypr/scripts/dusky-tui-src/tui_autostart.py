#!/usr/bin/env python3

import sys
from pathlib import Path

_dusky_root = Path.home() / ".config" / "hypr" / "scripts" / "dusky_tui"
if str(_dusky_root) not in sys.path:
    sys.path.insert(0, str(_dusky_root))

import sys
from pathlib import Path

_DUSKY_TUI_ROOT = Path.home() / ".config" / "hypr" / "scripts" / "dusky_tui"
if str(_DUSKY_TUI_ROOT) not in sys.path:
    sys.path.insert(0, str(_DUSKY_TUI_ROOT))

from python.frontend.core_types import ConfigItem

# =============================================================================
# 1. CORE APPLICATION ROUTING
# =============================================================================
ENGINE_TYPE = "lua"
TARGET_FILE = "~/.config/hypr/autostart.lua"
APP_TITLE = "Autostart & Services"

# =============================================================================
# 2. UI & ENVIRONMENT BEHAVIOR
# =============================================================================
DEFAULT_MODE = "auto"
THEME_FILE = "~/.local/state/omarchy/current/theme/colors.toml"
ENABLE_USER_PRESETS = True
USER_PRESETS_TAB = "Profiles"

# =============================================================================
# 3. TABS DEFINITION
# =============================================================================
TABS = [
    "System",
    "Utilities",
    "Profiles"
]

# =============================================================================
# 4. SCHEMA DEFINITION
# =============================================================================
SCHEMA = {
    # -------------------------------------------------------------------------
    # TAB 0: System Configuration (AST mapped natively to hl.config)
    # -------------------------------------------------------------------------
    0: [
        ConfigItem(
            label="Enable XWayland Subsystem",
            key="enabled",
            scope="xwayland",       # Maps to hl.config({ xwayland = { enabled = ... } })
            type_="bool",
            default=True,
            group="Compatibility",
            extended_help="**XWayland Support**\n\nToggles the XWayland translation layer globally. \n\n- **ON**: Better compatibility for older X11 applications.\n- **OFF**: Disables the layer to save 20-30 MB of RAM, but strictly prevents non-Wayland applications from functioning."
        ),
    ],

    # -------------------------------------------------------------------------
    # TAB 1: Utility Actions (Omarchy Services & Diagnostics)
    # -------------------------------------------------------------------------
    1: [
        # --- INTERFACE: Omarchy Shell ---
        ConfigItem(
            label="Launch / Reload Omarchy Shell",
            key="action_reload_shell",
            scope="DEFAULT",
            type_="action",
            default="omarchy-restart-shell",
            group="Interface",
            extended_help="**Omarchy Shell Controller**\n\nRestarts the Quickshell-based Omarchy shell (bar, quick settings, lock screen). Use this if the bar crashes or you changed shell configuration without a full restart."
        ),
        ConfigItem(
            label="Toggle Bar Visibility",
            key="action_toggle_bar",
            scope="DEFAULT",
            type_="action",
            default="omarchy-toggle-bar",
            group="Interface",
            extended_help="**Bar Visibility**\n\nShows or hides the Omarchy status bar without killing the shell."
        ),

        # --- WALLPAPER: Wallpaper Engine ---
        ConfigItem(
            label="Start Live Wallpaper",
            key="action_we_launch",
            scope="DEFAULT",
            type_="action",
            default="omarchy-we launch",
            group="Wallpaper",
            extended_help="**Wallpaper Engine**\n\n(Re)launches the saved live wallpaper via linux-wallpaperengine (`omarchy-we`)."
        ),
        ConfigItem(
            label="Next Wallpaper",
            key="action_we_next",
            scope="DEFAULT",
            type_="action",
            default="omarchy-we next",
            group="Wallpaper",
            extended_help="**Next Wallpaper**\n\nCycles to the next wallpaper in the Wallpaper Engine collection."
        ),

        # --- MONITORS: Omarchy System Glances ---
        ConfigItem(
            label="System Stats",
            key="action_system_stats",
            scope="DEFAULT",
            type_="action",
            default="omarchy-system-stats",
            group="Monitors",
            extended_help="**System Stats**\n\nPrints current CPU and memory statistics for the system."
        ),
        ConfigItem(
            label="Network Status",
            key="action_network_status",
            scope="DEFAULT",
            type_="action",
            default="omarchy-network-status",
            group="Monitors",
            extended_help="**Network Status**\n\nDisplays active network connections, IP addresses, and link state."
        ),
        ConfigItem(
            label="Drive Info",
            key="action_drive_info",
            scope="DEFAULT",
            type_="action",
            default="omarchy-drive-info",
            group="Monitors",
            extended_help="**Drive Info**\n\nShows storage devices, mount points, and free space."
        ),
        ConfigItem(
            label="Battery Status",
            key="action_battery_status",
            scope="DEFAULT",
            type_="action",
            default="omarchy-battery-status",
            group="Monitors",
            extended_help="**Battery Status**\n\nDisplays battery charge state, capacity, and health."
        ),
        ConfigItem(
            label="Weather",
            key="action_weather_status",
            scope="DEFAULT",
            type_="action",
            default="omarchy-weather-status",
            group="Monitors",
            extended_help="**Weather**\n\nShows current weather for the configured location."
        ),
        ConfigItem(
            label="System Monitor (btop)",
            key="action_monitor_btop",
            scope="DEFAULT",
            type_="action",
            default="omarchy-launch-or-focus-tui btop",
            group="Monitors",
            extended_help="**System Monitor**\n\nLaunches btop (or focuses an existing instance) for real-time CPU, memory, and process monitoring."
        ),

        # --- SERVICES ---
        ConfigItem(
            label="Start Network Applet",
            key="action_nm_applet",
            scope="DEFAULT",
            type_="action",
            default="nm-applet",
            group="Services",
            extended_help="**Network Manager Applet**\n\nManually starts the nm-applet tray icon for managing Wi-Fi and network connections."
        ),
        ConfigItem(
            label="Start Gnome Keyring Daemon",
            key="action_gnome_keyring",
            scope="DEFAULT",
            type_="action",
            default="/usr/bin/gnome-keyring-daemon --start --components=secrets",
            group="Services",
            extended_help="**Gnome Keyring**\n\nManually launches the Gnome Keyring daemon. This securely stores credentials and passwords for applications like VSCode, Chrome, and Nextcloud."
        ),
        ConfigItem(
            label="Toggle Stay Awake / Idle",
            key="action_toggle_idle",
            scope="DEFAULT",
            type_="action",
            default="omarchy-toggle-idle",
            group="Services",
            extended_help="**Idle Toggle**\n\nSwitches between normal idle behavior (allow lock & screensaver) and a stay-awake state that prevents the screen from locking while active."
        ),

        # --- CLIPBOARD ---
        ConfigItem(
            label="Open Clipboard History",
            key="action_open_clipboard",
            scope="DEFAULT",
            type_="action",
            default="omarchy-menu-clipboard",
            group="Clipboard",
            extended_help="**Clipboard History**\n\nOpens the Omarchy clipboard history picker with recently copied text and images."
        ),

        # --- ENVIRONMENT ---
        ConfigItem(
            label="Update Systemd Environment",
            key="action_systemd_env",
            scope="DEFAULT",
            type_="action",
            default="systemctl --user import-environment $(env | cut -d'=' -f 1)",
            group="Environment",
            extended_help="**Systemd Environment**\n\nImports current environment variables into systemd. Useful for fixing slow app launches (like XDPH)."
        ),
        ConfigItem(
            label="Update DBus Environment",
            key="action_dbus_env",
            scope="DEFAULT",
            type_="action",
            default="dbus-update-activation-environment --systemd --all",
            group="Environment",
            extended_help="**DBus Environment**\n\nUpdates DBus activation environment with all systemd variables."
        ),

        # --- REFERENCE ---
        ConfigItem(
            label="Keybindings",
            key="action_keybindings",
            scope="DEFAULT",
            type_="action",
            default="omarchy-menu-keybindings",
            group="Reference",
            extended_help="**Keybindings Reference**\n\nOpens the Omarchy keybinding overview menu."
        ),
    ],

    # -------------------------------------------------------------------------
    # TAB 2: Profiles (System Presets)
    # -------------------------------------------------------------------------
    2: [
        ConfigItem(
            label="Deploy Lightweight Mode",
            key="preset_lightweight_mode",
            scope="DEFAULT",
            type_="preset",
            default=None,
            group="Optimization",
            preset_payload={
                "xwayland.enabled": False
            },
            extended_help="**Lightweight Preset**\n\nOptimizes RAM usage by aggressively disabling the XWayland compatibility layer. \n\n⚠️ Ensure you are only running native Wayland applications before applying this profile."
        ),
        ConfigItem(
            label="Restore Standard Defaults",
            key="preset_restore_defaults",
            scope="DEFAULT",
            type_="preset",
            default=None,
            group="Optimization",
            preset_payload={
                "xwayland.enabled": True
            },
            extended_help="**Standard Defaults**\n\nRe-enables the XWayland compatibility layer, reverting the system back to maximum application compatibility."
        ),
    ]
}

# =============================================================================
# DIRECT EXECUTION HANDLER
# =============================================================================
if __name__ == "__main__":
    import sys, subprocess
    from pathlib import Path

    script_path = Path(__file__).resolve()
    main_router = Path.home() / ".config" / "hypr" / "scripts" / "dusky_tui" / "python" / "main" / "main.py"

    if main_router.exists():
        sys.exit(subprocess.run([sys.executable, str(main_router), str(script_path)] + sys.argv[1:]).returncode)
    else:
        print(f"[-] Error: Main Dusky TUI router not found at {main_router}", file=sys.stderr)
        sys.exit(1)
