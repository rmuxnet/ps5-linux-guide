# Fan Control

The fan is driven by the ICC's autoservo firmware - the kernel exposes a
target SoC temperature and the firmware ramps the fan on its own to hold
that temperature. There's no manual PWM/RPM control, just the target.

Kernel driver: `drivers/ps5/fan/` (merged in `ps5-linux-patches` #25).
Default target is 80°C.

## Sysfs interface

```
/sys/bus/platform/devices/ps5-fan/target_temp
```

Read the current target:

```bash
cat /sys/bus/platform/devices/ps5-fan/target_temp
```

Set a lower target for more aggressive cooling (louder, but keeps the SoC
cooler under load) - e.g. 65°C:

```bash
echo 65 | sudo tee /sys/bus/platform/devices/ps5-fan/target_temp
```

Valid range is 0-100 (°C). There's no need to slam it to a fixed "max"
setting - the servo already ramps as needed once it has a target to chase,
so just pick a target temp you're happy with.

## ps5ctl

[ps5ctl](https://github.com/rmuxnet/ps5ctl) wraps this (plus LED, buzzer,
and GPU clock) in a TUI/CLI/web control panel:

```bash
sudo ps5ctl --temp 65
```

or interactively via the Fan tab in `sudo ps5ctl`.
