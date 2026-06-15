# Booting Linux

## 1. Get a Linux Image

### Available distros

| Distro | Desktop | Notes |
|---|---|---|
| Ubuntu 26.04 (default) | GNOME | Reccomended for beginners |
| Arch | Sway | Minimal, rolling |
| CachyOS | Gamescope + Steam Big Picture | Gaming-focused |
| Kali Linux | XFCE + kali-linux-everything | ~96 GB image, needs ~150 GB free to build |
| Fedora | GNOME | |
| Bazzite | Gamescope + Steam (Deck-like) | Community builds, not in official image builder |

You can also build a **multi-distro image** with kexec switching between Ubuntu, Arch, and CachyOS on the same USB.

### Pre-built

Download from [ps5-linux-image releases](https://github.com/ps5-linux/ps5-linux-image/releases/tag/latest). Grab the `.img.xz` for your chosen distro and unpack it.

### Build your own

Requires Docker and ~30 GB free disk space (Kali needs ~150 GB).

```bash
# Windows: run in WSL first (wsl --install)
sudo apt update && sudo apt install docker.io -y
sudo service docker start
sudo usermod -aG docker $USER
newgrp docker

git clone https://github.com/ps5-linux/ps5-linux-image
cd ps5-linux-image
chmod +x ./build_image.sh

# Single distro
./build_image.sh --distro ubuntu2604
./build_image.sh --distro cachyos
./build_image.sh --distro kali

# Multi-distro (Ubuntu + Arch + CachyOS, 32 GB image)
./build_image.sh --distro all
```

Output is written to `output/`. Subsequent runs reuse cached kernel and rootfs automatically.

::: tip WSL running out of memory during build?
Create or edit `C:\Users\<you>\.wslconfig` and raise the memory limit:
```ini
[wsl2]
memory=8GB
```
Then restart WSL: `wsl --shutdown`
:::

### Editing cmdline.txt from Windows (WSL)

To mount the FAT32 partition of the PS5 USB in WSL and edit `cmdline.txt`:

```bash
# Attach the physical drive to WSL (run in PowerShell as admin first)
# Get the drive number with: GET-CimInstance -query "SELECT * from Win32_DiskDrive"
wsl --mount \\.\PHYSICALDRIVE1 --partition 1 --type vfat

# Then in WSL
ls /mnt/wsl/PHYSICALDRIVE1p1/
nano /mnt/wsl/PHYSICALDRIVE1p1/cmdline.txt
```

## 2. Flash to USB

Drive must be 64 GB+. External SSD is strongly reccomended.

**Linux/macOS:**
```bash
# Find your drive with lsblk / diskutil list
sudo dd if=ps5-ubuntu2604.img of=/dev/sdX bs=4M status=progress conv=fsync
```

**Windows:** Use [Balena Etcher](https://etcher.balena.io/).

## 3. Plug USB into PS5

Supported boot ports:
- Front bottom Type-C port
- Rear Type-A ports

The front top Type-A port is USB 2.0 - slower, not recommended.

## 4. Run the Jailbreak

See [Jailbreak](/guide/jailbreak).

## 5. Send the Payload

Download [ps5-linux-loader.elf](https://github.com/ps5-linux/ps5-linux-loader/releases/) or build it:

```bash
# ARM64 hosts need cross-compilation tools first:
sudo apt install gcc-x86-64-linux-gnu binutils-x86-64-linux-gnu

git clone https://github.com/ps5-linux/ps5-linux-loader
cd ps5-linux-loader
make
```

Send it (replace `$PS5IP` with your PS5's IP shown on screen):

```bash
socat -t 99999999 - TCP:$PS5IP:9021 < ps5-linux-loader.elf
```

## Reading the LED

| LED | Meaning |
|---|---|
| Orange blinking | Going into rest mode (wait) |
| Orange static | Ready - press power button now |
| White | Linux booted |
| Back to PS5 OS | Power button pressed too early, or USB power in rest mode not set |

## Troubleshooting Black Screen

- Remove `video=DP-1:1920x1080@60` from `cmdline.txt` on the FAT32 partition
- Add `amdgpu.force_1080p=1` to `cmdline.txt`
- Toggle HDCP on/off in PS5 settings (try both)
- Try a different monitor or capture card
- Report in [Discord](https://discord.gg/PeMGVB7BAm) with your EDID info

## First Boot

1. Set up your user account and password. Make sure you remeber it.
2. Disable the screen saver (currently broken).
3. Hold kernel packages to prevent accidental upgrades:
   ```bash
   sudo apt-mark hold linux-generic linux-generic-hwe-24.04 linux-generic-hwe-26.04 \
     linux-image-generic linux-image-generic-hwe-24.04 linux-image-generic-hwe-26.04 \
     linux-headers-generic linux-headers-generic-hwe-24.04 linux-headers-generic-hwe-26.04
   ```
4. Install Firefox:
   ```bash
   sudo snap install firefox
   ```
5. Update Mesa:
   ```bash
   sudo snap refresh mesa-2404 --channel=latest/edge
   sudo add-apt-repository ppa:kisak/kisak-mesa
   sudo apt update && sudo apt upgrade
   ```
6. Install ps5-linux-tools:
   ```bash
   sudo apt install zlib1g-dev
   git clone https://github.com/ps5-linux/ps5-linux-tools
   cd ps5-linux-tools
   make
   ```
7. Install the internal WiFi driver:
   ```bash
   git clone https://github.com/ps5-linux/ps5-linux-mwifiex
   cd ps5-linux-mwifiex
   sudo ./install.sh
   ```

## Recovering a Broken USB (Chroot Reinstall)

If you broke your external SSD and can't boot, you can reinstall the kernel `.deb` via chroot from another Linux machine or from another booted PS5 Linux instance.

```bash
sudo mkdir -p /mnt/usb
sudo mount /dev/sdXN /mnt/usb   # replace sdXN with your rootfs partition

sudo mount --bind /dev      /mnt/usb/dev
sudo mount --bind /dev/pts  /mnt/usb/dev/pts
sudo mount --bind /proc     /mnt/usb/proc
sudo mount --bind /sys      /mnt/usb/sys
sudo mount --bind /run      /mnt/usb/run

sudo cp ./linux-ps5_7.0.10_amd64.deb /mnt/usb/tmp/

sudo chroot /mnt/usb /bin/bash

cd /tmp
dpkg -i linux-ps5_7.0.10_amd64.deb
```
