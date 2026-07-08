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

Full preset list (`ls /sys/class/leds/ | grep ps5`):

```
off, blue_breathe, blue_hint_purple, blue_rich, blue_to_richblue,
blue_white_anim, dim_cool_white, orange_breathe, orange_dim,
pink_breathe, pink_breathe_fast, pink_purple, pink_violet_dim,
purple, purple_white, purplish_blue_white, salmon_pink,
salmon_pink_breathe, soft_blue_purple_1, soft_blue_purple_2,
soft_orange_dim, soft_purple, sunrise, warm_pink_dim,
white_breathe, white_bright, white_dim, white_medium,
zoneb_both_pulse, zoneb_orange_pulse, zoneb_white_pulse
```

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
