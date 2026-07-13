# Ethernet

PCI ID: `104d:9104`

Driver: `mts` (MediaTek Star based Gigabit Ethernet)

Works out of the box. No extra setup requried after booting Linux.

## Background

The PS5 GbE controller is based on the MediaTek Star Ethernet MAC (`mtk_star_emac`). The `mts` driver was written by rmuxnet with a base shared by slidybat and endless testing from c0w.

## Kernel Config

```
CONFIG_MTS=y
```

Built-in by default in the ps5-linux kernel. No manual loading neccesary.

## Troubleshooting

If the interface doesn't come up after first boot, disable and re-enable the wired connection in your network manager.

### USB Ethernet Adapters Flaky

If you're using a USB-C or USB-A ethernet adapter instead of the internal port, some users report the connection toggling on/off repeatedly instead of staying stable. No fix identified yet, try a different adapter/cable if you hit this, or use the internal `mts` driver instead, it works on any supported firmware. If buying one, **RTL8156B** is the confirmed-working chipset to look for.

### Internal GbE Slower Than USB Adapter

One report of the internal port (`mts`) bottlenecking around 300Mbps while a USB-C ethernet adapter on the same connection reached 940-980Mbps. Suspected cause per the `mts` driver author: an IRQ overflow pegging one CPU thread at 100%, capping throughput well below gigabit, not yet confirmed. Not fixed either way, if you need full gigabit, a USB adapter is a working fallback in the meantime.

### IRQ/NAPI Bugs

A related but distinct bug was fixed upstream: on cold boot, a core could get pegged with useless load because the NIC never fired its interrupt and the driver looped forever, this is fixed.

A second bug remains **unfixed**: under heavy sustained TX load, a sticky ISR bit gets left set, causing the driver to keep re-kicking NAPI and pegging a core, reloading the driver does not clear it, only a reboot does. Only shows up under real stress (large sustained transfers), not normal use.
