# Display Output

HDMI 2.1 via amdgpu. Works out of the box once amdgpu loads.

## Supported Resolutions

| Resolution | Refresh Rate | Status |
|---|---|---|
| 1080p | 60 Hz | Working |
| 1080p | 120 Hz | Confirmed on ASUS VY249HGR (see note below) |
| 1440p | 60 Hz | Working (some monitors have issues) |
| 2160p (4K) | 60 Hz | Working (some monitors have issues) |
| 1440p | 120 Hz | Confirmed on DELL S3225QC |

30 Hz and broader 120 Hz support may be added in the future.

::: tip `amdgpu.force_1080p=1` caps refresh rate
This flag ships in the default `cmdline.txt` and was long assumed
mandatory, but as of 2026-07-10 testing it isn't required for every
monitor and it actively **caps output to 60Hz** even on displays that
support more. Confirmed on an ASUS VY249HGR (native 1920x1080@120Hz,
AMD FreeSync 48-120Hz per EDID) — capped to 60Hz with the flag present,
full 120Hz once removed. A Lenovo T23d-10 (60Hz-class panel) also
displayed fine with the flag removed.

If your monitor won't display at all, it's still worth trying as a
troubleshooting step (see below) — but if it does work without it, leave
it out, especially on a high-refresh panel.
:::

## Confirmed Working Monitors (no cmdline override needed)

- MSI MAG274Q QD E2 (1440p@60)
- DELL S2721DGF (1440p@60)
- DELL U2515H (1440p@60)
- LG 27GL850 (reportedly)
- Lenovo Legion Y27q (reportedly)
- ViewSonic Elite XG270QG (reportedly)
- ASUS VY249HGR (1080p@120, HDMI — needs `amdgpu.force_1080p=1` *removed* for 120Hz, see tip above)
- Lenovo T23d-10 (1080p@60, HDMI)
- Gigabyte M27UP (1440p@60 and 4K@60, both confirmed, HDMI + sound working)
- Samsung Odyssey G50D 27" (1440p@60)
- AOC Q27G4 (needs `video=DP-1:...` line removed + `amdgpu.force_1080p=1` added)
- ASUS TUF Gaming VG289Q (4K@60, sound working)

## Confirmed Working TVs

- LG C1 OLED (4K@60)
- LG C2 (4K@60, default cmdline, HDCP on)
- LG C4 48" (4K@60, audio delay is a separate known issue, see [Audio](/guide/audio))
- TCL 4K 55" (4K@60, wifi/BT also working, kernel 7.1.2+)
- HiSense 58A7100F (4K@60, 1440p@60, 1080p@60 all confirmed)
- Hisense 6Series-55 (4K, needed a TV firmware update first to get past 1080p)
- Xiaomi TV A 50 (2025 model, working)

::: info Same model can still vary
Reports of the exact same TV/monitor model working for one person and black-screening for another aren't uncommon (see [Troubleshooting Black Screen](#troubleshooting-black-screen) above). Panel revision, firmware version, and cable quality all seem to matter. Treat this list as "known to work for someone," not a guarantee.
:::

## Troubleshooting Black Screen

**Try these in order:**

1. Remove `video=DP-1:1920x1080@60` from `cmdline.txt` on the FAT32 partition
2. Add `amdgpu.force_1080p=1` to `cmdline.txt`
3. Toggle HDCP on/off in PS5 settings (try both)
4. Try a different monitor or cable
5. Use an **HDMI-to-VGA adapter** - confirmed to get some problematic monitors working
6. Try switching TTY: switch to tty2 then back to tty1

**Kernel-level fix (advanced):** Some users fixed persistent black screens by commenting out specific lines in `drivers/ps5/hdmi.c` and rebuilding the kernel:

```c
// sceSetBackToUnpluggedSequence();
// sceSetBackToWaitResolutionSequence();
// in the FLAVA3 block: comment out i2c_cmd_4_2() and the sceSetEdid/sceSetWaitPll calls
```

Rebuild the kernel after making changes - see [Kernel Setup](/guide/kernel).

## 4K Display - Black Screen After Login

If Linux boots but goes black/blue after the login screen on a 4K display:

1. On PS5 OS go to `Settings` → `Screen and Video` → `Video Output` → set resolution to **4K** (not Automatic) and **disable 120Hz**
2. Add your resolution to `cmdline.txt` on the FAT32 partition:
   ```
   video=HDMI-A-1:3840x2160@60
   ```
3. If desktop still doesn't render, SSH in and switch desktop environment - GNOME is confirmed working for some users where other DEs fail

## Black Screen Switching to Desktop Mode (SteamOS/Bazzite)

Boots fine into gamemode, but the screen flashes and goes black when switching to desktop mode. `dmesg` may show:

```
[drm] Failed to add display topology, DTM TA is not initialized.
```

SSH in and force the desktop session directly:

```bash
steamos-session-select plasma
```

Confirmed fix on SteamOS/Bazzite installs hitting this. If it persists, try updating to the latest image build first, this has also been reported fixed by newer builds alone.

## Link Training Error (Most Common Black Screen Cause)

By far the most common root cause behind reported black screens across many different monitor models. Check `dmesg`:

```
amdgpu 0000:20:00.0: [drm] *ERROR* perform_8b_10b_clock_recovery_sequence: Link Training Error, could not get CR after 100 tries. Possibly voltage swing issue
```

This is fixed by [ps5-linux-patches commit fe852d3](https://github.com/ps5-linux/ps5-linux-patches/commit/fe852d3cdb82cd6994072bfdb29d4b7dea803f13), confirmed to resolve it, update your kernel to a version that includes it first before trying anything else on this page.

If you're still on an older kernel and can't update immediately, a resolution-toggle workaround can force recovery without a reboot, e.g. with `kscreen-doctor` (KDE) switch to 1080p then back to your target resolution a few seconds later, this recovers the link without a cold boot on affected setups.

## Gamescope Doesn't Recover From Link Training Failure (SteamOS/CachyOS)

If you get white LED (Linux running), SSH works, Steam/gamescope processes are running, but truly no signal on any display (not just black, actually no signal), and `dmesg` shows the link training error above cycling every ~60-90 seconds: gamescope grabs the DRM device during its initial modeset, hits the link training failure window, and never re-probes even after the PS5's HDMI driver successfully reads EDID afterward (`hdmi: got real edid` in dmesg). `echo detect > /sys/class/drm/card0-DP-1/status` does not help, gamescope already holds the device.

No known fix within CachyOS/SteamOS-based images as of this writing. Workaround: switch to an Ubuntu-based image, which handles this correctly out of the box.

## Custom EDID Injection

If your monitor's EDID isn't being read/parsed correctly (common on some 4K/ultrawide displays), you can inject a known-good EDID dump manually:

1. Dump your monitor's EDID from another PC (Windows: various free EDID tools; Linux: `cat /sys/class/drm/card*/edid` while connected)
2. Copy the `.bin` file to `/lib/firmware/edid/my_edid.bin` on the Linux partition
3. Add to `cmdline.txt`:
   ```
   drm.edid_firmware=DP-1:edid/my_edid.bin
   ```

Note the connector name (`DP-1` here) needs to match your actual output, check `/sys/class/drm/` for the exact name if unsure.

## Black Screen but SSH Works

![This is fine dog sitting in a burning room](/images/memes/this-is-fine.png)

If you can SSH in but display is black, collect logs to diagnose - see
[SSH & Getting Help](/guide/getting-help#collecting-logs-for-a-bug-report)
for the full log-dump command. At minimum check:

```bash
dmesg | grep -iE 'psp|ucode|firmware'
ls /lib/firmware/amdgpu/
```

for missing/failed amdgpu firmware, then share the full dump in Discord.

## Wayland / X11

Both work. Wayland (sway, weston) recommended.

## Audio

See [Audio](/guide/audio).
