# ESP32 Chip ID Troubleshooting Guide

This guide addresses the "wrong chip id 0x0002" error that can occur when flashing Aura firmware to CYD (Cheap Yellow Display) boards.

## Problem Overview

The error "wrong chip id 0x0002" typically appears when:
1. The bootloader is compiled for the wrong ESP32 variant
2. The board configuration (FQBN) doesn't match the physical hardware
3. The merged binary has incompatible component binaries

## Quick Fixes

### 1. Try Different Board Configurations

Our build system now automatically tests multiple board configurations. The following have been verified to work:

✅ **Working Configurations:**
- `esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=dio`
- `esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=qio`
- `esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=min_spiffs,CPUFreq=240,FlashMode=dio`

❌ **Known Issues:**
- `esp32:esp32:esp32dev` - Board definition not found in ESP32 core 3.0.4
- `esp32:esp32:esp32wrover` - PSRAM parameter incompatible

### 2. Hardware-Specific Solutions

#### For CYD Boards (ESP32-2432S028R):
- **Recommended FQBN:** `esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=default`
- **Flash Mode:** DIO (more compatible) or QIO (faster)
- **Flash Size:** 4MB
- **PSRAM:** Disabled (most CYD boards don't have PSRAM)

#### Manual Flash Mode Selection:
If web installer fails, try:
1. Hold the **BOOT** button on the ESP32 during flashing
2. Use ESP32 Flash Download Tool with manual timing
3. Try different USB cables/ports

## Diagnostic Information

### Chip Information Output

The firmware now includes detailed chip identification at startup:

```
=== Aura ESP32 Board Information ===
Chip Model: ESP32-D0WDQ6
Chip Revision: 3
Chip Cores: 2
CPU Frequency: 240 MHz
Flash Size: 4194304 bytes
Flash Speed: 40000000 Hz
SDK Version: v4.4.7-dirty
Chip Features: WiFi BLE
PSRAM: Disabled in build
===================================
```

### Binary Verification

You can verify your firmware binary has the correct chip target:

```bash
# Check bootloader header (should start with 0xE9 for ESP32)
xxd -l 16 firmware.bin

# Expected output:
00000000: e903 0220 e405 0840 ee00 0000 0000 0000  ... ...@........
```

## Build System Improvements

### Automatic Board Testing

The build workflow now:
1. Tests multiple board configurations automatically
2. Falls back to working configurations if primary fails
3. Logs detailed chip information during build
4. Verifies bootloader chip target compatibility

### Test Script

Run the board configuration test locally:

```bash
chmod +x test_board_configs.sh
./test_board_configs.sh
```

This will test all available board configurations and report which ones work.

## Web Installer Integration

### Manifest Files

Each build variant now includes proper manifest files for ESP Web Tools:

```json
{
  "name": "Aura 24_ILI9341",
  "version": "development",
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

### Troubleshooting Web Installer

If the web installer shows chip errors:

1. **Browser Compatibility:** Use Chrome, Edge, or Opera
2. **HTTPS Required:** Ensure the installer is served over HTTPS
3. **USB Permissions:** Grant browser access to USB devices
4. **Boot Mode:** Hold BOOT button if flashing fails
5. **Try Different Firmware:** Test with different board configuration builds

## Hardware Verification

### Check Your CYD Board

1. **Model Number:** Look for ESP32-2432S028R on the board
2. **Display Driver:** Should be ILI9341 for 2.4" or ILI9341/ST7789 for 2.8"
3. **USB Connection:** Use a good quality USB cable
4. **Power Supply:** Ensure stable 5V supply

### Pin Configuration

Verify your board matches the expected pin configuration:

```cpp
// TFT Pins (from TFT_eSPI/User_Setup.h)
#define TFT_MISO 12
#define TFT_MOSI 13
#define TFT_SCLK 14
#define TFT_CS   15
#define TFT_DC   2
#define TFT_RST  -1

// Touch Pins
#define TOUCH_CS 33
```

## Advanced Debugging

### Serial Monitor Output

Connect to the ESP32's serial port (115200 baud) to see:
- Detailed chip information at startup
- Boot process and any error messages
- WiFi connection status
- Display initialization logs

### Using esptool for Manual Flashing

If web installer fails, use esptool directly:

```bash
# Install esptool
pip install esptool

# Flash merged binary
esptool --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x0 firmware.bin

# Or flash individual components
esptool --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0xe000 boot_app0.bin \
  0x10000 app.bin
```

## Support and Reporting Issues

When reporting chip ID issues, please include:

1. **Board Model:** ESP32-2432S028R, etc.
2. **Firmware Version:** From GitHub releases
3. **Browser/OS:** Chrome on Windows 11, etc.
4. **Error Messages:** Complete error text
5. **Serial Output:** First 50 lines after reset
6. **Hardware Photos:** If possible, board close-ups

The enhanced logging and multiple board configuration testing should resolve most chip ID compatibility issues.
