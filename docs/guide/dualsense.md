# DualSense Controller

Works via USB with the `hid-playstation` kernel driver (mainline since 5.12).

```bash
lsmod | grep hid_playstation
```

Rumble, touchpad, gyro, and buttons all functional over USB.

::: info Wireless
On Bazzite, pair the controller via Bluetooth in **gamemode only** - pairing in desktop mode will not work.
:::

# Dualsense Fix For Marvell

The developer cow recently released an updated Bluetooth driver supporting Marvell and MediaTek wireless chipsets. However, users attempting to connect a PlayStation 5 DualSense controller to a Linux environment may experience connectivity issues.

The following procedure outlines the steps required to successfully resolve these connection failures specifically on systems utilizing Marvell hardware.

::: info Warning
After testing the workaround it does not resolve connectivity issues on MediaTek chipsets. This fix is strictly applicable to Marvell chips.
:::

This script automatically generates the required udev rules, modifies the TLP and Bluetooth configurations, and restarts the necessary services.

```bash
curl -sSL https://raw.githubusercontent.com/rmuxnet/ps5-linux-guide/main/docs/public/scripts/BLfix/blfix.sh | bash
```