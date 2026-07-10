# Media & IPTV

::: info Arch-based only
:::

## IPTVnator

IPTV client for m3u/m3u8 playlists with EPG, favorites, and TV archive
support - a solid pick if you're feeding the PS5 an IPTV subscription
instead of/alongside streaming apps.

```bash
paru -S iptvnator-bin
```

Verified on the reference PS5: `iptvnator-bin 0.21.0`.

Point it at your `.m3u`/`.m3u8` playlist URL or local file, EPG (program
guide) is a separate XMLTV URL entered in Settings.

## Local Playback

For non-IPTV local media, `mpv` is the lightweight pick (no bundled Qt UI
overhead like VLC), works fine over the amdgpu VAAPI path for hardware
decode of supported codecs:

```bash
sudo pacman -S mpv
```

VLC also works if you want a full GUI player with more format/protocol
handling built in:

```bash
sudo pacman -S vlc
```
