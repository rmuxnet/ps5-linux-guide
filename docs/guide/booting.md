# Booting Linux

## 1. Get a Linux Image

### Available distros

| Distro | Desktop | Notes |
|---|---|---|
| Ubuntu 26.04 (default) | GNOME | Recommended for beginners |
| Arch | Sway | Low overhead, low RAM usage (~750 MiB idle) |
| CachyOS | Gamescope + Steam Big Picture, KDE Plasma (no SDDM) | Gaming-focused |
| Fedora | GNOME (Wayland) | |
| Debian 12 | XFCE | Successor to the old Kali-based image |
| Proxmox VE 8 | headless | Runs PS5 as a hypervisor, no desktop |
| Bazzite | Gamescope + Steam | uBlue gaming Fedora, ostree-flattened |
| Bazzite Deck | Gamescope + Steam, Deck-like UI | Bazzite's Steam Deck interface variant |
| Batocera | retro emulation frontend | Pre-built squashfs rootfs |

You can also build a **multi-distro image** with kexec switching between Ubuntu, Arch, and CachyOS on the same USB.

### Pre-built

Download from [ps5-linux-image releases](https://github.com/ps5-linux/ps5-linux-image/releases/tag/latest). Grab the `.img.xz` for your chosen distro and unpack it.

### Build your own

Requires Docker and ~30 GB free disk space.

```bash
# Windows: run in WSL first (wsl --install)
sudo apt update && sudo apt install docker.io -y
sudo service docker start
sudo usermod -aG docker $USER
newgrp docker

git clone https://github.com/ps5-linux/ps5-linux-image
cd ps5-linux-image
chmod +x ./build_image.sh

# Single distro: ubuntu2604, arch, cachyos, fedora, debian, proxmox,
# bazzite, bazzite-deck, batocera
./build_image.sh --distro ubuntu2604
./build_image.sh --distro cachyos

# Multi-distro (Ubuntu + Arch + CachyOS, 32 GB image)
./build_image.sh --distro all

# Build just the kernel packages (.deb / .pkg.tar.zst), no image
./build_image.sh --kernel-only

# Build against a specific ps5-linux-patches branch/tag/commit
./build_image.sh --distro arch --patches-ref main
```

Output is written to `output/` (kernel-only output goes to `linux-bin/`). Subsequent runs reuse cached kernel and rootfs automatically; use `--clean` to wipe and start fresh.

::: tip WSL running out of memory during build?
Create or edit `C:\Users\<you>\.wslconfig` and raise the memory limit:
```ini
[wsl2]
memory=8GB
```
Then restart WSL: `wsl --shutdown`
:::

### Editing cmdline.txt from Windows

**Without WSL:** Use [Explorer++](https://explorerplusplus.com/) (run as admin) - it can access the FAT32 EFI partition directly where `cmdline.txt` lives.

**With WSL:**

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

**Windows:** Use [Rufus](https://rufus.ie/). Balena Etcher has known issues flashing PS5 images - use Rufus instead.

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

::: warning Ubuntu - black screen before user creation
Ubuntu has no default user. If you get a black screen before completing setup, you cannot SSH in to debug because there is no user to log in as. If this happens, chroot into the install from another Linux environment to create a user first - see [Recovering via Chroot](/guide/booting#recovering-via-chroot).
:::

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

## Recovering via Chroot

If you can't boot but have access to another Linux environment (USB boot, another machine via SSH, etc.), you can chroot into your install to fix things.

**Find your partition:**
```bash
lsblk -f
# Look for the ext4 partition - nvme0n1p3 for M.2, sdXN for USB drive
```

```bash
# M.2 install
sudo mkdir -p /mnt/ps5root
sudo mount /dev/nvme0n1p3 /mnt/ps5root

sudo mount --bind /dev  /mnt/ps5root/dev
sudo mount --bind /proc /mnt/ps5root/proc
sudo mount --bind /sys  /mnt/ps5root/sys
sudo mount --bind /run  /mnt/ps5root/run

sudo chroot /mnt/ps5root

# do your fixes here, then:
exit

sudo umount /mnt/ps5root/{run,dev,proc,sys}
sudo umount /mnt/ps5root
```

**Common fixes inside chroot:**
- Reinstall kernel: `dpkg -i /tmp/linux-ps5_*.deb`
- Create user: `adduser <username>` then `usermod -aG sudo <username>`
- Fix permissions: `chown -R user:user /home/user`

### Kernel Reinstall (USB drive)

If you broke your external USB drive and can't boot, reinstall the kernel `.deb` via chroot.

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
