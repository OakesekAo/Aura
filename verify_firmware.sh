#!/bin/bash
# Aura Firmware Verification Script
# Usage: ./verify_firmware.sh [firmware-file.bin]

set -e

FIRMWARE_FILE="${1:-aura-firmware-24-ili9341.bin}"
RELEASE_TAG="v1.0.2-web-installer"

echo "🚀 Aura Firmware Verification Tool"
echo "================================="

# Download firmware if not present
if [ ! -f "$FIRMWARE_FILE" ]; then
    echo "📥 Downloading $FIRMWARE_FILE..."
    curl -L -o "$FIRMWARE_FILE" \
        "https://github.com/OakesekAo/Aura/releases/download/$RELEASE_TAG/$FIRMWARE_FILE"
fi

echo "🔍 Validating firmware: $FIRMWARE_FILE"

# Check file exists and size
if [ ! -f "$FIRMWARE_FILE" ]; then
    echo "❌ File not found: $FIRMWARE_FILE"
    exit 1
fi

SIZE=$(stat -c%s "$FIRMWARE_FILE" 2>/dev/null || stat -f%z "$FIRMWARE_FILE")
SIZE_KB=$((SIZE / 1024))
echo "📊 File size: $SIZE_KB KiB"

if [ $SIZE -lt 700000 ] || [ $SIZE -gt 800000 ]; then
    echo "⚠️  Warning: Unexpected file size (should be ~705 KiB)"
else
    echo "✅ File size looks good"
fi

# Check magic bytes at different offsets
echo ""
echo "🔮 Magic byte verification:"

# Check if xxd is available
if ! command -v xxd &> /dev/null; then
    echo "❌ xxd command not found. Please install it to continue."
    exit 1
fi

# Bootloader at 0x1000 offset (should be E9)
BOOTLOADER_MAGIC=$(xxd -s 0x1000 -l 1 -p "$FIRMWARE_FILE" | tr -d '\n')
if [ "${BOOTLOADER_MAGIC:0:2}" = "e9" ]; then
    echo "✅ Bootloader magic: 0x$BOOTLOADER_MAGIC (ESP32 compatible)"
else
    echo "❌ Invalid bootloader magic: 0x$BOOTLOADER_MAGIC (expected 0xE9xx)"
fi

# App at 0x10000 offset (should be E9)  
APP_MAGIC=$(xxd -s 0x10000 -l 1 -p "$FIRMWARE_FILE" | tr -d '\n')
if [ "${APP_MAGIC:0:2}" = "e9" ]; then
    echo "✅ Application magic: 0x$APP_MAGIC (ESP32 compatible)"
else
    echo "❌ Invalid application magic: 0x$APP_MAGIC (expected 0xE9xx)"
fi

# Partition table at 0x8000 (should be AA50)
PARTITION_MAGIC=$(xxd -s 0x8000 -l 2 -p "$FIRMWARE_FILE" | tr -d '\n')
if [ "${PARTITION_MAGIC:0:4}" = "aa50" ]; then
    echo "✅ Partition magic: 0x$PARTITION_MAGIC (valid partition table)"
else
    echo "❌ Invalid partition magic: 0x$PARTITION_MAGIC (expected 0xAA50)"
fi

# Boot app0 at 0xe000 (should be specific pattern)
BOOT_APP0_MAGIC=$(xxd -s 0xe000 -l 4 -p "$FIRMWARE_FILE" | tr -d '\n')
echo "ℹ️  Boot app0 signature: 0x$BOOT_APP0_MAGIC"

echo ""
echo "🔧 Hardware verification commands:"
echo "================================="
echo "# Detect ESP32 chip (run before flashing):"
echo "esptool.py --port /dev/ttyUSB0 chip_id"
echo ""
echo "# Flash firmware (after verification):"
echo "esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 $FIRMWARE_FILE"
echo ""
echo "# Monitor serial output (after flashing):"
echo "screen /dev/ttyUSB0 115200"
echo "# (Press Ctrl-A, K to exit screen)"

echo ""
echo "📋 Expected successful boot sequence:"
echo "====================================="
echo "rst:0x01 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)"
echo "configsip: 0, SPIWP:0xee"
echo "mode:DIO, clock div:1"
echo "load:0x3fff0030,len:1344"
echo "ho 0 tail 12 room 4"
echo "load:0x40078000,len:13964"
echo "load:0x40080400,len:3600"
echo "entry 0x400805f0"
echo "[    0.123] Aura Weather Display Starting..."

echo ""
if [ "${BOOTLOADER_MAGIC:0:2}" = "e9" ] && [ "${APP_MAGIC:0:2}" = "e9" ] && [ "${PARTITION_MAGIC:0:4}" = "aa50" ]; then
    echo "🎉 Firmware validation PASSED - ready to flash!"
    exit 0
else
    echo "❌ Firmware validation FAILED - DO NOT FLASH"
    exit 1
fi
