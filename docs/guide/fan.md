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

**Reported idle temps:** default target (80°C) idles around 59°C SoC. Dropping target to ~40°C brings idle down to ~46°C, at the cost of constant audible fan noise ("jet mode"). Diminishing returns below that, the servo is already near its ramp ceiling.

## ps5ctl

[ps5ctl](https://github.com/rmuxnet/ps5ctl) wraps this (plus LED, buzzer,
and GPU clock) in a TUI/CLI/web control panel:

```bash
sudo ps5ctl --temp 65
```

or interactively via the Fan tab in `sudo ps5ctl`.

## Standalone fan_mode kernel module

A separate, minimal alternative for benchmarking with the fan forced to a fixed EMC mode (auto/max/min) instead of a target temp, RE'd directly from the EMC ICC commands:

```bash
make -C /lib/modules/$(uname -r)/build M=$PWD obj-m=fan_mode.o modules
```

Force max speed:

```bash
sudo insmod fan_mode.ko zone=0 fan_mode=2 ; sudo rmmod fan_mode
```

Restore auto mode:

```bash
sudo insmod fan_mode.ko zone=0 fan_mode=1 ; sudo rmmod fan_mode
```

No adjustable percentage, the EMC only supports Auto/Max/Min modes. Max is loud, audibly described as "turbine mode" by testers.

## No Dedicated GPU Temperature Sensor

There's no separate GPU-only temperature reading, only the combined APU die temp (`Tctl`), since CPU and GPU share one die:

```bash
cat /sys/class/hwmon/hwmon*/temp*_label   # find Tctl
cat /sys/class/hwmon/hwmon*/temp*_input   # value in millidegrees C
```

This has been a recurring question since early testing, there simply isn't a GPU-specific sensor exposed, `Tctl` is the closest available number and covers both.

**Reference reading:** GPU pinned at its floor (400MHz, `/sys/class/devfreq/ps5-gpufreq/cur_freq`), `Tctl` sat at **42.75°C**. Normal CPU idle floor is ~798MHz, an active SSH session at sample time kept cores elevated (~1.6-3.2GHz spread) rather than fully idle.
