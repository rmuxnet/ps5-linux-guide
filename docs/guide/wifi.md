# WiFi (IW620 / mwifiex)

Internal chip: `40:00.7` - `Marvell Technology Group Ltd. Device [1b4b:2b56] (rev 02)`

Driver: NXP mwifiex fork patched for PS5 IW620.

## Install

```bash
git clone https://github.com/ps5-linux/ps5-linux-mwifiex
cd ps5-linux-mwifiex
sudo ./install.sh
```

To uninstall:

```bash
sudo ./install.sh uninstall
```

## Manual Load

```bash
sudo modprobe cfg80211
sudo insmod ./mlan.ko
sudo insmod ./moal.ko \
  fw_name=nxp/pcieuartiw620_combo_v1.bin \
  pcie_int_mode=1 drv_mode=1 cfg80211_wext=4 sta_name=mlan \
  ext_scan=1 auto_fw_reload=0 wifi_reset_config=0 \
  sched_scan=0 ps_mode=2 auto_ds=2 amsdu_disable=1
```

## Build from Source

```bash
git clone https://github.com/nxp-imx/mwifiex.git && cd mwifiex
git checkout lf-6.18.2_1.0.0
git apply ../ps5-iw620.patch
make CONFIG_OBJTOOL=
```

## Pre-configure WiFi Before First Boot

No Ethernet and need WiFi working on first boot? You can hardcode credentials from another PC before plugging the USB into your PS5.

```bash
# Mount the rootfs partition from the flashed USB
MNT=$(mktemp -d)
sudo mount /dev/sdX1 "$MNT"

# Create the NetworkManager connection file
sudo install -d -m 700 "$MNT/etc/NetworkManager/system-connections"
sudo tee "$MNT/etc/NetworkManager/system-connections/wifi.nmconnection" >/dev/null <<'EOF'
[connection]
id=wifi
type=wifi
autoconnect=true

[wifi]
mode=infrastructure
ssid=YOUR_SSID_HERE

[wifi-security]
key-mgmt=wpa-psk
psk=YOUR_PASSWORD_HERE

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto
EOF

sudo chmod 600 "$MNT/etc/NetworkManager/system-connections/wifi.nmconnection"
sudo chown root:root "$MNT/etc/NetworkManager/system-connections/wifi.nmconnection"
sudo umount "$MNT"
```

## Arch - Install Failing (Missing / Wrong Headers Path)

If `./install.sh` fails on Arch, first make sure headers are installed:

```bash
sudo pacman -U linux-bin/linux-ps5-headers_*.pkg.tar.zst
```

Headers are in the same `linux-bin/` folder as the kernel package, or download from [ps5-linux-patches releases](https://github.com/ps5-linux/ps5-linux-patches/releases).

If it still fails, there is a known packaging bug where headers get installed to `/usr/usr/include` instead of `/usr/include`. Fix:

```bash
sudo cp -r /usr/usr/include/* /usr/include/
```

Confirmed working on CachyOS Arch base.

## Known Issues

WiFi may need to be disabled and re-enabled after first boot to get a connection. If it drops under load, reload the driver (this is a known occurance):

```bash
sudo modprobe -r moal mlan
sudo modprobe cfg80211
sudo insmod ./mlan.ko
sudo insmod ./moal.ko fw_name=nxp/pcieuartiw620_combo_v1.bin pcie_int_mode=1 drv_mode=1 cfg80211_wext=4 sta_name=mlan ext_scan=1 auto_fw_reload=0 wifi_reset_config=0 sched_scan=0 ps_mode=2 auto_ds=2 amsdu_disable=1
```
