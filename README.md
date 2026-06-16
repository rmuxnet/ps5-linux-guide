# What is this?

Community guide for running Linux on the **PlayStation 5** (Phat model only).

Uses patched HV vulnerabilities to boot a full Linux desktop. Internal SSD is untouched - you can still use PS5 OS normally.

> [!WARNING]
> **Currently documented:** PS5 Phat, FW 3.00–6.02
> 
> Whether higher firmware or other models will ever be supported—we genuinely don't know, and we don't want to jinx anything.

![PS5 running Arch Linux with kernel 7.1.0](/docs/public/screenshot-arch.webp)

## Hardware Status

| Component | Status |
|---|---|
| HDMI 4K60 video + audio | ✓ Working |
| USB ports | ✓ Working |
| Ethernet (custom driver) | ✓ Working |
| AMD GPU (amdgpu / RDNA2) | ✓ Working |
| M.2 SSD | ✓ Working (FW ≥4.00) |
| CPU boost (3.5 GHz) | ✓ via ps5_control |
| GPU boost (2.23 GHz) | ✓ via ps5_control |
| GPU CU unlock (up to 40) | ✓ Working |
| WiFi (IW620 / mwifiex) | ~ Working, some instability |
| BD-ROM drive (ahci_salina) | ✓ Working |
| DualSense (USB) | ✓ Working |
| HW Video Decode (VCN) | ✗ Not working |
| Screen saver | ✗ Broken |
| CachyOS distro | ✗ Currently broken (kernel panic) |

## Resources

- [This guide on GitHub](https://github.com/rmuxnet/ps5-linux-guide) - corrections and additions welcome
- [ps5-linux org](https://github.com/ps5-linux)
- [ps5-linux-loader](https://github.com/ps5-linux/ps5-linux-loader)
- [ps5-linux-patches](https://github.com/ps5-linux/ps5-linux-patches)
- [ps5-linux-tools](https://github.com/ps5-linux/ps5-linux-tools)
- [ps5-linux-mwifiex](https://github.com/ps5-linux/ps5-linux-mwifiex)
- [ps5-linux-image](https://github.com/ps5-linux/ps5-linux-image)
- [ps5-linux-image (mia's builds)](https://git.etawen.dev/mia/ps5-linux-image)
- [Discord](https://discord.gg/PeMGVB7BAm)
- [Video guide by Modded Warfare](https://www.youtube.com/watch?v=4Iix8SaJtaM)
