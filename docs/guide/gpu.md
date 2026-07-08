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

For heavier loads or if you're chasing higher sustained boost clocks, `--fan max`
runs the fan stronger than plain `on`:

```bash
sudo ./ps5_control --fan max
```

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

Without the unlock parameter, dmesg reports the hardware-default active CU count:

```
amdgpu: SE 2, SH per SE 2, CU per SH 10, active_cu_number 36
```

(2 × 2 × 10 = 40 total physical CUs, 36 active by default on this unit)

To unlock all CUs, add to `cmdline.txt` on the FAT32 USB partition:

```
amdgpu.ps5_cu_unlock=3
```

The patch writes to both the CC register and SPI - both are required for the unlock to actually affect dispatch (verified on BC-250).

Source: [ps5-linux-patches commit 5b0dc56](https://github.com/ps5-linux/ps5-linux-patches/commit/5b0dc56c1b37a01dd813cb0f58cd4ae2fc6ed45a)

## VCN / Hardware Video Decode

amdgpu for `1002:13fb` does not register the `vcn_v3_0` IP block. Mesa, VAAPI, and ffmpeg userspace are fine - the kernel driver simply never exposes VCN. Software decode only for now.

**Known fix (not yet upstream):** patch `drivers/gpu/drm/amd/amdgpu/nv.c` to add `vcn_v3_0` for `0x13fb` and rebuild the kernel. Tracked in [ps5-linux-patches TODO](https://github.com/ps5-linux/ps5-linux-patches#todo).

## VRAM

Default allocation shown in tools is 512MB, but this is **dynamic** - the driver escalates and allocates more as needed. With 16GB shared RAM/VRAM, the GPU can use up to ~12GB in practice.

To set a fixed allocation, edit `vram.txt` on the FAT32 USB partition. The
loader reads this as **hex bytes**, not decimal MB - `strtoull(buf, NULL, 16)`
in `ps5-linux-loader/source/loader.c`. A decimal MB value here silently
mis-sets VRAM to almost nothing (a common cause of black screen on boot).

Default (512MB):

```
20000000
```

| Size | vram.txt value |
|---|---|
| 512MB (default) | `20000000` |
| 1GB | `40000000` |
| 2GB | `80000000` |
| 4GB | `100000000` |
| 8GB | `200000000` |

## Equivalent Hardware

| Component | Equivalent |
|---|---|
| GPU | AMD RX 6700 (non-XT) - 36 CU, similar clocks |
| CPU | ~AMD Ryzen 2700 (downclocked Zen 2, 8c/16t) |

## Benchmarks (Superposition 1080p Extreme)

| Config | Score | Notes |
|---|---|---|
| No boost | 4903 | GPU @ 3193 MHz |
| Fan + boost, no CU unlock | ~5150 | |
| 40 CU + fan + boost | 5041 | GPU @ 3493 MHz actual, kernel 7.0.10 |
| 40 CU + fan + boost (CFI-1216A) | 5259 | 6nm APU, highest seen |

BC250 reference: 36CU@2200MHz = ~5336, 40CU@2200MHz = ~5530. Boost mode on PS5 may not always sustain full clock speed depending on thermals.

## Performance Tips

- Remove `idle=halt` from `cmdline.txt` if you notice microstuttering - theflow asked community to test this
- If you see graphical issues in games, set `RADV_DEBUG=nohiz` (same recommendation as AMD BC250)
- Many tips from [AMD BC250 Documentation](https://elektricm.github.io/amd-bc250-docs/) apply to PS5 too
