# Audio

HDMI audio works on most monitors but not all. Known bug, no fix yet for monitors where it outright doesn't work.

## Audio Defaults to Controller Instead of HDMI

If you have a DualSense plugged in via USB, Linux may default audio output to the controller instead of HDMI.

**Fix (Ubuntu/GNOME):**

1. Press the Super key and type "Sound"
2. Open the Sound panel
3. Under Output, select your HDMI device

**Alternative fix:** Switch from PipeWire to PulseAudio native - confirmed to resolve audio issues for some users.

## HDMI Audio Not Working at All

Some monitors do not recieve HDMI audio from the PS5. This is a known issue with no fix currently. Use a USB or Bluetooth audio device as a workaround.

## DP Audio Hiccup Every ~40 Seconds (DP-to-HDMI Adapters)

If you're using an active DisplayPort-to-HDMI adapter and get a recurring audio "hiccup" roughly every 40 seconds, this is a clock mismatch in the amdgpu display clock manager, the DP audio clock the driver expects (5988740) doesn't match what the hardware actually runs at (6000000). Fixed upstream with a two-line patch to `dcn201_clk_mgr.c`, already merged into `ps5-linux-patches`. Update your kernel and this should be resolved.

## HDMI Audio Delay

A kernel-level fix for HDMI audio delay/desync has been merged. If you're still on an older kernel, update first. After updating, you may also need to manually switch your output format: open Sound settings and change from **Digital Stereo (HDMI)** to **Digital Surround 5.1 (HDMI)**, some users needed this extra step on top of the kernel update for the fix to fully take effect, especially noticeable during video playback.
