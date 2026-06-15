# DualSense Controller

Works via USB with the `hid-playstation` kernel driver (mainline since 5.12).

```bash
lsmod | grep hid_playstation
```

Rumble, touchpad, gyro, and buttons all functional over USB.

::: info Wireless
Use a USB Bluetooth dongle to connect DualSense wirelessly. On Bazzite, pair the controller via Bluetooth in **gamemode only** - pairing in desktop mode will not work.
:::
