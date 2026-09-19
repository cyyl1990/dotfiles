# Installation

## Requirements

- **tmux** 3.0+ (recommended: 3.2+)
- **Bash** 5.0+ (5.1+ recommended for optimal performance)
- **Nerd Font** for icons (recommended: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/))

### Bash Version Features

PowerKit uses modern Bash features for optimal performance:

| Version | Features | Impact |
|---------|----------|--------|
| **5.0+** (required) | `$EPOCHSECONDS`, `$EPOCHREALTIME`, `${var,,}`, `${var^^}` | Eliminates external `date` and `tr` calls |
| **5.1+** (recommended) | `assoc_expand_once` | Optimizes associative array operations |

**Check your Bash version:**

```bash
bash --version
```

## TPM Installation (Recommended)

Add to your `~/.tmux.conf`:

```bash
set -g @plugin 'fabioluciano/tmux-powerkit'
```

Install with `prefix + I` (capital i).

## Manual Installation

### Shallow Clone (Recommended)

For faster download (~1.5 MB instead of ~20 MB):

```bash
git clone --depth 1 https://github.com/fabioluciano/tmux-powerkit.git ~/.tmux/plugins/tmux-powerkit
```

### Full Clone

If you need the full git history:

```bash
git clone https://github.com/fabioluciano/tmux-powerkit.git ~/.tmux/plugins/tmux-powerkit
```

### Tarball Download (No Git Required)

Download without git (smallest size):

```bash
mkdir -p ~/.tmux/plugins
curl -L https://github.com/fabioluciano/tmux-powerkit/archive/refs/heads/main.tar.gz | tar xz -C ~/.tmux/plugins
mv ~/.tmux/plugins/tmux-powerkit-main ~/.tmux/plugins/tmux-powerkit
```

### Configuration

Add to your `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-powerkit/tmux-powerkit.tmux
```

Reload tmux:

```bash
tmux source ~/.tmux.conf
```

### Nix/NixOS

Add to `flake.nix`:

```nix
{
  inputs.tmux-powerkit.url = "github:fabioluciano/tmux-powerkit";
}
```

Add to `configuration.nix` or `home.nix`:

```nix
programs.tmux = {
  enable = true;
  plugins = [{
    plugin = inputs.tmux-powerkit.packages.${pkgs.system}.default;
    extraConfig = ''
      set -g @powerkit_plugins "datetime,battery,cpu,memory,git"
      set -g @powerkit_theme "catppuccin"
      set -g @powerkit_theme_variant "mocha"
    '';
  }];
};
```

For non-flake install, add to your `configuration.nix` or `home.nix`:

```nix
let
  tmux-powerkit = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    rev = "main";  # or pin to a specific commit
    sha256 = "";   # nix will provide correct hash on first build
  } + "/default.nix") {};
in {
  programs.tmux = {
    enable = true;
    plugins = [ tmux-powerkit ];
    extraConfig = ''
      set -g @powerkit_plugins "datetime,battery,cpu,memory,git"
      set -g @powerkit_theme "catppuccin"
      set -g @powerkit_theme_variant "mocha"
    '';
  };
}
```

## Verify Installation

After installation, you should see the PowerKit status bar. Press `prefix + C-e` to open the options viewer and verify the configuration.

## Nerd Font Setup

PowerKit uses Nerd Font icons. Install a Nerd Font and configure your terminal:

### macOS

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

### Linux

Download from [Nerd Fonts](https://www.nerdfonts.com/font-downloads) and install to `~/.local/share/fonts`.

### Terminal Configuration

Configure your terminal to use the Nerd Font:
- **iTerm2**: Preferences → Profiles → Text → Font
- **Alacritty**: `font.normal.family` in config
- **Kitty**: `font_family` in config

## Bash 5+ on macOS

macOS ships with Bash 3.x (due to licensing). Install Bash 5+:

```bash
brew install bash
```

Verify installation:

```bash
/opt/homebrew/bin/bash --version  # Apple Silicon
# or
/usr/local/bin/bash --version     # Intel Mac
```

PowerKit will automatically detect and use the Homebrew version if available.

## Next Steps

- [Quick Start](Quick-Start) - Basic configuration
- [Configuration](Configuration) - All options
- [Themes](Themes) - Available themes
