#!/bin/bash

BIN_DIR="$HOME/.local/bin"
APPIMAGE_PATH="$BIN_DIR/xenia-edge.AppImage"
API_URL="https://api.github.com/repos/has207/xenia-edge/releases/latest"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
LOCAL_ICON_DIR="$HOME/.local/share/icons"

[ -d "$BIN_DIR" ] || mkdir -p "$BIN_DIR"
[ -d "$DESKTOP_ENTRY_DIR" ] || mkdir -p "$DESKTOP_ENTRY_DIR"
[ -d "$LOCAL_ICON_DIR" ] || mkdir -p "$LOCAL_ICON_DIR"

echo "Checking GitHub for the latest Xenia Edge release..."
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -oP '"browser_download_url": "\K[^"]+\.AppImage' | grep 'linux' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not retrieve the download URL from GitHub."
    exit 1
fi

if [ -f "$APPIMAGE_PATH" ]; then
    echo "Xenia Edge is already installed. Checking for updates..."

    LOCAL_SIZE=$(stat -c%s "$APPIMAGE_PATH")
    REMOTE_SIZE=$(curl -sIL "$DOWNLOAD_URL" | grep -i 'content-length' | awk '{print $2}' | tr -d '\r' | head -n 1)

    if [ -z "$REMOTE_SIZE" ]; then
        echo "Could not verify remote file size. Forcing update to ensure freshness..."
        LOCAL_SIZE=-1
        REMOTE_SIZE=0
    fi

    if [ "$LOCAL_SIZE" -eq "$REMOTE_SIZE" ]; then
        echo "You already have the latest version installed!"
    else
        echo "An update is available!"
        echo "Updating Xenia Edge..."
        curl -sL -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"
        chmod +x "$APPIMAGE_PATH"
        echo "Update complete!"
    fi
else
    echo "Xenia Edge not found. Installing the latest version..."
    curl -sL -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"
    chmod +x "$APPIMAGE_PATH"
    echo "Installation complete!"
fi

if [ ! -f "$LOCAL_ICON_DIR/xenia.png" ]; then
    echo "Setting up application icons..."
    curl -sL -o "$LOCAL_ICON_DIR/xenia.png" "https://raw.githubusercontent.com/rmuxnet/ps5-linux-guide/main/docs/public/images/Xemu/xeniapng"
fi

# 3. Create Application Menu Entry (.desktop shortcut)
echo "Creating desktop environment configurations..."
cat <<EOF> "$DESKTOP_ENTRY_DIR/xenia-edge.desktop"
[Desktop Entry]
Type=Application
Name=Xenia Edge
Comment=Xbox 360 Emulator Research Project (Canary Fork)
Exec=$APPIMAGE_PATH
Icon=xenia
Terminal=false
Categories=Game;Emulator;
Keywords=xbox360;emulator;xenia;edge;
EOF

# 4. Initialize Decoupled Process Tree 
echo "Launching Xenia Edge in background window..."
"$APPIMAGE_PATH" > /dev/null 2>&1 & disown