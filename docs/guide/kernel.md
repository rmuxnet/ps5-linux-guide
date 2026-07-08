# Kernel Setup

The ps5-linux project ships a patched kernel via [ps5-linux-patches](https://github.com/ps5-linux/ps5-linux-patches). Pre-built packages are available as `.deb` for Debian/Ubuntu.

## 1. Install Pre-built Kernel

Download from [ps5-linux-patches releases](https://github.com/ps5-linux/ps5-linux-patches/releases) and install normally:

```bash
# Debian/Ubuntu
sudo dpkg -i ps5-linux-*.deb
```

## 2. Build from Source

### Dependencies

GCC works, but Clang/LLVM is recommended.

**Arch Linux:**
```bash
# Clang (recommended)
sudo pacman -S clang llvm lld pahole bison flex bc cpio python openssl

# GCC
sudo pacman -S gcc pahole bison flex bc cpio python openssl
```

**Debian/Ubuntu:**
```bash
# Clang (recommended)
sudo apt install clang llvm lld dwarves bison flex bc cpio python3 libssl-dev libelf-dev

# GCC
sudo apt install gcc dwarves bison flex bc cpio python3 libssl-dev libelf-dev
```

### Build

```bash
git clone https://github.com/ps5-linux/ps5-linux-patches
git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
git checkout "tags/v$(grep -m1 '^# Linux/' ../ps5-linux-patches/.config | awk '{print $3}')"
git apply ../ps5-linux-patches/linux.patch
cp ../ps5-linux-patches/.config .config

# With Clang (recommended)
make LLVM=1 LLVM_IAS=1 -j$(nproc)

# With GCC
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

Default shipped cmdline (varies slightly per image):

```
root=LABEL=__DISTRO__ rw rootwait console=ttyTitania0 console=tty0 mitigations=off idle=halt preempt=full
```

- `console=ttyTitania0` - Sony's internal name for the UART serial console, useful if you're debugging headless over UART
- `mitigations=off` - Spectre/Meltdown mitigations disabled by default for performance; add `mitigations=auto` if you want them back
- `idle=halt` - see [Performance Tips](/guide/gpu#performance-tips) if you notice microstuttering

## VRAM

Default VRAM allocation is 512 MB (dynamic). To change, edit `vram.txt` on the FAT32 partition - value is a **hex byte count**, not decimal MB, see [GPU: VRAM](/guide/gpu#vram) for the correct format and a size table. See [AMD BC250 docs](https://elektricm.github.io/amd-bc250-docs/bios/flashing/#why-flash-the-bios) for details.
