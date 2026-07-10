# Desktop Stack

::: info Arch-based only
This page covers the Arch/CachyOS stack, verified from a real PS5 running
Arch (kernel `7.1.3-FullLTO-exp`) plus a daily-driver laptop.
:::

## Recommendation: sway (or Hyprland)

**sway** is the pick for PS5 Linux. It's what's actually running on
rmux's own PS5 right now, and this is a direct recommendation from the
guide maintainer, who's also a PS4/PS5 kernel developer. **Hyprland**
is the other solid option if you want more eye candy for a small GPU cost.
Reasons for sway:

- wlroots-based, minimal compositor overhead - matters on shared APU memory (GPU + CPU share the same pool)
- No animation/blur/effect pipeline eating GPU cycles you'd rather give to a game
- Config is a flat text file, easy to strip down further
- Idle desktop session footprint on the reference PS5: **~762MB RAM** (sway + waybar + foot + swaync running)

## Verified working sway stack (from the PS5)

| Component | Package | Role |
|---|---|---|
| Compositor | `sway` | Window manager |
| Status bar | `waybar` | Top/bottom bar, workspaces, clock, network, temps |
| Notifications | `swaync` | Notification daemon + do-not-disturb |
| Terminal | `foot` | GPU-accelerated, fast startup, server mode supported |
| Launcher | `fuzzel` | App launcher (rofi-equivalent) |
| Wallpaper | `swaybg` | Static wallpaper daemon |
| Logout menu | `wlogout` | Power menu (lock/logout/reboot/shutdown) |
| Greeter | `greetd` + `greetd-regreet` | Login manager, wayland-native |

Install:

```bash
sudo pacman -S sway waybar swaync foot fuzzel swaybg wlogout greetd greetd-regreet
sudo systemctl enable greetd
```

## Other WMs/DEs - when they make sense

You don't *have* to run sway. What matters more than the DE choice is
trimming background daemons regardless of which one you pick - a heavy DE
with everything disabled can beat a light WM left at defaults.

| DE/WM | Weight | Notes |
|---|---|---|
| **sway** | Lightest | Top recommendation. wlroots, no compositor effects |
| **Hyprland** | Light-medium | Also recommended. wlroots-based, more eye candy (blur/animations) than sway at some GPU cost |
| **GNOME** | Heavy | Works fine on PS5 hardware. Mutter compositor overhead is real but the APU handles it |
| **KDE Plasma** | Heaviest | Confirmed working intermittently - has been flaky on some setups. If you want KDE, budget more RAM headroom and expect to trim `plasma-*` background services |

::: tip Trimming background apps
Whatever DE you land on, check `systemctl --user list-units --state=running`
and disable anything you don't use (indexers, telemetry-adjacent services,
duplicate polkit agents). This matters more for total headroom than the WM
pick itself.
:::

## Extra utilities worth having

Common across both a PS5 and a normal Arch laptop setup:

| Tool | Purpose |
|---|---|
| `grim` + `slurp` | Screenshot (full/region) |
| `swappy` | Annotate screenshots |
| `cliphist` | Clipboard history for wayland |
| `playerctl` | Media key control (play/pause/next from keyboard) |
| `nwg-look` | GTK theme switcher for wayland |
| `starship` | Shell prompt (works with fish/bash/zsh) |
| `zoxide` | Faster `cd`, jumps to frecent dirs |
