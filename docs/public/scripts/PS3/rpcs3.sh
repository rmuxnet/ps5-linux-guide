#!/bin/bash

BIN_DIR="$HOME/.local/bin"
APPIMAGE_PATH="$BIN_DIR/rpcs3.AppImage"
API_URL="https://api.github.com/repos/RPCS3/rpcs3-binaries-linux/releases/latest"

[ -d "$BIN_DIR" ] || mkdir -p "$BIN_DIR"

echo "Checking GitHub for the latest RPCS3 release..."
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -oP '"browser_download_url": "\K[^"]+\.AppImage' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not retrieve the download URL from GitHub."
    exit 1
fi

# 2. Check if RPCS3 is already installed
if [ -f "$APPIMAGE_PATH" ]; then
    echo "RPCS3 is already installed. Checking for updates..."

    LOCAL_SIZE=$(stat -c%s "$APPIMAGE_PATH")

    REMOTE_SIZE=$(curl -sIL "$DOWNLOAD_URL" | grep -i 'content-length' | awk '{print $2}' | tr -d '\r' | head -n 1)

    if [ "$LOCAL_SIZE" -eq "$REMOTE_SIZE" ]; then
        echo "You already have the latest version installed!"
    else
        echo "An update is available!"
        echo "Updating RPCS3..."
        curl -sL -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"
        chmod +x "$APPIMAGE_PATH"
        echo "Update complete!"
    fi
else
    echo "RPCS3 not found. Installing the latest version..."
    curl -sL -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"
    chmod +x "$APPIMAGE_PATH"
    echo "Installation complete!"
fi

echo "Launching RPCS3..."
"$APPIMAGE_PATH" > /dev/null 2>&1 & disown