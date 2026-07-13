# Hardware Overview

## SoC

**AMD Oberon** - custom APU.

- CPU: 8 cores / 16 threads, Zen 2 @ 3.5 GHz (boost via ps5_control), `schedutil` cpufreq governor by default
- GPU: RDNA2, 36–40 active CUs depending on unit (harvested CUs unlockable via kernel param), PCI ID `1002:13fb`, boost to 2.23 GHz via ps5_control
- RAM: 16 GB GDDR6 (unified memory) - ~14 GB usable by the OS, remainder reserved for firmware/VRAM

## Storage

- Internal NVMe: 825 GB (not touched by Linux install)
- M.2 slot: compatible with standard M.2 SSDs (FW 4.00+ only) - see [M.2 Setup](/guide/usb-storage#m2-setup)
- BD-ROM drive: Salina AHCI controller (`104d:9105` / `104d:9106`), driver `ahci_salina` - working

## Video

- HDMI 2.1 - 1080p, 1440p, 2160p at 60 Hz broadly supported; 1440p@120 Hz confirmed on DELL S3225QC
- amdgpu driver handles display output
- HW video decode (VCN): not available - see [GPU](/guide/gpu)

## Networking

- Ethernet: MediaTek Star GbE / Salina GBE (`104d:9104`), driver `mts` - works out of the box, see [Ethernet](/guide/ethernet)
- WiFi: Marvell IW620 (`1b4b:2b56`), driver `moal` - see [WiFi](/guide/wifi)

::: warning Salina chip revision
Boards use one of two Salina revisions for the wireless combo chip - not tied to a specific console model, varies unit to unit. Check yours with:

```bash
dmesg | grep spcie0
```

`0x11xxxxx` = Salina rev1 (Marvell) - currently supported. `0x12xxxxx` = Salina rev2 (MediaTek on most units, though some rev2 boards are still Marvell) - unsupported for WiFi/BT driver work in progress.
:::

## Audio

- HDMI audio: AMD/ATI `1002:13ea` - working
- HD Audio Coprocessor: AMD Ariel `1022:13eb` - unknown status

## USB

- Type-A (2 port, USB 3.1 Gen2): AMD Ariel `1022:13ee`
- Type-C (1 port, USB 3.1 Gen2 + DP Alt Mode): AMD Ariel `1022:13ed`
- Front bottom Type-C - recommended boot port
- Rear Type-A - usable for boot and peripherals
