#!/bin/bash

# Manual flash script for troubleshooting ESP32 chip ID issues
# This script downloads the latest firmware and attempts manual flashing

echo "=== Manual ESP32 Flash Troubleshooting ==="

# Download the latest firmware
echo "Downloading latest firmware..."
wget -q "https://github.com/OakesekAo/Aura/releases/download/v1.0.6-web-installer/aura_24_ili9341_merged.bin" -O aura_latest.bin

if [ ! -f "aura_latest.bin" ]; then
    echo "Error: Could not download firmware"
    exit 1
fi

echo "Firmware downloaded: $(stat -c%s aura_latest.bin) bytes"

# Check if esptool is available
if ! command -v esptool.py &> /dev/null; then
    echo "Installing esptool..."
    pip install esptool
fi

echo ""
echo "=== Manual Flash Options ==="
echo ""
echo "1. Standard Flash (Auto-detect):"
echo "   esptool.py --port /dev/ttyUSB0 write_flash 0x0 aura_latest.bin"
echo ""
echo "2. Force ESP32 Mode:"
echo "   esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 aura_latest.bin"
echo ""
echo "3. Slow Flash (More Reliable):"
echo "   esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 write_flash 0x0 aura_latest.bin"
echo ""
echo "4. Manual Boot Mode:"
echo "   1. Hold BOOT button on ESP32"
echo "   2. Press RESET button (while holding BOOT)"
echo "   3. Release RESET (keep holding BOOT)"
echo "   4. Run flash command"
echo "   5. Release BOOT when flashing starts"
echo ""

# Detect ESP32 ports
echo "=== Detecting ESP32 Devices ==="
for port in /dev/ttyUSB* /dev/ttyACM*; do
    if [ -e "$port" ]; then
        echo "Found potential ESP32 port: $port"
        # Try to get chip info
        timeout 5 esptool.py --port "$port" chip_id 2>/dev/null && echo "  -> ESP32 detected on $port"
    fi
done

echo ""
echo "Replace /dev/ttyUSB0 with your actual port (e.g., /dev/ttyUSB1, /dev/ttyACM0)"
echo "On Windows: use COM1, COM2, etc."
echo "On macOS: use /dev/cu.usbserial-*"
