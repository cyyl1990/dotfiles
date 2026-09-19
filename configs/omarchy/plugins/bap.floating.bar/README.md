# Bap Floating Bar

A modular floating-island bar for [Omarchy](https://omarchy.org), built on the stock `omarchy.bar`.

![Bap Floating Bar](preview.png?v=2)

Instead of one bar strip glued to the screen edge, your widgets live on **three independent rounded islands** (left / center / right sections) that float off the edge with configurable gaps and an optional outline for dark wallpapers.

## Features

- **Three floating islands** — left, center and right widget sections render as separate pills that float away from the screen edge.
- **Drag to swap** — grab any island by its empty space and drop it onto another island to swap their widget groups. Swaps are persisted to `shell.json`.
- **Edge resizing** — each island has invisible grip strips on its ends; drag them to give an island extra breathing room beyond its content-fit width. Widths persist too.
- **Works on all edges** — full support for top / bottom / left / right positions. On side edges the islands stack vertically along the strip.
- **Outline** — a subtle hairline outline (accent-colored while dragging over a swap target) keeps the islands readable against dark wallpapers.
- **Security hardened** — all externally controlled strings (window titles, tray names, menu text, command output, layout labels) render as plain text or get rich-text escaped at the plugin boundary; indicator ids are validated before hitting the loader; workspace dispatch is numeric-checked. These fixes were originally surfaced during the salted.bar marketplace review ([omarchy-plugin-marketplace#1057](https://github.com/HANCORE-linux/omarchy-plugin-marketplace/issues/1057)).

## Install

Already configured in shell.json as active bar. Just ensure symlink exists:

```bash
bap-suite link bap.floating.bar
omarchy-restart-shell
```

## Remove

Switch back to built-in bar:

```bash
omarchy bar use omarchy.bar
bap-suite disable bap.floating.bar
bap-suite unlink bap.floating.bar
```

## Configuration

Everything lives in `~/.config/omarchy/shell.json` under `bar.islands`. Edits hot-reload.

```jsonc
{
  "bar": {
    "islands": {
      "enabled": true,
      // edgeGap / sideGap are OPTIONAL. Omit them and both layouts track
      // Hyprland's own general:gaps_out live (below); set a number to pin
      // that side to a fixed px instead.
      "edgeGap": 8,          // px between the islands and the screen edge
      "sideGap": 8,          // px inset from the perpendicular screen sides
      "radius": 9,           // corner rounding of each island
      "padding": 12,         // horizontal padding inside an island
      "outlineWidth": 1,     // 0 disables the outline
      "outlineOpacity": 0.35,
      "widths": {            // extra px added to each island's content width
        "left": 82,
        "center": 128,
        "right": 74
      }
    }
  }
}
```

Notes:

- Widget layout itself stays under the standard `bar.layout` keys (`left` / `center` / `right`) — manage it with the regular Omarchy bar settings UI.
- Double-clicking empty island space toggles bar transparency, same as the stock bar.

## Gap follows Hyprland (both layouts)

The floating margin isn't a fixed number. Both the **island** layout and the
**slab** layout read Hyprland's `general:gaps_out` at startup and re-read it
on every Hyprland config reload (`configreloaded`), so whatever gap a theme
sets for the desktop is the gap the bar floats at — no shell reload needed.

- Theme swaps or Omarchy's own "no gaps" toggle (`omarchy hyprland window
  gaps toggle`) re-gap the bar live, because they `hyprctl reload` and change
  `gaps_out`.
- On side/vertical edges, `edgeGap` (gap to the anchored screen edge) and
  `sideGap` (gap to the perpendicular sides) both default to the detected
  gap. Setting either one in `shell.json` pins just that side.
- In island mode the edge facing the tiled windows gets no gap of its own —
  Hyprland already gaps windows right up to the bar's exclusion zone there.
- `noRoundedOnNoGaps` still squares the bar off whenever the detected gap is
  `0` (see `bar` config), so a flush bar never ends up rounded against the
  screen edge.

## Credits

- Built on top of Omarchy's built-in [`omarchy.bar`](https://github.com/HANCORE-linux/omarchy) widget set.
- Originally forked from [`better_salted.bar`](https://github.com/salted-sorbet/better_salted.bar) by salted-sorbet.
- Hardening fixes adapted from the marketplace security review of the original salted.bar.

## License

MIT License - Copyright (c) 2026 Bắp (bap)
Forked from better_salted.bar by salted-sorbet (MIT License)
