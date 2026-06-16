#!/bin/bash

INSTALL_DIR="$HOME/Applications/DuckStation"
URL="https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage"
APPIMAGE_PATH="$INSTALL_DIR/DuckStation-x64.AppImage"

[ -d "$INSTALL_DIR" ] || mkdir -p "$INSTALL_DIR"

if [ -f "$APPIMAGE_PATH" ]; then
    echo "DuckStation is already installed. Checking for updates..."
    
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
    echo "DuckStation not found. Downloading..."
    curl -sL "$URL" -o "$APPIMAGE_PATH"
    
    if [ ! -f "$APPIMAGE_PATH" ] || [ ! -s "$APPIMAGE_PATH" ]; then
        echo "Error: Could not download DuckStation."
        exit 1
    fi

    chmod +x "$APPIMAGE_PATH"
fi

echo "✅ DuckStation installation complete!"
"$APPIMAGE_PATH" > /dev/null 2>&1 & disown