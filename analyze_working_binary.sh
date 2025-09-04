#!/bin/bash

# Script to analyze a working ESP32 binary to understand its configuration
# Usage: ./analyze_working_binary.sh <path_to_working_binary.bin>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path_to_working_binary.bin>"
    echo "Example: $0 /path/to/bongocat.bin"
    exit 1
fi

BINARY_PATH="$1"

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: File '$BINARY_PATH' not found"
    exit 1
fi

echo "=== Analyzing Working ESP32 Binary ==="
echo "File: $BINARY_PATH"
echo "Size: $(stat -c%s "$BINARY_PATH") bytes"
echo ""

echo "=== Binary Structure Analysis ==="

# Check the first 32 bytes for ESP32 magic and chip identification
echo "First 32 bytes (hex):"
xxd -l 32 "$BINARY_PATH"
echo ""

# Look for ESP32 bootloader signature
echo "=== Bootloader Analysis ==="
echo "Checking for ESP32 bootloader signature at common offsets..."

# Check at offset 0x1000 (4096 bytes) - standard ESP32 bootloader location
OFFSET_4K=4096
if [ $(stat -c%s "$BINARY_PATH") -gt $OFFSET_4K ]; then
    echo "Bootloader at 0x1000 (4096):"
    xxd -s $OFFSET_4K -l 32 "$BINARY_PATH"
    
    # Extract chip ID from bootloader header
    CHIP_ID=$(xxd -s $((OFFSET_4K + 12)) -l 2 -p "$BINARY_PATH" | sed 's/\(..\)\(..\)/\2\1/')
    echo "Chip ID from bootloader: 0x$CHIP_ID"
    
    case "$CHIP_ID" in
        "0000") echo "  -> ESP32 (chip ID 0x0000)" ;;
        "0002") echo "  -> ESP32-S2 (chip ID 0x0002)" ;;
        "0005") echo "  -> ESP32-C3 (chip ID 0x0005)" ;;
        "0009") echo "  -> ESP32-S3 (chip ID 0x0009)" ;;
        "000c") echo "  -> ESP32-C2 (chip ID 0x000c)" ;;
        "000d") echo "  -> ESP32-C6 (chip ID 0x000d)" ;;
        "0010") echo "  -> ESP32-H2 (chip ID 0x0010)" ;;
        *) echo "  -> Unknown chip ID: 0x$CHIP_ID" ;;
    esac
fi
echo ""

# Check at offset 0 - some binaries start with bootloader
echo "Checking if bootloader starts at offset 0:"
FIRST_4_BYTES=$(xxd -l 4 -p "$BINARY_PATH")
if [[ "$FIRST_4_BYTES" == "e904"* ]] || [[ "$FIRST_4_BYTES" == *"04e9" ]]; then
    echo "ESP32 bootloader found at offset 0"
    CHIP_ID_0=$(xxd -s 12 -l 2 -p "$BINARY_PATH" | sed 's/\(..\)\(..\)/\2\1/')
    echo "Chip ID: 0x$CHIP_ID_0"
else
    echo "No ESP32 bootloader at offset 0"
fi
echo ""

echo "=== Flash Configuration Analysis ==="

# Look for partition table (usually at 0x8000)
PARTITION_OFFSET=32768
if [ $(stat -c%s "$BINARY_PATH") -gt $PARTITION_OFFSET ]; then
    echo "Checking partition table at 0x8000 (32768):"
    PARTITION_MAGIC=$(xxd -s $PARTITION_OFFSET -l 2 -p "$BINARY_PATH")
    if [ "$PARTITION_MAGIC" = "50aa" ]; then
        echo "Valid ESP32 partition table found"
        xxd -s $PARTITION_OFFSET -l 64 "$BINARY_PATH"
    else
        echo "No partition table at standard location (magic: $PARTITION_MAGIC, expected: 50aa)"
    fi
fi
echo ""

echo "=== Application Analysis ==="

# Look for common ESP32 application start patterns
echo "Searching for application entry point patterns..."

# Search for ESP32 app header patterns
if xxd "$BINARY_PATH" | grep -q "e904"; then
    echo "Found ESP32 magic bytes (e904) in binary"
fi

if xxd "$BINARY_PATH" | grep -q "EBEB"; then
    echo "Found ESP32 app descriptor pattern"
fi

echo ""
echo "=== File Structure Summary ==="
echo "Total size: $(stat -c%s "$BINARY_PATH") bytes ($(printf "0x%x" $(stat -c%s "$BINARY_PATH")))"

# Check if it's a merged binary or individual component
if [ $(stat -c%s "$BINARY_PATH") -gt 1000000 ]; then
    echo "Large file - likely a merged binary with bootloader + app + partitions"
elif [ $(stat -c%s "$BINARY_PATH") -gt 500000 ]; then
    echo "Medium file - likely application binary only"
else
    echo "Small file - likely bootloader or partition table only"
fi

echo ""
echo "=== Recommendations ==="
echo "To match this working configuration:"
echo "1. Use the same chip ID found in the bootloader"
echo "2. Match the binary structure (merged vs separate components)"
echo "3. Use compatible flash mode and partition scheme"
echo ""
echo "If you can share this working binary, we can extract the exact"
echo "bootloader and partition configuration to match in our build."
