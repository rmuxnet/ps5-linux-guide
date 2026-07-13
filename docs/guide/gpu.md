# GPU (AMD Oberon / RDNA2)

PCI ID: `1002:13fb`

## Status

- amdgpu loads and drives HDMI output - working
- Hardware video decode (VCN) - not working (IP block not registered)

::: tip Required modprobe options for a working display
The known-working distro images ship `/etc/modprobe.d/ps5-amdgpu.conf` with:
```
options amdgpu dpm=0 gpu_recovery=0
```
Ports missing this (seen on an in-progress Fedora build) hit no-video/black-screen bugs. If you're porting a new distro or building from scratch, add this file first before chasing other display issues.
:::

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

Verify after unlocking:

```
sudo dmesg | grep active_cu_number
```

::: info CU count must match per shader engine
The two shader engines (SE) need the same active CU count for the extras to actually get used, 38 CU (uneven split across SEs) benchmarks identically to 36 CU. If you see graphical glitches after unlocking, try `RADV_DEBUG=nohiz` in Steam launch options first, and 38 CU instead of 40 if that doesn't help.
:::

::: warning Harvested CUs come in pairs, some can be faulty
Disabled CUs are harvested in blocks of two, so a real unit's usable count is always 36, 38, or 40, never an odd number in between. If enabling all 40 causes severe visual artifacts, one of your harvested pairs may be silicon-faulty rather than just yield-disabled. You'll need to trial-and-error which pair by testing 38 with different CUs masked off, there's no known correlation between which pair fails and anything else about the unit.
:::

(2 × 2 × 10 = 40 total physical CUs, 36 active by default on this unit)

To unlock all CUs, add to `cmdline.txt` on the FAT32 USB partition:

```
amdgpu.ps5_cu_unlock=3
```

The patch writes to both the CC register and SPI - both are required for the unlock to actually affect dispatch (verified on BC-250).

Source: [ps5-linux-patches commit 5b0dc56](https://github.com/ps5-linux/ps5-linux-patches/commit/5b0dc56c1b37a01dd813cb0f58cd4ae2fc6ed45a)

### Runtime Unlock via UMR (No Kernel Rebuild)

[UMR](https://gitlab.freedesktop.org/tomstdenis/umr) (the AMD GPU register debugger) can enable the extra CUs at runtime without a kernel patch or rebuild, useful for quickly testing before committing to a kernel-level unlock. Available via AUR on Arch, RPM on Fedora/Bazzite, compile from source on Debian-based distros.

Verify the topology looks unlocked with `umr`, but note the topology output may still show the CUs as disabled even when the runtime unlock is active, check benchmark scores to confirm it actually took effect rather than trusting the topology display alone.

## Underperforming vs BC-250 (open investigation)

Superposition scores land noticeably below the theoretical scaling from BC-250 numbers (PS5 has 36-40 CU vs BC-250's 24, expected ~5700-6450pts scaling linearly, actual scores land closer to 5100-5300 even at 40CU+boost). Root cause not confirmed. dmesg does report all 36 CUs detected correctly, so it isn't a detection issue.

At matched CU count and clock, BC-250 consistently beats PS5:

| Config | PS5 (boost mode) | BC-250 |
|---|---|---|
| 36 CU @ ~2200MHz | 5040 pts | 5330 pts |
| 40 CU @ ~2200MHz | 5290 pts | 5530 pts |

Leading theory is boost mode isn't holding a constant clock (non-boost scores track much closer between the two platforms).

::: danger Unconfirmed, caused a black screen on test
One theory floated: `adev->gfx.cu_info.lds_size = 128;` in `amdgpu_device.c`. A tester who tried it got a black screen with no amdgpu driver output after rebuild, root cause unclear. Not a working fix, listed here so nobody re-discovers the same dead end blind.
:::

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

::: warning What `vram.txt` actually controls
Every VRAM split is dynamic, 512MB is **not** a special "fully dynamic" mode. The `vram.txt` value only sets the *minimum* hard-allocated VRAM, it does not cap the maximum. The real maximum dynamic allocation ceiling is `(vram.txt split) + (leftover RAM not in that split) / 2`, which is why some games that use just over 8GB VRAM (FF7 Remake is a known example) crash with `amdgpu_vm_validate() failed / Not enough memory for command submission` even though "plenty" of RAM is technically free.

**Real fix:** raise the GTT ceiling directly with the `ttm.pages_limit` kernel boot parameter instead of (or alongside) bumping `vram.txt`:

```
ttm.pages_limit = (desired GTT size in GB) * 1024 * 1024 / 4
```

Best practice is to leave `vram.txt` at the low default (512MB) and raise `ttm.pages_limit` instead of raising `vram.txt` itself, same effective ceiling without permanently locking that RAM away from the rest of the system when you're not gaming.

Example, 10GB GTT ceiling:

```
ttm.pages_limit=2621440
```
:::

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
- If you see graphical issues in games, set `RADV_DEBUG=nohiz` (same recommendation as AMD BC250). Worth setting this in your shell profile/environment globally rather than per-game, several games have issues without it and it's easy to forget on a fresh Steam library entry
- Many tips from [AMD BC250 Documentation](https://elektricm.github.io/amd-bc250-docs/) apply to PS5 too, but double-check anything VRAM/GTT-allocation related against this page's [VRAM](#vram) section specifically, that page has been reported to have inaccurate/LLM-generated info on how the VRAM split actually works
