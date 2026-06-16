#!/bin/bash

INSTALL_DIR="$HOME/Applications/PCSX2"
API_URL="https://api.github.com/repos/PCSX2/pcsx2/releases/latest"
APPIMAGE_PATH="$INSTALL_DIR/PCSX2-linux-x64.AppImage"
ICON_PATH="$INSTALL_DIR/PCSX2.png"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
DESKTOP_SHORTCUT_DIR="$HOME/Desktop"

[ -d "$INSTALL_DIR" ] || mkdir -p "$INSTALL_DIR"

URL=$(curl -s "$API_URL" | grep -oP '"browser_download_url": "\K[^"]+\.AppImage' | head -n 1)

if [ -z "$URL" ]; then
    echo "Error: Could not retrieve the latest download URL from GitHub."
    exit 1
fi

if [ -f "$APPIMAGE_PATH" ]; then
    echo "PCSX2 is already installed. Checking for updates..."
    
    LOCAL_SIZE=$(stat -c%s "$APPIMAGE_PATH")
    REMOTE_SIZE=$(curl -sIL "$URL" | grep -i 'content-length' | awk '{print $2}' | tr -d '\r' | head -n 1)

    if [ "$LOCAL_SIZE" -eq "$REMOTE_SIZE" ]; then
        echo "You already have the latest version installed!"
    else
        echo "An update is available!"
        curl -sL "$URL" -o "$APPIMAGE_PATH"
        chmod +x "$APPIMAGE_PATH"
    fi
fi

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "PCSX2 not found. Downloading the latest release..."
    curl -sL "$URL" -o "$APPIMAGE_PATH"
    
    if [ ! -f "$APPIMAGE_PATH" ] || [ ! -s "$APPIMAGE_PATH" ]; then
        echo "Error: Could not download PCSX2."
        exit 1
    fi

    chmod +x "$APPIMAGE_PATH"
fi

echo "Setting up desktop and app menu entries..."

if [ ! -f "$ICON_PATH" ]; then
    curl -sL "https://raw.githubusercontent.com/rmuxnet/ps5-linux-guide/main/docs/public/images/PS2/PCSX2.png" -o "$ICON_PATH"
fi

DESKTOP_CONTENT="[Desktop Entry]
Version=1.0
Type=Application
Name=PCSX2
Comment=PlayStation 2 Emulator
Exec=$APPIMAGE_PATH
Icon=$ICON_PATH
Categories=Game;Emulator;
Terminal=false
StartupWMClass=pcsx2-qt"


[ -d "$DESKTOP_ENTRY_DIR" ] || mkdir -p "$DESKTOP_ENTRY_DIR"
echo "$DESKTOP_CONTENT" > "$DESKTOP_ENTRY_DIR/pcsx2.desktop"
chmod +x "$DESKTOP_ENTRY_DIR/pcsx2.desktop"

if [ -d "$DESKTOP_SHORTCUT_DIR" ]; then
    echo "$DESKTOP_CONTENT" > "$DESKTOP_SHORTCUT_DIR/pcsx2.desktop"
    chmod +x "$DESKTOP_SHORTCUT_DIR/pcsx2.desktop"
fi

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_ENTRY_DIR"
fi

echo "✅ PCSX2 installation and shortcuts are complete!"
"$APPIMAGE_PATH" > /dev/null 2>&1 & disown