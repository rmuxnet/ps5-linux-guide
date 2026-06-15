# Known Issues

| Issue | Status |
|---|---|
| VCN hardware video decode missing | Open |
| WiFi (mwifiex) drops under load | Open |
| Screen saver broken | Open |
| HDMI audio missing on some monitors | Open |
| 1440p/2160p display issues on some monitors | Open |
| CachyOS currently not booting (kernel panic) | Broken - use Ubuntu or Arch |
| Kernel update on M.2 causes black screen | Workaround: stay on 7.0.10 |
| Audio defaults to controller instead of HDMI | Workaround available |

## CachyOS Currently Broken

CachyOS is currently not booting - confirmed by multiple users including rmux. Kernel panics immediately after the orange LED stops blinking. **Use Ubuntu or Arch instead until this is resolved.**

If you have an older image (7.0.2) it may still work. The gamescope-session fix below applied to an earlier issue:

```bash
sed -i 's/-steamos3//' /usr/bin/gamescope-session-ps5
```

## Kernel Update Breaks M.2 Boot

Updating the kernel on an M.2 install can cause a black screen. Stay on kernel **7.0.10** on M.2 until this is resolved. If you already updated and get a black screen, use the chroot method to reinstall 7.0.10 - see [Recovering a Broken USB](/guide/booting#recovering-a-broken-usb-chroot-reinstall).

## FAQ

**Will Slim / higher firmware versions be supported?**
We genuinely don't know - and we don't want to jinx anything.

**Can I dual-boot Linux and PS5 OS?**
No - this is a soft-mod. Re-run the exploit each time to boot Linux.

**Can I use the PS5 in standby/resume?**
Not currently. Shutdown puts PS5 into rest mode; relaunch Linux on next power-up may be added later.

**Does the internal SSD get modified?**
No. Linux runs from USB or M.2. Internal SSD is untouched.

**After reboot I see "Repairing" / "PS5 wasn't turned off properly"**
Normal and harmless.

**Screensaver kicked in during a long install and the screen is frozen**
SSH in from another device and run `sudo reboot`. Always disable the screensaver before long operations - it is currently broken and cannot be dismissed.

**"Could not create PS5 WiFi firmware directory" in loader output**
Non-fatal. The loader continues and Linux will still boot. Not the cause of boot failures.

**My PS5 goes back to PS5 OS instead of booting Linux**
You pressed the power button before the orange LED became static. Wait for solid orange, then press.

**Linux won't boot after running the exploit**
Make sure you did not run etahen, kstuff, or any other payload before sending the Linux loader. Restart and jailbreak fresh - see [Jailbreak](/guide/jailbreak).
