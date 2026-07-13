# USB & Storage

## USB Ports

| Port | Type | Speed | Boot? |
|---|---|---|---|
| Front bottom | Type-C | USB 3.x | Recommended |
| Front top | Type-A | USB 2.0 | Possible (slow) |
| Rear | Type-A | USB 3.x | Yes |

All ports usable for peripherals once booted.

## Recommended USB Hubs / Docks

Confirmed working with full port functionality:

- **Startech 10G2A1C25EPD-USB-HUB** - USB-C, 2x USB-A, 2.5GbE fully utilized by Linux
- **Dell WD19TBS Dock** (latest firmware) - USB-C, all USB-A ports, 1GbE fully utilized (also works via a USB 3.1 Type-A-to-C OTG adapter, not just direct Type-C)
- **Orico PW11-6PR** (6-in-1 dock) - Gigabit ethernet and 3x USB-A confirmed working, HDMI port untested

## USB Ethernet/WiFi Adapters

Any adapter with a Linux driver works, since this is a regular Linux environment, but the following are confirmed by users:

- **FENVI 1800Mbps WiFi 6 USB adapter** (MT7921 chip) - works out of the box, no config needed
- **TP-Link Archer TX10UB Nano** (AX900, WiFi 6 + BT 5.3) - WiFi confirmed working smoothly

See [Ethernet](/guide/ethernet) for the RTL8156B chipset recommendation on wired USB adapters specifically.

::: warning eGPU is not possible
An M.2-to-PCIe riser for an eGPU has been asked about and confirmed **not supported**, don't expect this to work.
:::

## USB Drive (Required)

Minimum 64 GB reccomended. If you only have a small USB drive, see [M.2 from Small USB](#m2-from-small-usb-no-64-gb-drive-available) below.

If an M.2 enclosure is not being detected, try a different cable (USB 3.x) and a different port before assuming the drive is faulty.

::: warning Reported: rear USB ports stop detecting M.2 enclosures on newer kernels
Multiple users report an M.2 enclosure that worked fine on the rear Type-A ports on an older kernel only gets detected on the front Type-C port after updating. Not yet confirmed as a kernel regression vs. hardware/cable variance, if you hit "no signal"/no-detect on rear ports, try the front Type-C port first before troubleshooting further.
:::

::: warning Enclosure won't power back on after sleeping
If your external SSD enclosure goes into its own sleep mode after the payload launches, it may not power back on, this can look like a bad SSD image, bad HDMI, or a dead TV when the actual cause is the enclosure. Disable automatic screen/display sleep so the enclosure stays active: `Settings` -> `Power` -> `Automatic Screen Blank` -> `Off` (Ubuntu).
:::

::: tip Drive shows way less free space than its actual capacity
The rootfs partition is sparse, it starts small and is meant to grow into the drive. If `df` shows only a few GB free on a much bigger drive, grow the filesystem to fill it:

```bash
sudo resizefs2 /dev/sda1
```

Confirmed working, adjust the device/partition to match your actual drive.
:::

## M.2 Compatibilty

**NVMe only. SATA M.2 drives do not work** - confirmed not working regardless of adapter or enclosure.

Gen3 NVMe drives are **officially unsupported** by Sony but can be unlocked. See [Gen3 NVMe Unlock](#gen3-nvme-unlock) below. Sub-250 GB drives also work once unlocked.

Community-tested drive compatibility: [M.2 Compatibility List](/guide/m2-compat) - also the original [spreadsheet](https://docs.google.com/spreadsheets/d/1z35NT5GuQMwAh5G4U8cvb-FTG9SbWVAy07kW6v8dCk0/edit?usp=sharing)

## Gen3 NVMe Unlock

Sony blocks Gen3 NVMe drives in PS5 claiming they're too slow (5500 MB/s minimum). In practice the performance difference is ~1-2 seconds on loading screens - not a real issue, especially for Linux.

The PS5 checks a small header at the start of the drive. Writing the first 2 MB from any PS5-formatted Gen4 drive onto your Gen3 drive bypasses the check entirely.

**What you need:**
- A Gen4 NVMe that has been formatted by a PS5 (or use a pre-made dump)
- Your Gen3 NVMe
- A USB NVMe enclosure or a PC with an M.2 slot

**Steps:**

```bash
# 1. Put the Gen4 drive in your enclosure, connect to PC
# Dump the first 2 MB
sudo dd if=/dev/sdX of=ps5_gen4_header.bin bs=1M count=2

# 2. Swap to your Gen3 drive
# Write the header to it
sudo dd if=ps5_gen4_header.bin of=/dev/sdX bs=1M count=2
```

Then put the Gen3 drive in the PS5. It will be detected and formatted normally.

::: tip No Gen4 drive? Use Bringus' dump
Bringus Studios documented this method and provides a pre-made 2 MB dump in the video description: [youtube.com/watch?v=Uds315QBUnE](https://www.youtube.com/watch?v=Uds315QBUnE)

Note: pre-made dumps may not work on higher firmwares. If it doesn't work, borrow a Gen4 drive and take your own dump.
:::

::: warning Do not reformat the Gen3 drive on PS5
Reformatting via PS5 Settings → Storage wipes the unlocked header. If you do it by accident, just redo the 2 MB write from PC.
:::

**Firmware compatibility:** Confirmed working on 4.00, 4.03, 4.51. Failed reports on 5.xx and above are suspected user error - most likely using the wrong dump. If it doesn't work, take your own dump from a PS5-formatted Gen4 drive instead of using a shared one. See [M.2 Compatibility](/guide/m2-compat) for full results.

## M.2 Setup

Available on FW 4.00+. M.2 is used exclusively for Linux - cannot be used for PS5 game storage simultaneously.

Install your M.2 following [Sony's official guide](https://www.playstation.com/en-us/support/hardware/ps5-install-m2-ssd). If it was previously used for games, reformat it first: `Settings` → `Storage` → `M.2 SSD Storage`.

**Initialize the M.2 from Linux:**

```bash
cd ps5-linux-tools
sudo ./m2_init
sudo reboot
```

If PS5 asks you to format the M.2 again after reboot, report it in Discord with your M.2 model and size.

::: tip Switching distros doesn't require reformatting from PS5 OS
Formatting the M.2 from PS5 settings only performs a "soft" format, it overwrites the LBAs PS5 itself needs and leaves your Linux partition alone. To switch distros you can just reformat directly from Linux instead (`sudo mkfs.ext4 /dev/nvme1` or your target filesystem) and reinstall, no need to go through PS5 OS first.
:::

**Install Linux image onto M.2:**

```bash
cd ps5-linux-tools
chmod +x ./m2_install.sh
sudo ./m2_install.sh --install /path/to/ps5-ubuntu2604.img
```

**Boot from M.2:**

```bash
cd ps5-linux-tools
chmod +x ./m2_exec.sh
sudo ./m2_exec.sh
```

To always boot from M.2, edit `/boot/efi/cmdline.txt` and change `root=LABEL=ubuntu2604` to `root=LABEL=ubuntu2604-m2`. You still need the USB drive for the FAT32 partition.

## M.2 from Small USB (No 64 GB Drive Available)

If you only have a small USB drive and can't flash the full image, use the community rsync-based script as an alternative to `m2_install.sh`:

[github.com/g4caos/ps5-linux-script](https://github.com/g4caos/ps5-linux-script)

It syncs the live running Linux session directly onto the M.2 instead of requiring a pre-built image file.
