# Jailbreak

Which exploit you need depends on your firmware. Check [Firmware](/guide/firmware).

::: danger Do not run etahen, kstuff, or any other payload before sending the Linux loader
If you already ran them, **restart the PS5** and jailbreak again fresh. Send the Linux loader as the only payload. Running it alongside etahen or kstuff will prevent Linux from booting.
:::

## Firmware 3.00 - 5.50: umtx2

```bash
git clone https://github.com/idlesauce/umtx2
```

1. Edit `dns.conf` to point `manuals.playstation.net` to your PC's IP.
2. Start fake DNS: `sudo python fakedns.py -c dns.conf`
3. In another terminal, start the HTTPS server: `sudo python host.py`
4. On PS5: go to network settings, set primary DNS to your PC's IP, leave secondary as `0.0.0.0`.
5. Open `Settings` → User Manual → accept the untrusted certificate prompt → exploit runs.

## Firmware 6.00 - 6.02: Y2JB

1. Install Y2JB: [github.com/Gezine/Y2JB](https://github.com/Gezine/Y2JB)
2. Run the kernel exploit:
   ```bash
   python3 payload_sender.py $PS5IP 50000 payloads/lapse.js
   ```

::: tip Y2JB for Linux only
To run Y2JB without conflicting with your regular jailbreak setup, install a separate YouTube package from a different region. See [prosperopatches](https://prosperopatches.com/) for packages.
:::

After either exploit succeeds, the PS5 listens on port `9021` for the Linux payload. Continue to [Booting](/guide/booting#5-send-the-payload).

## Exploit Host Options

You need a machine to serve the exploit. Options:

| Method | Notes |
|---|---|
| PC on same network | Simplest. Run `fakedns.py` + `host.py` on your PC |
| Raspberry Pi via Ethernet | Plug RPi directly into PS5 via Ethernet, set PS5 DNS to RPi IP. Self-contained, no PC needed |
| ESP (WiFi) | Small ESP board serves the exploit over WiFi. Keeps the PS5 Ethernet port free under Linux |
| Cached browser shortcut | Save exploit page to PS5 homescreen. Works offline once cached |

## Autoloader

If using an autoloader USB, version **0.4** is more stable than 0.7 for some setups. Point `autoloader.txt` to the Linux loader `.elf` only - no other payloads in the same run.
