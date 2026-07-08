# SSH & Getting Help

If something's broken and you want help in [Discord](https://discord.gg/PeMGVB7BAm),
SSH access plus a proper log dump gets you a real answer instead of "no wonder
you have black screen." This page covers both.

## SSH access by default

| Distro | SSH enabled out of the box | Root login | Password auth |
|---|---|---|---|
| Ubuntu 26.04 | Yes | No (use your user + sudo) | Yes |
| Arch | Yes | No | Yes |
| CachyOS | Yes | No | Yes |
| Fedora | Yes | No | Yes |
| Debian 12 | **No** - disabled by default (public default creds) | No | Yes |
| Proxmox VE | Yes | **Yes** (`root@pam`, headless hypervisor) | Yes |

On Debian, enable it yourself once you're at a desktop:

```bash
sudo systemctl enable --now ssh.service
```

Everywhere else it's already running - log in with the user account you
created on first boot.

## Find your PS5's IP

From the desktop, open a terminal:

```bash
ip -brief a
```

Look for the interface that's `UP` with an address in your LAN range
(`wlp*` for WiFi, `enp*` for Ethernet). If you have no display, check your
router's DHCP client list for a device named after your distro (e.g.
`ubuntu`, `archlinux`).

## SSH in

```bash
ssh <your-username>@<ps5-ip>
```

If it's your first time connecting, accept the host key prompt. From here
you can debug over SSH even if the display is black - see
[Black Screen but SSH Works](/guide/display#black-screen-but-ssh-works).

## Collecting logs for a bug report

Before posting in Discord, grab everything relevant in one go:

```bash
{
  echo "=== uname ==="; uname -a
  echo "=== distro ==="; cat /etc/os-release
  echo "=== cmdline ==="; cat /proc/cmdline
  echo "=== lspci ==="; lspci -nn
  echo "=== dmesg ==="; dmesg
  echo "=== journal (this boot) ==="; journalctl -b --no-pager
  echo "=== amdgpu firmware ==="; ls /lib/firmware/amdgpu/
  echo "=== loaded modules ==="; lsmod
} > ps5-log-$(date +%Y%m%d-%H%M).txt 2>&1
```

Grab it off the PS5 with `scp`:

```bash
scp <user>@<ps5-ip>:ps5-log-*.txt .
```

Post the file in Discord (or a paste service, then link it) along with:

- What you expected vs. what happened
- Your distro, kernel version (`uname -r`), and firmware version
- Your monitor/cable if it's a display issue - include EDID if asked:
  ```bash
  cat /sys/class/drm/card*/card*-*/edid > edid.bin
  ```

Vague reports without logs are the #1 reason people don't get help fast.
