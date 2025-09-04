#!/bin/bash

# Test different ESP32 board configurations for CYD compatibility
echo "Testing different ESP32 board configurations for CYD boards..."

# Array of different FQBN configurations to test
declare -a CONFIGS=(
    "esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=dio,FlashFreq=40,FlashSize=4M"
    "esp32:esp32:esp32dev:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=dio,FlashFreq=40,FlashSize=4M"
    "esp32:esp32:esp32wrover:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=dio,FlashFreq=40,FlashSize=4M"
    "esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=default,CPUFreq=240,FlashMode=qio,FlashFreq=40,FlashSize=4M"
    "esp32:esp32:esp32:PSRAM=disabled,PartitionScheme=min_spiffs,CPUFreq=240,FlashMode=dio,FlashFreq=40,FlashSize=4M"
)

declare -a CONFIG_NAMES=(
    "esp32_default_dio"
    "esp32dev_default_dio"
    "esp32wrover_default_dio"
    "esp32_default_qio"
    "esp32_min_spiffs_dio"
)

# Ensure we have the right libraries
echo "Installing/updating required libraries..."
arduino-cli lib install "ArduinoJson@7.0.4"
arduino-cli lib install "TFT_eSPI@2.5.43"
arduino-cli lib install "WiFiManager@2.0.17"
arduino-cli lib install "XPT2046_Touchscreen@1.4"
arduino-cli lib install "lvgl@9.2.0"

# Copy TFT_eSPI config
TFT_LIB_PATH=$(find ~/Arduino/libraries -name "TFT_eSPI" -type d 2>/dev/null | head -1)
if [ -z "$TFT_LIB_PATH" ]; then
    TFT_LIB_PATH=$(find ~/.arduino15/packages/*/hardware/*/libraries -name "TFT_eSPI" -type d 2>/dev/null | head -1)
fi

if [ -n "$TFT_LIB_PATH" ]; then
    cp TFT_eSPI/User_Setup.h "$TFT_LIB_PATH/User_Setup.h"
    echo "TFT_eSPI config copied to $TFT_LIB_PATH"
else
    echo "WARNING: TFT_eSPI library not found"
fi

# Copy LVGL config  
LVGL_LIB_PATH=$(find ~/Arduino/libraries -name "lvgl" -type d 2>/dev/null | head -1)
if [ -z "$LVGL_LIB_PATH" ]; then
    LVGL_LIB_PATH=$(find ~/.arduino15/packages/*/hardware/*/libraries -name "lvgl" -type d 2>/dev/null | head -1)
fi

if [ -n "$LVGL_LIB_PATH" ]; then
    cp lvgl/src/lv_conf.h "$LVGL_LIB_PATH/src/"
    echo "LVGL config copied to $LVGL_LIB_PATH"
else
    echo "WARNING: LVGL library not found"
fi

# Test each configuration
mkdir -p test_builds
for i in "${!CONFIGS[@]}"; do
    config="${CONFIGS[$i]}"
    name="${CONFIG_NAMES[$i]}"
    
    echo ""
    echo "===================="
    echo "Testing: $name"
    echo "FQBN: $config"
    echo "===================="
    
    # Clean previous build
    rm -rf test_builds/$name
    
    # Attempt to build
    if arduino-cli compile \
        --fqbn "$config" \
        --build-property "build.extra_flags=-DAURA_SCREEN=24_ILI9341 -DCORE_DEBUG_LEVEL=0" \
        --output-dir test_builds/$name \
        aura; then
        
        echo "✅ SUCCESS: $name built successfully"
        
        # Check if we have the necessary binaries
        if [ -f "test_builds/$name/aura.ino.bin" ]; then
            echo "   Main binary: $(ls -lh test_builds/$name/aura.ino.bin)"
        fi
        
        if [ -f "test_builds/$name/aura.ino.bootloader.bin" ]; then
            echo "   Bootloader: $(ls -lh test_builds/$name/aura.ino.bootloader.bin)"
        fi
        
        if [ -f "test_builds/$name/aura.ino.partitions.bin" ]; then
            echo "   Partitions: $(ls -lh test_builds/$name/aura.ino.partitions.bin)"
        fi
        
        # Try to create a merged binary for web installer
        echo "   Attempting to create merged binary..."
        
        # Find ESP32 core path
        ESP32_PATH=$(find ~/.arduino15/packages/esp32/hardware/esp32 -name "3.0.4" -type d | head -1)
        
        if [ -n "$ESP32_PATH" ]; then
            # Look for bootloader and boot_app0
            BOOTLOADER_PATH=""
            BOOT_APP0_PATH=""
            
            for path in "$ESP32_PATH/tools/sdk/esp32/bin" "$ESP32_PATH/tools/sdk/bin" "$ESP32_PATH/tools/partitions"; do
                if [ -f "$path/bootloader_dio_40m.bin" ]; then
                    BOOTLOADER_PATH="$path/bootloader_dio_40m.bin"
                    break
                fi
            done
            
            for path in "$ESP32_PATH/tools/partitions" "$ESP32_PATH/tools/sdk/esp32/bin" "$ESP32_PATH/tools/sdk/bin"; do
                if [ -f "$path/boot_app0.bin" ]; then
                    BOOT_APP0_PATH="$path/boot_app0.bin"
                    break
                fi
            done
            
            if [ -n "$BOOTLOADER_PATH" ] && [ -n "$BOOT_APP0_PATH" ]; then
                if command -v esptool.py >/dev/null 2>&1; then
                    esptool.py --chip esp32 merge_bin -o test_builds/$name/aura_merged.bin \
                        0x1000 "$BOOTLOADER_PATH" \
                        0x8000 test_builds/$name/aura.ino.partitions.bin \
                        0xe000 "$BOOT_APP0_PATH" \
                        0x10000 test_builds/$name/aura.ino.bin 2>/dev/null
                    
                    if [ -f "test_builds/$name/aura_merged.bin" ]; then
                        echo "   ✅ Merged binary created: $(ls -lh test_builds/$name/aura_merged.bin)"
                    else
                        echo "   ❌ Failed to create merged binary"
                    fi
                else
                    echo "   ⚠️  esptool.py not found, skipping merged binary"
                fi
            else
                echo "   ⚠️  Could not find all required system binaries"
                echo "      Bootloader: $BOOTLOADER_PATH"
                echo "      Boot app0: $BOOT_APP0_PATH"
            fi
        fi
        
    else
        echo "❌ FAILED: $name build failed"
    fi
done

echo ""
echo "===================="
echo "Test Summary:"
echo "===================="

# Show successful builds
SUCCESS_COUNT=0
for name in "${CONFIG_NAMES[@]}"; do
    if [ -f "test_builds/$name/aura.ino.bin" ]; then
        echo "✅ $name"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ $name"
    fi
done

echo ""
echo "Successful builds: $SUCCESS_COUNT/${#CONFIG_NAMES[@]}"

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo "Recommendation: Use one of the successful configurations above."
    echo "The 'esp32dev' variant is often most compatible with CYD boards."
fi
