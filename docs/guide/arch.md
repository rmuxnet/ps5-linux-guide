# Kernel Setup Arch Linux

The ps5-linux project ships a patched kernel via [ps5-linux-patches](https://github.com/ps5-linux/ps5-linux-patches). Pre-built packages are available as `.pkg.tar.zst` for Arch Linux based distributions.

## 1. Install Pre-built Kernel

Download from [ps5-linux-patches releases](https://github.com/ps5-linux/ps5-linux-patches/releases) and install normally:

```bash
# Arch based distributions
sudo pacman -U ps5-linux-*.pkg.tar.zst

```

## 2. Compiling the Kernel

First, clone the repositories, apply the PS5 Linux patches, and run the compilation.

::: warning Check for the Latest Kernel Version
Do not blindly copy the checkout version below. Always check the official [ps5-linux-patches Releases page](https://github.com/ps5-linux/ps5-linux-patches/releases) to see what the current supported kernel version is (for example, `v7.0.10`), and replace `v7.0.10` with the newest tag.
:::

# Clone the patch repository and the stable Linux kernel
```bash
git clone https://github.com/ps5-linux/ps5-linux-patches
git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
```

# Navigate to the kernel directory
```bash
cd linux
```

# Replace v7.0.10 with the latest version found on the releases page
```bash
git checkout tags/v7.0.10
```
# Apply patches and copy configuration

```bash
git apply ../ps5-linux-patches/linux.patch
cp ../ps5-linux-patches/.config .config
```

# Prepare and build the kernel using all available CPU cores
```bash
make olddefconfig
make -j$(nproc)
```

## Generating the Initrd & Storage Setup

After compilation, you need to generate your initial ramdisk (initrd) image. 

::: info Keep Track of Your Version
When generating the initrd and copying files, the `$(make kernelrelease)` command dynamically fetches your kernel version (e.g., `7.0.10`). Ensure your compilation steps above finished successfully so this variable resolves correctly.
:::

```bash
sudo mkinitcpio -k "$(make kernelrelease)" -g /boot/initrd.img-$(make kernelrelease) || true
```
# Backup your old boot images just in case
```bash
sudo mv /boot/efi/bzImage /boot/efi/bzImage.old
sudo mv /boot/efi/initrd.img /boot/efi/initrd.img.old
```

# Copy the newly compiled kernel and generated initrd
```bash
sudo cp ~/linux/arch/x86/boot/bzImage /boot/efi/bzImage
sudo cp /boot/initrd.img-$(make kernelrelease) /boot/efi/initrd.img
```
# Flush file system buffers to ensure data is safely written
```bash
sync
```