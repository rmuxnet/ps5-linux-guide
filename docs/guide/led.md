# LED Control

The front bar and standby LEDs are driven by the ICC (Internal Controller
Chip) - a preset driver is built into the kernel via `drivers/ps5/led/`
(merged in `ps5-linux-patches` commit `6479385`).

## Sysfs interface

```
/sys/class/leds/ps5:<preset>:indicator/brightness
```

Write `1` to activate a preset:

```bash
echo 1 | sudo tee /sys/class/leds/ps5:purple:indicator/brightness
```

Turn the LED off:

```bash
echo 1 | sudo tee /sys/class/leds/ps5:off:indicator/brightness
```

List available presets:

```bash
ls /sys/class/leds/ | grep ps5
```

Common presets: `off`, `blue_rich`, `purple`, `pink_breathe`, `sunrise`.

## Hardware notes

The LED has two independently addressable zones:

- **Zone A** - main front light bar (blue, white, orange channels)
- **Zone B** - secondary LED near the power button, used for standby breathe
  animations. Not user-visible during normal desktop use.

Channels overlap in perceived color - blue and white both wash out orange
at high brightness, so pink/purple presets keep orange near max and the
other channel(s) low.

## Reading the boot-status LED

This is separate from the presets above - see [Booting Linux](/guide/booting#reading-the-led)
for what the stock orange/white LED states mean during the loader handoff.
