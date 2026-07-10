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

## Black Screen but SSH Works

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
