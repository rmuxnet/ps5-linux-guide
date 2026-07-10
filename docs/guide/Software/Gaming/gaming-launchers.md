# Gaming Launchers

::: info Arch-based only
For game compatibility, benchmarks, and Proton troubleshooting see the
existing [Gaming](/guide/gaming) page (written for the apt/Ubuntu install).
This page covers just the Arch-side launcher setup, pulled from a real PS5.
:::

## Steam

```bash
sudo pacman -S steam
```

No snap/flatpak needed on Arch - the repo package is the recommended path.
Verified on the reference PS5: `steam 1.0.0.85`.

### Proton versions available out of the box

Steam ships these once you enable "Steam Play" for all titles in Settings → Compatibility:

- Proton Experimental (bleeding-edge, use this by default)
- Proton 11.0
- Proton Hotfix

See [Gaming](/guide/gaming#proton) for which one to pick per-game.

## Heroic Games Launcher

Epic/GOG/Amazon Games launcher, no Epic client overhead.

```bash
paru -S heroic-games-launcher-bin
```

Verified on the reference PS5: `heroic-games-launcher-bin 2.22.0`. Uses its
own bundled Proton-GE by default - manage versions from Heroic's Settings →
Wine/Proton Manager, no separate tool needed for that launcher specifically.

## ProtonUp-Qt

Only needed if you're **not** using Heroic's built-in manager, or want extra
Proton-GE/Wine-GE builds for Steam non-Steam-game entries.

```bash
paru -S protonup-qt
```

Not installed on the reference PS5 by default - Heroic's built-in manager
covered that use case there. Install it yourself if you add non-Steam games
that need a custom Proton-GE build.

## gamescope / gamemode / mangohud

Also not present on the reference PS5 install by default, despite being
referenced in the [Gaming](/guide/gaming#performance-tips) performance tips.
They're optional add-ons, not required:

```bash
sudo pacman -S gamescope gamemode mangohud
```

- **gamescope** - run games in a nested compositor, TTY-only mode is the lowest-overhead way to game (no DE running at all)
- **gamemode** - auto-applies CPU governor/priority tweaks per-game
- **mangohud** - FPS/frametime overlay
