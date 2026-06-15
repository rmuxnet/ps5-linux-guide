# Kernel Setup

The ps5-linux project ships a patched kernel via [ps5-linux-patches](https://github.com/ps5-linux/ps5-linux-patches). Pre-built packages are available as `.deb` or `.pkg.tar.zst`.

## Install Pre-built Kernel

Download from [ps5-linux-patches releases](https://github.com/ps5-linux/ps5-linux-patches/releases) and install normally:

```bash
# Debian/Ubuntu
sudo dpkg -i ps5-linux-*.deb

# Arch
sudo pacman -U ps5-linux-*.pkg.tar.zst
```

## Build from Source

```bash
git clone https://github.com/ps5-linux/ps5-linux-patches
git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
git checkout "tags/v$(grep -m1 '^# Linux/' ../ps5-linux-patches/.config | awk '{print $3}')"
git apply ../ps5-linux-patches/linux.patch
cp ../ps5-linux-patches/.config .config
make -j$(nproc)
sudo make modules_install
sudo make install
```

## Pending in ps5-linux-patches

- amdgpu SMU driver: correct GPU frequency and temperature reporting
- HDMI converter: HDR, RGB range, 120 Hz improvements

## Cmdline

Kernel cmdline is in `cmdline.txt` on the FAT32 partition of your USB drive. Edit it to pass custom parameters:

```
# Force 1080p if display not detected correctly
amdgpu.force_1080p=1

# Remove this line if you get black screen
video=DP-1:1920x1080@60
```

## VRAM

Default VRAM allocation is 512 MB (dynamic). To change, edit `vram.txt` on the FAT32 partition. See [AMD BC250 docs](https://elektricm.github.io/amd-bc250-docs/bios/flashing/#why-flash-the-bios) for details.
