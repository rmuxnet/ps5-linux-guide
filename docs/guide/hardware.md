# Hardware Overview

## SoC

**AMD Oberon** - custom APU.

- CPU: 8 cores / 16 threads, Zen 2 @ 3.5 GHz (boost via ps5_control)
- GPU: RDNA2, 36–40 active CUs depending on unit (harvested CUs unlockable via kernel param), PCI ID `1002:13fb`, boost to 2.23 GHz via ps5_control
- RAM: 16 GB GDDR6 (unified memory)

## Storage

- Internal NVMe: 825 GB (not touched by Linux install)
- M.2 slot: compatible with standard M.2 SSDs (FW 4.00+ only) - see [M.2 Setup](/guide/usb-storage#m2-setup)
- BD-ROM drive: Salina AHCI controller (`104d:9105` / `104d:9106`), driver `ahci_salina` - working

## Video

- HDMI 2.1 - 1080p, 1440p, 2160p at 60 Hz broadly supported; 1440p@120 Hz confirmed on DELL S3225QC
- amdgpu driver handles display output
- HW video decode (VCN): not available - see [GPU](/guide/gpu)

## Networking

- Ethernet: MediaTek Star GbE (`104d:9104`), driver `mts` - works out of the box, see [Ethernet](/guide/ethernet)
- WiFi: IW620 (mwifiex) - see [WiFi](/guide/wifi)

## USB

- Front bottom: Type-C (USB 3.x) - recommended boot port
- Front top: Type-A (USB 2.0) - slower, not recommended for boot
- Rear: Type-A (USB 3.x) - usable for boot and peripherals
