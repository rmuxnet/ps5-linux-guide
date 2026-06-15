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
