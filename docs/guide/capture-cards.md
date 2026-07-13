# Capture Cards

Capture cards are treated as another display output, same black-screen and EDID quirks apply as regular monitors, see [Display Output](/guide/display) for the general troubleshooting steps first.

## AVerMedia Live Gamer Ultra (GC553)

| Resolution | Status |
|---|---|
| 1920x1080@60Hz | Working |
| 1920x1080@120Hz | Black screen |
| 2560x1440@60Hz | Working (see fix below) |
| 2560x1440@120Hz | Black screen |
| 3840x2160@60Hz | Black screen |

**Getting 1440p60 working** (fixes a black screen at default settings):

1. In the capture card's own HDMI compatibility settings, remove any EDID profiles above 2K
2. Remove `video=DP-1:1920x1080@60` from `cmdline.txt`
3. Set `vram.txt` to `0x80000000` (2GB)

## Elgato

Results vary a lot by model and firmware version, HDCP handling in particular seems inconsistent between units.

- **Elgato 4K X**: works with a standard/default config for some users, black screen for others on the same model, suspected firmware version difference (worth updating the capture card's firmware if you hit issues)
- **Elgato HD60X**: reported showing 4K60 HDR correctly in PS5 OS, but Linux only outputs 1080p60, switching to 4K60 or enabling HDR in Linux causes a black screen. Unresolved.

## HDCP

Whether the capture card needs HDCP on, off, or a dedicated HDCP stripper/splitter is inconsistent across devices and setups, some users report needing an HDCP-decrypting splitter for their capture card to pick up a signal at all, others have it working fine straight through. If you're stuck, try both HDCP states in PS5 settings and, if you have one, an HDCP stripper as a troubleshooting step.

## Switching Between TV and Capture Card Without Rebooting

If you use both a TV/monitor and a capture card and want to switch between them without a full reboot, `arandr` (a GUI for `xrandr`) has worked for some users:

```bash
sudo apt install arandr
```

Results are mixed, some users still can't get a picture back after switching outputs and need a reboot regardless.
