# Prerequisites

## Required PS5 Settings

These must be set before running the exploit. If you reset PS5 settings or reinstall firmware, reapply them. Forgeting this is the most common reason Linux fails to boot.

**Enable USB power in rest mode** (required for boot):
`Settings` → `System` → `Power Saving` → `Features Available in Rest Mode` → set `Supply Power to USB Ports` to `Always`

**Disable HDMI Device Link** (required):
`Settings` → `HDMI` → `Enable HDMI Device Link` → Off

**Recommended:**

Disable automatic updates:
`Settings` → `System Software` → `System Software Update and Settings`

Disable automatic error reporting:
`Settings` → `System Software` → `Report System Software Errors Automatically`

## Hardware

- USB drive 64 GB+ (FAT32 or exFAT, external SSD preferred)
- USB keyboard/mouse

## Host Machine

Linux or Windows (WSL) to prepare the image. Needs: `dd`, `docker`, `socat`.

## Linux Knowledge

This guide assumes basic Linux command line familiarity. If you're new to Linux, go through a basic tutorial before starting - it will save you a lot of frustration. [learnshell.org](https://www.learnshell.org/) is a good free interactive start.
