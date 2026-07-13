# Gaming

PS5 Linux runs Steam games via Proton. Performance is solid - 1800p is a sweet spot for many titles.

## Steam Installation

**Do not use the snap version.** Install from the Steam website or via apt with i386 enabled:

```bash
# Ubuntu
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steam
```

Or download the `.deb` installer from [store.steampowered.com/about](https://store.steampowered.com/about/) and install it directly.

## Proton

Use **Proton Experimental (bleeding-edge)** for best compatibility. For EAC/BattleEye games specifically, try **Proton EAC** or **Proton BE**.

## Confirmed Working Games

| Game | Settings | Notes |
|---|---|---|
| CS2 | - | Working; see mouse issue below |
| Halo MCC | 4K | 90-100fps, multiplayer works |
| Call of Duty: Black Ops 3 | 1800p | 90+ fps |
| Forza Horizon 6 | 1800p high | 60fps; Proton Experimental bleeding-edge; add as non-Steam game |
| World of Warcraft | 1080p max | Stable 60fps; install via Battlenet |
| Star Wars Jedi: Survivor | 1080p medium | 60fps, no ray tracing |
| Blades of Fire | 1080p max | 60+ fps |
| Another Crab's Treasure | High | Flawless |
| VOIN | TAA only | Fast and responsive |
| Call of the Elder Gods | - | Working |
| Final Fantasy XIV | - | Via XIV Launcher through Steam |
| 007: First Light | Low + FSR Performance | OK |
| Rocket League | - | Online works; latest Proton |
| Factorio | - | Runs great |
| Final Fantasy XVI | 4K | 60fps with 8GB VRAM; drop to 2K for faster load times |
| Mafia 3 | - | Stutters; theflow barely hits 60fps - known game optimization issue, not PS5-specific |

## Anti-Cheat

| Anti-Cheat | Status | Notes |
|---|---|---|
| EAC / BattleEye | ~ Partial | Use Proton EAC or Proton BE |
| EA Javelin (FC 26, BF6) | ✗ No Linux support | Blocks Linux outright; no workaround |

## World of Warcraft via Battlenet

WoW requires Battlenet. Install via Proton:

1. Download `battlenet-setup.exe` from battle.net
2. Add it as a non-Steam game
3. Install to `/home/<user>/Games` (shows as `Z:/home/<user>/Games` in the installer)
4. Launch `Battle.net.exe` from that folder to play

**Performance tuning:** single-core CPU performance is the bottleneck in raids (see [Gaming Benchmarks](#gaming-benchmarks) for why), not GPU. In Lutris, edit the WoW shortcut, Configure -> Environment Variables, add:

```
PROTON_FORCE_FSYNC=1
VKD3D_CONFIG=no_upload_h_cb
RADV_PERF_PROFILE=pro
```

Reported to noticeably help frame times in busy scenes (25-man raids), though single-core-bound content will still dip regardless. Use the cachyos-proton build from Steam for this.

## Known Issues

### CS2 - Mouse keeps snapping to center

Caused by DualSense being recognized as a controller while connected. Fix via gamescope (add to Steam launch options):

```
gamescope --force-grab-cursor --immediate-flips -f -w 1080 -h 1080 -W 1920 -H 1080 -r 144 -S stretch -- %command% -fullscreen -w 1080 -h 1080 -refresh 144
```

Adjust `-r 144` and resolution to match your display. Also try disconnecting DualSense before launching.

### CS2 - Black screen after Valve logo

Some users on Ubuntu get a black screen after the Valve splash. CS2 is more reliable on CachyOS. If you're on Ubuntu, make sure Mesa is updated (see First Boot steps).

### Steam snap version

The snap install of Steam has known issues. Use the `.deb` from the Steam website instead.

## Gaming Benchmarks

| Game | Settings | FPS |
|---|---|---|
| Tiny Tina's Wonderlands | 1080p High | 95 avg |
| Tiny Tina's Wonderlands | 1080p Ultra | 85 avg |
| Tiny Tina's Wonderlands | 4K Low | 28 avg |
| Tiny Tina's Wonderlands | 4K High | OOM crash |
| Team Fortress 2 | 4K Max (no MSAA) | 60-300 |

## Game Streaming & VR

No VCN hardware encoder (see [GPU](/guide/gpu#vcn-hardware-video-decode)), and Vulkan video encode is not supported on this GPU (GFX1013) either, so any streaming solution is limited to **software (x264) encoding only**.

- **Steam Link:** works, x264 software encode. Reported ~33% CPU usage per core while streaming.
- **Sunshine:** does not work currently, fails with `[h264_vulkan] Encoding of h264 is not supported by this device` since it expects a hardware or Vulkan encoder.
- **VR (Quest/standalone headsets):** WiVRN has had better results than Steam Link or ALVR for PCVR streaming - reported working with Quest 3, audio can be choppy at low bitrate, raise bitrate if pixelation/choppiness shows up.

## Local LLMs

PS5 Linux runs local LLMs fine via [Open-WebUI](https://github.com/open-webui/open-webui). Community has run:

- Gemma4:12B
- Qwen3:14B

16GB shared RAM makes it viable for mid-size models.

## Performance Tips

- **1800p** is a sweet spot - many games hit 90+ fps at 1800p that struggle at 4K
- Enable fan and CPU/GPU boost via `ps5_control` before gaming - see [Post-Install](/guide/booting#first-boot)
- **gamescope in TTY** (no DE) is the lowest-overhead way to run games - launch gamescope directly from a TTY session
- Use **gamescope** for FPS limiting and upscaling
- **mangohud** for an FPS overlay
- Remove `idle=halt` from `cmdline.txt` if you notice microstuttering - see [GPU](/guide/gpu#performance-tips)
