# GPU (AMD Oberon / RDNA2)

PCI ID: `1002:13fb`

## Status

- amdgpu loads and drives HDMI output - working
- Hardware video decode (VCN) - not working (IP block not registered)

## Boost

Default GPU clock is lower than PS5 OS. Use ps5_control to unlock full speed:

```bash
cd ps5-linux-tools
sudo ./ps5_control --fan on
sudo ./ps5_control --boost on
```

Always enable fan alongside boost - this matches PS5 OS behavior.

To enable at boot:

```bash
sudo ./install.sh
```

This installs `ps5fan.service` and `ps5boost.service` as systemd units.

## 40 CU Unlock

PS5 units ship with either 36 or 38 active CUs out of 40 total - the remainder are harvested (disabled) in silicon. How many CUs your unit actually has is **hardware-specific**: some consoles physically cap at 38, some have all 40. This also means benchmark scores vary between units. The ps5-linux kernel patch unlocks whichever harvested CUs are present.

**Kernel parameter:** `amdgpu.ps5_cu_unlock=N`

| Value | Behavior |
|---|---|
| 0 | Off (default) |
| 1 | Probe |
| 2 | Unlock SE0/SH0 only |
| 3 | Unlock all harvested CUs |
| 4 | Probe-all |

To unlock all CUs, add to `cmdline.txt` on the FAT32 USB partition:

```
amdgpu.ps5_cu_unlock=3
```

The patch writes to both the CC register and SPI - both are required for the unlock to actually affect dispatch (verified on BC-250).

Source: [ps5-linux-patches commit 5b0dc56](https://github.com/ps5-linux/ps5-linux-patches/commit/5b0dc56c1b37a01dd813cb0f58cd4ae2fc6ed45a)

## VCN / Hardware Video Decode

amdgpu for `1002:13fb` does not register the `vcn_v3_0` IP block. Mesa, VAAPI, and ffmpeg userspace are fine - the kernel driver simply never exposes VCN. Software decode only for now.

**Known fix (not yet upstream):** patch `drivers/gpu/drm/amd/amdgpu/nv.c` to add `vcn_v3_0` for `0x13fb` and rebuild the kernel. Tracked in [ps5-linux-patches TODO](https://github.com/ps5-linux/ps5-linux-patches#todo).

## Tips

- If you see graphical issues in games, set `RADV_DEBUG=nohiz` (same recommendation as AMD BC250).
- VRAM size defaults to 512 MB (dynamic VRAM allocation). Adjust in `vram.txt` on the FAT32 USB partition.
- Many tips from [AMD BC250 Documentation](https://elektricm.github.io/amd-bc250-docs/) apply to PS5 too.
