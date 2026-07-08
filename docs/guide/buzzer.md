# Buzzer

The PS5's chassis piezo buzzer is exposed as a kernel driver, driven over
ICC (same indicator service used by the LED). Merged in `ps5-linux-patches`
#12.

## Sysfs interface

```
/sys/class/misc/ps5_buzzer/beep
```

Write a level, 0-3:

| Value | Meaning |
|---|---|
| 0 | Silent |
| 1 | Short beep |
| 2 | Error beep |
| 3 | Long beep |

```bash
echo 1 | sudo tee /sys/class/misc/ps5_buzzer/beep   # short
echo 2 | sudo tee /sys/class/misc/ps5_buzzer/beep   # error
echo 3 | sudo tee /sys/class/misc/ps5_buzzer/beep   # long
```

There's also a `stop` attribute that cancels a pattern started through the
driver's ioctl-based pattern player (`/dev/ps5_buzzer`, `PS5_BUZZER_PLAY`) -
not needed for the basic beep levels above.

```bash
echo 1 | sudo tee /sys/class/misc/ps5_buzzer/stop
```

## ps5ctl

[ps5ctl](https://github.com/rmuxnet/ps5ctl) exposes the three beep levels
by name:

```bash
sudo ps5ctl --buzz --list      # Short, Error, Long
sudo ps5ctl --buzz Short
```

or via the Buzzer tab in `sudo ps5ctl`.
