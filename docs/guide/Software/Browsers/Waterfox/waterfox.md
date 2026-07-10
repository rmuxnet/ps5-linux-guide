# Waterfox

Firefox fork, no telemetry by default, drop-in replacement if you don't want vanilla Firefox.

::: info Arch-based only
This page covers Arch/CachyOS install. Firefox (via `pacman -S firefox`) is the
verified default on the PS5's own Arch install - Waterfox is an alt if you
want it.
:::

## Install (AUR)

```bash
paru -S waterfox-bin
# or with yay
yay -S waterfox-bin
```

No AUR helper yet:

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si
```

## Why Waterfox over Firefox

- No Mozilla telemetry/data collection by default
- Same Gecko engine, same extension compatibility (Firefox add-ons work)
- Drop-in - profile/bookmarks import from Firefox works normally

## Hardware Video Acceleration

Same as Firefox on amdgpu - set in `about:config`:

```
media.ffmpeg.vaapi.enabled = true
media.hardware-video-decoding.force-enabled = true
```

Confirm it's active: play a video, check `about:support` → Media → "Decoder used" should say `PlatformDecoderModule`/VAAPI, not `ffmpeg software`.
