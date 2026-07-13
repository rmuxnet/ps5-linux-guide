# WiFi (IW620 / mwifiex)

Internal chip: `40:00.7` - `Marvell Technology Group Ltd. Device [1b4b:2b56] (rev 02)`

Driver: NXP mwifiex fork patched for PS5 IW620.

::: warning MediaTek MT7921 chip (Salina rev2 / CFI-12xx Chassis C) not supported
Some newer chassis boards use a MediaTek MT7921 (`14c3:7961`) instead of the Marvell chip covered on this page, see [Hardware](/guide/hardware) for how to check which one you have. There is currently **no working driver** for it, the stock `mt7921e` module isn't built in the official kernel config, and even test builds with it enabled don't reach the firmware-load code, this needs reverse engineering, not just a config flag. If you have this chip, use a USB WiFi adapter for now.
:::

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

## Adapter Shows as UNCLAIMED, Driver Loads But Never Binds

If `lspci` sees the Marvell chip and `moal` shows up under Kernel modules, but the interface never actually comes up, and dmesg shows the driver recognizing the card then silently giving up with no firmware errors:

```
Attach moal handle ops, card interface type: 0x207
Enable moal_recv_amsdu_packet
Attach mlan adapter operations.card_type is 0x207.
```

This was a script bug: `install.sh` dropped the firmware in `/lib/` instead of `/lib/firmware/`, and the kernel only scans `/lib/firmware/`. Check where it actually landed:

```bash
find /lib -iname "pcieuartiw620_combo_v1.bin"
```

If it's sitting in `/lib/` instead of `/lib/firmware/nxp/`, move it:

```bash
sudo mkdir -p /lib/firmware/nxp
sudo mv /lib/pcieuartiw620_combo_v1.bin /lib/firmware/nxp/
```

Reload the driver after moving it, the interface should come up immediately.

## Package Manager Install (Fedora / Debian) - Common Failures

If you're on a distro using the `ps5-linux-mwifiex` package instead of the manual `install.sh` above, two failure modes come up often:

**Dependency version pin:**

```
ps5-linux-mwifiex : Depends: linux-ps5 (= 7.1.1) but 7.1.2 is to be installed
```

The mwifiex package pins an exact kernel version. Install the matching `linux-ps5` version rather than upgrading the kernel first, or check `dmesg | grep -iE 'moal|mlan|mwifiex'` to see if your kernel already has it built in before fighting the package manager.

**Kernel/gcc/pahole mismatch on build:**

```
warning: kernel built on gcc 13, using gcc 15
```

The toolchain building the module has to match what built the kernel. Don't mix a distro-upgraded gcc with an older prebuilt `linux-ps5` kernel package.

**Confirmed working install (rpm-ostree / Bazzite):**

```bash
sudo dnf upgrade -y linux-ps5 --setopt=gpgcheck=0
sudo rpm-ostree install ps5-linux-mwifiex ps5-linux-tools
sudo systemctl reboot
```

If apt/dnf conflicts on cached package files with the same filenames, fall back to the manual `install.sh` method above instead.

## Known Issues

WiFi may need to be disabled and re-enabled after first boot to get a connection. If it drops under load, reload the driver (this is a known occurance):

```bash
sudo modprobe -r moal mlan
sudo modprobe cfg80211
sudo insmod ./mlan.ko
sudo insmod ./moal.ko fw_name=nxp/pcieuartiw620_combo_v1.bin pcie_int_mode=1 drv_mode=1 cfg80211_wext=4 sta_name=mlan ext_scan=1 auto_fw_reload=0 wifi_reset_config=0 sched_scan=0 ps_mode=2 auto_ds=2 amsdu_disable=1
```

**Wedge under sustained load:** if `dmesg` shows a pattern like this during heavy traffic, the driver is stuck in reset:

```
num_cmd_timeout = 1
woal_reset_adma: ADMA reset failed (value:97)
woal_reset_intf: get bss info failed
Block woal_cfg80211_deauthenticate in abnormal driver state
PCIe In-band Reset Fail
```

Power-save cycling is a suspected trigger. Set `ps_mode=0` (disables power save entirely) instead of `ps_mode=2` in the insmod command above if you hit this - reported to hold up under sustained load where `ps_mode=2` did not.
