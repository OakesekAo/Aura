# Aura Weather Display Web Installer Integration Guide

## Overview

The Aura Weather Display firmware is now available with web installer compatible releases. This guide provides the technical specifications for integrating Aura firmware with web installer systems similar to Bongo Cat or the base aura-installer implementations.

## Release Assets Structure

Each Aura release contains 6 critical files for web installer compatibility:

### Firmware Binaries (Merged)
- `aura-firmware-24-ili9341.bin` - 2.4" ILI9341 displays (~705 KiB)
- `aura-firmware-24-st7789.bin` - 2.4" ST7789 displays (~705 KiB) 
- `aura-firmware-28-ili9341.bin` - 2.8" ILI9341 displays (~705 KiB)

### Manifest Files (ESPHome Web Tools Compatible)
- `manifest-24-ili9341.json` - Configuration for 2.4" ILI9341
- `manifest-24-st7789.json` - Configuration for 2.4" ST7789
- `manifest-28-ili9341.json` - Configuration for 2.8" ILI9341

## Primary Focus: 2.4" Display Variants

**Primary Target Hardware**: 2.4" displays are the main focus for direct hardware testing and support.

### 2.4" ILI9341 (Most Common)
```json
{
  "name": "Aura 24_ILI9341",
  "version": "v1.0.0-web-installer",
  "home_assistant_domain": "esphome",
  "new_install_prompt_erase": true,
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        {
          "path": "aura-firmware-24-ili9341.bin",
          "offset": 0
        }
      ]
    }
  ]
}
```

### 2.4" ST7789 (Alternative Driver)
```json
{
  "name": "Aura 24_ST7789",
  "version": "v1.0.0-web-installer",
  "home_assistant_domain": "esphome",
  "new_install_prompt_erase": true,
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        {
          "path": "aura-firmware-24-st7789.bin",
          "offset": 0
        }
      ]
    }
  ]
}
```

## Web Installer Integration

### GitHub Releases API Consumption

Your MCP agent should consume releases using the GitHub API:

```
GET https://api.github.com/repos/OakesekAo/Aura/releases
```

### Asset URL Pattern

Assets are available at predictable URLs:
```
https://github.com/OakesekAo/Aura/releases/download/{tag}/aura-firmware-24-ili9341.bin
https://github.com/OakesekAo/Aura/releases/download/{tag}/manifest-24-ili9341.json
```

### Latest Release Detection

For the latest release:
```
GET https://api.github.com/repos/OakesekAo/Aura/releases/latest
```

## Technical Specifications

### ESP32 Compatibility
- **Chip Family**: ESP32 (all variants)
- **ESP32 Core**: 3.0.4 (web installer compatible)
- **Flash Mode**: DIO, 40MHz
- **Partition Scheme**: huge_app (4MB)
- **Flash Size**: 4MB minimum

### Binary Structure
- **Single merged binary** - Contains bootloader, partitions, and application
- **Flash offset**: 0x0 (simplified single-file flashing)
- **Size**: ~705 KiB per variant
- **SHA256 checksums**: Available in release assets

### Supported Display Matrix

| Variant | Size | Driver | Priority | Use Case |
|---------|------|--------|----------|----------|
| 24-ili9341 | 2.4" | ILI9341 | **PRIMARY** | Main testing hardware |
| 24-st7789 | 2.4" | ST7789 | **PRIMARY** | Alternative 2.4" driver |
| 28-ili9341 | 2.8" | ILI9341 | Secondary | Larger display option |

## Web Installer Implementation Example

### HTML Integration (ESPHome Web Tools Style)
```html
<esp-web-install-button
  manifest="https://github.com/OakesekAo/Aura/releases/download/v1.0.0-web-installer/manifest-24-ili9341.json">
  <button slot="activate">Install Aura Weather Display (2.4" ILI9341)</button>
</esp-web-install-button>
```

### JavaScript API Usage
```javascript
// Detect latest release
const response = await fetch('https://api.github.com/repos/OakesekAo/Aura/releases/latest');
const release = await response.json();

// Primary 2.4" variants
const variants = [
  {
    name: 'Aura Weather Display (2.4" ILI9341)',
    manifest: `https://github.com/OakesekAo/Aura/releases/download/${release.tag_name}/manifest-24-ili9341.json`,
    priority: 1
  },
  {
    name: 'Aura Weather Display (2.4" ST7789)',
    manifest: `https://github.com/OakesekAo/Aura/releases/download/${release.tag_name}/manifest-24-st7789.json`,
    priority: 1
  },
  {
    name: 'Aura Weather Display (2.8" ILI9341)',
    manifest: `https://github.com/OakesekAo/Aura/releases/download/${release.tag_name}/manifest-28-ili9341.json`,
    priority: 2
  }
];
```

## MCP Agent Implementation Notes

### Asset Verification
- **Check file sizes**: Firmware binaries should be ~705 KiB
- **Verify checksums**: Use GitHub-provided SHA256 hashes
- **Validate JSON**: Ensure manifest files are valid JSON

### Error Handling
- **Network timeouts**: Implement retry logic for GitHub API calls
- **Missing assets**: Graceful fallback to previous stable release
- **Invalid manifests**: Validate manifest structure before presenting to user

### Caching Strategy
- **Cache releases**: Avoid excessive GitHub API calls (rate limits)
- **Cache manifests**: Store locally for offline validation
- **Update frequency**: Check for new releases daily or on user request

## Installation Flow

### Recommended User Experience
1. **Display selection**: Present 2.4" options prominently
2. **Hardware detection**: Guide users to identify their display type
3. **One-click install**: Use ESPHome Web Tools for installation
4. **Success verification**: Confirm successful flash and device boot

### Display Identification Guide
```
2.4" ILI9341: Most common, usually marked "ILI9341" on PCB
2.4" ST7789: Alternative driver, may be marked "ST7789" or "ST7735"
2.8" ILI9341: Larger display, clearly marked as 2.8" or 240x320
```

## Version Management

### Release Naming Convention
- **Tags**: `v{major}.{minor}.{patch}-web-installer`
- **Example**: `v1.0.0-web-installer`

### Compatibility Matrix
- **ESP32 Core 3.0.4+**: Required for web installer compatibility
- **LVGL 9.2.0**: UI library version
- **Arduino IDE 1.8.19+**: For manual compilation

## Testing and Validation

### Pre-deployment Checklist
- [ ] All 3 variants build successfully
- [ ] Manifest files validate against ESPHome Web Tools schema
- [ ] Binary sizes are reasonable (~705 KiB)
- [ ] SHA256 checksums match
- [ ] Test installation on actual 2.4" hardware

### Hardware Testing Priority
1. **2.4" ILI9341** - Primary test target
2. **2.4" ST7789** - Secondary test target  
3. **2.8" ILI9341** - Optional validation

## Support and Documentation

### User Resources
- **Manual Installation**: `esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 aura-firmware-{variant}.bin`
- **Troubleshooting**: Check ESP32 drivers and USB connection
- **Hardware Guide**: Display identification and wiring diagrams

### Developer Resources
- **Source Code**: `https://github.com/OakesekAo/Aura`
- **Build System**: GitHub Actions with Arduino CLI
- **Issue Tracking**: GitHub Issues with hardware-specific labels

## Verification and Troubleshooting

### Verify Chip ID Fixes

#### 1. Binary Header Verification
Check if the firmware has correct ESP32 magic bytes:

```bash
# Download and verify firmware header
curl -L -o aura-firmware-24-ili9341.bin \
  https://github.com/OakesekAo/Aura/releases/download/v1.0.2-web-installer/aura-firmware-24-ili9341.bin

# Check magic bytes (should start with 0xE9)
xxd -l 32 aura-firmware-24-ili9341.bin | head -2
# Expected output should start with: e9xx xxxx (where xx can be any hex digits)
```

#### 2. ESP32 Hardware Detection
Before flashing, verify your ESP32 hardware:

```bash
# Detect ESP32 chip info
esptool.py --port /dev/ttyUSB0 chip_id
esptool.py --port /dev/ttyUSB0 flash_id

# Expected output for ESP32-WROOM-32:
# Chip is ESP32-D0WD-V3 (revision v3.0)
# Features: WiFi, BT, Dual Core, 240MHz, VRef calibration in efuse, Coding Scheme None
```

#### 3. Flash Memory Layout Verification
Verify flash layout matches expectations:

```bash
# Check partition table
esptool.py --port /dev/ttyUSB0 read_flash 0x8000 0x1000 partitions.bin
python3 -c "
import struct
with open('partitions.bin', 'rb') as f:
    data = f.read()
    # Look for partition magic
    if b'\xAA\x50' in data:
        print('✓ Valid partition table found')
    else:
        print('✗ Invalid partition table')
"
```

### Debugging "Wrong Chip ID" Errors

If you still get "wrong chip id 0x0002" errors, collect this diagnostic information:

#### 1. Complete Boot Log
Capture the full serial output:

```bash
# Linux/macOS
screen /dev/ttyUSB0 115200

# Windows
putty -serial COM3 -sercfg 115200,8,n,1,N

# Look for these key lines:
# rst:0x?? (reset reason)
# configsip: ???????? (should show valid config)
# mode:DIO, clock div:1 (flash mode)
# wrong chip id 0x???? (the error)
```

#### 2. Flash Tool Verification
Test with different flash tools:

```bash
# Method 1: esptool.py (recommended)
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 aura-firmware-24-ili9341.bin

# Method 2: ESP Flash Download Tool (Windows)
# Use Espressif's official tool with these settings:
# - Address: 0x0
# - File: aura-firmware-24-ili9341.bin
# - SPI Speed: 40MHz
# - SPI Mode: DIO

# Method 3: Arduino IDE
# File → Preferences → Additional Boards Manager URLs:
# https://dl.espressif.com/dl/package_esp32_index.json
# Tools → Board → ESP32 Dev Module
# Tools → Upload Speed → 921600
# Tools → Flash Frequency → 40MHz
# Tools → Flash Mode → DIO
```

#### 3. Hardware Information Collection
Gather detailed hardware info:

```bash
# ESP32 chip details
esptool.py --port /dev/ttyUSB0 chip_id > esp32_info.txt

# Flash chip details  
esptool.py --port /dev/ttyUSB0 flash_id >> esp32_info.txt

# Read current bootloader (if accessible)
esptool.py --port /dev/ttyUSB0 read_flash 0x1000 0x7000 current_bootloader.bin

# Check bootloader header
xxd -l 32 current_bootloader.bin | head -2 >> esp32_info.txt
```

### Common Issues and Solutions

#### Issue 1: "wrong chip id 0x0000"
**Symptom**: `wrong chip id 0x0000` on boot
**Cause**: Completely corrupted or missing bootloader
**Solution**:
```bash
# Full chip erase and reflash
esptool.py --port /dev/ttyUSB0 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash 0x0 aura-firmware-24-ili9341.bin
```

#### Issue 2: "wrong chip id 0x0002" 
**Symptom**: `wrong chip id 0x0002` on boot
**Cause**: ESP32-S2/C3 bootloader on ESP32 hardware
**Solution**: Use v1.0.2+ firmware with correct bootloader

#### Issue 3: "configsip: 0, SPIWP:0xee"
**Symptom**: Flash configuration errors
**Cause**: Incorrect flash mode/frequency settings
**Solution**: 
```bash
# Force DIO mode at 40MHz
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash \
  --flash_mode dio --flash_freq 40m 0x0 aura-firmware-24-ili9341.bin
```

### Issue Reporting Template

If problems persist, create a GitHub issue with this information:

```markdown
**Hardware Information:**
- ESP32 Module: [ESP32-WROOM-32/ESP32-DevKit/Other]
- Display: [2.4" ILI9341/2.4" ST7789/2.8" ILI9341]
- USB Cable: [Data capable/Charging only]
- Power Supply: [USB/External]

**Software Information:**
- Firmware Version: [v1.0.2-web-installer]
- Flash Tool: [esptool.py version / Arduino IDE / Other]
- Operating System: [Windows/macOS/Linux]

**Error Details:**
- Full boot log (copy/paste serial output)
- esptool chip_id output
- esptool flash_id output
- Binary header check: `xxd -l 32 aura-firmware-*.bin`

**Flash Command Used:**
```bash
# Paste exact command used
```

**Steps to Reproduce:**
1. [Step by step instructions]
```

### Firmware Validation Script

Create this script to validate firmware before flashing:

```bash
#!/bin/bash
# validate_firmware.sh

FIRMWARE_FILE="$1"
if [ -z "$FIRMWARE_FILE" ]; then
    echo "Usage: $0 <firmware-file.bin>"
    exit 1
fi

echo "🔍 Validating firmware: $FIRMWARE_FILE"

# Check file exists and size
if [ ! -f "$FIRMWARE_FILE" ]; then
    echo "❌ File not found"
    exit 1
fi

SIZE=$(stat -c%s "$FIRMWARE_FILE" 2>/dev/null || stat -f%z "$FIRMWARE_FILE")
echo "📊 File size: $((SIZE / 1024)) KiB"

if [ $SIZE -lt 700000 ] || [ $SIZE -gt 800000 ]; then
    echo "⚠️  Warning: Unexpected file size (should be ~705 KiB)"
fi

# Check magic bytes at different offsets
echo "🔮 Magic byte verification:"

# Bootloader at 0x1000 offset (should be E9)
BOOTLOADER_MAGIC=$(xxd -s 0x1000 -l 1 -p "$FIRMWARE_FILE")
if [ "${BOOTLOADER_MAGIC:0:2}" = "e9" ]; then
    echo "✅ Bootloader magic: 0x$BOOTLOADER_MAGIC"
else
    echo "❌ Invalid bootloader magic: 0x$BOOTLOADER_MAGIC (expected 0xE9)"
fi

# App at 0x10000 offset (should be E9)  
APP_MAGIC=$(xxd -s 0x10000 -l 1 -p "$FIRMWARE_FILE")
if [ "${APP_MAGIC:0:2}" = "e9" ]; then
    echo "✅ Application magic: 0x$APP_MAGIC"
else
    echo "❌ Invalid application magic: 0x$APP_MAGIC (expected 0xE9)"
fi

# Partition table at 0x8000 (should be AA50)
PARTITION_MAGIC=$(xxd -s 0x8000 -l 2 -p "$FIRMWARE_FILE")
if [ "${PARTITION_MAGIC:0:4}" = "aa50" ]; then
    echo "✅ Partition magic: 0x$PARTITION_MAGIC"
else
    echo "❌ Invalid partition magic: 0x$PARTITION_MAGIC (expected 0xAA50)"
fi

echo "✅ Firmware validation complete"
```

---

**Last Updated**: September 4, 2025  
**Current Release**: v1.0.2-web-installer  
**Primary Hardware**: 2.4" ILI9341/ST7789 displays
