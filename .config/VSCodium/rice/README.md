# Lily × VSCodium

A quiet, wallpaper-tinted VSCodium: the Lily matugen palette, Space Grotesk
chrome, JetBrains Mono with ligatures, a static Material icon fork, Vim keys,
and a translucent editor over the current desktop wallpaper.

## What runs what

- `~/.local/bin/vscodium-rice` — the launcher. It runs the sync, then starts
  the user-owned clone at `~/.local/share/vscodium-rice/app`.
- `~/.local/bin/lily-vscodium-sync` — renders the palette, refreshes the
  static icon theme, downsamples the wallpaper, rebuilds the clone after a
  VSCodium update, and keeps `product.json`'s checksum in step.
- `~/.local/bin/lily-vscodium-restart` — safe restart helper. Waits for the
  running VSCodium instance to exit cleanly before relaunching `vscodium-rice`.
- `~/.config/VSCodium/rice/custom.css` — the glass, wallpaper, typography and
  minimal-UI rules. The clone loads it through a symlink, so editing this file
  never touches the packaged app.
- `~/.config/VSCodium/rice/wallpaper.jpg` — the downscaled copy of the current
  wallpaper. `.wallpaper-source` stores the source path and its size/mtime so a
  wallpaper with an old mtime still triggers a refresh.
- `~/.vscode-oss/extensions/lily.lily-vscodium-theme-1.0.0/` — the “Lily”
  colour theme, the “Lily Material Icons” icon theme, and the background
  wallpaper watcher extension (`extension.js`).

## Wallpaper watcher & restart notification

When you change the wallpaper in Lily, the background extension detects the
update in `~/.local/state/lily-wallpaper`, re-runs `lily-vscodium-sync` in the
background, and shows a toast notification:

> **Lily palette and editor wallpaper updated. Restart VSCodium to apply them.**
> [Restart Now] [Later]

- **Restart Now**: Uses `lily-vscodium-restart` to gracefully quit and relaunch
  the editor with the refreshed palette and wallpaper.
- **Later**: Keeps current session open. The assets are already synced and will
  appear automatically the next time VSCodium is opened.

> [!NOTE]
> **Why restart instead of reload?**
> A window reload (`Developer: Reload Window`) is not enough because Chromium
> caches the workbench stylesheet and `vscode-file://` wallpaper image. Fully
> restarting VSCodium forces Chromium to reload fresh assets.

## Handy commands

```sh
lily-vscodium-sync          # refresh palette, icons, wallpaper and clone
lily-vscodium-restart       # quit-and-relaunch helper
vscodium-rice                # launch the rice
vscodium-rice --new-window --folder-uri \
  "file://$HOME/.config/VSCodium/rice" \
  --goto "$HOME/.config/VSCodium/rice/custom.css:33"
```

In VSCodium's Command Palette (`Ctrl+Shift+P`):
- `Lily: Sync Wallpaper Now` — force an immediate sync and prompt for restart
- `Lily: Restart VSCodium` — gracefully quit and restart the editor

## Icons

The upstream `pkief.material-icon-theme` extension is **not installed**. Its
icons were forked into the Lily theme extension and are now static, which
avoids the upstream extension's startup regeneration race. The pinned source
lives at:

```text
~/.local/share/vscodium-rice/material-icon-theme-src
```

`lily-vscodium-sync` uses that copy if the icon directory ever needs to be
rebuilt. The explorer arrows are hidden and the folder glyphs are re-tinted
from the current matugen `outline` colour on every palette change.

## Troubleshooting

- **Theme or wallpaper did not change:** confirm
  `~/.local/state/lily-wallpaper` points at the current image, run
  `lily-vscodium-sync`, then fully restart VSCodium.
- **Icons disappeared:** check that
  `~/.vscode-oss/extensions/lily.lily-vscodium-theme-1.0.0/icons/` exists and
  that `workbench.iconTheme` is `lily-material-icons`, then restart.
- **VSCodium package updated:** just launch it. The sync detects the new
  version, rebuilds the clone, re-applies the CSS import, and updates the
  integrity checksum.
