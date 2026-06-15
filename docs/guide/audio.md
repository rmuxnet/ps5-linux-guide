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
