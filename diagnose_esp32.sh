#!/bin/bash
# ESP32 Hardware Diagnostic Script
# Usage: ./diagnose_esp32.sh [serial_port]

SERIAL_PORT="${1:-/dev/ttyUSB0}"

echo "🔧 ESP32 Hardware Diagnostic Tool"
echo "================================="
echo "Port: $SERIAL_PORT"
echo ""

# Check if esptool is available
if ! command -v esptool.py &> /dev/null; then
    echo "❌ esptool.py not found. Please install it:"
    echo "   pip install esptool"
    exit 1
fi

# Check if port exists
if [ ! -e "$SERIAL_PORT" ]; then
    echo "❌ Serial port $SERIAL_PORT not found."
    echo ""
    echo "Available ports:"
    ls /dev/tty* 2>/dev/null | grep -E "(USB|ACM)" || echo "  No USB/ACM ports found"
    exit 1
fi

echo "🔍 Attempting to connect to ESP32..."

# Basic connectivity test
if ! esptool.py --port "$SERIAL_PORT" chip_id > /tmp/esp32_info.txt 2>&1; then
    echo "❌ Failed to connect to ESP32"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check USB cable (must be data cable, not charging-only)"
    echo "2. Check if device is in download mode (hold BOOT button while pressing EN/RST)"
    echo "3. Try different USB port"
    echo "4. Check if another program is using the port"
    echo "5. Try with sudo (Linux/macOS)"
    echo ""
    echo "Error details:"
    cat /tmp/esp32_info.txt
    exit 1
fi

echo "✅ ESP32 connection successful!"
echo ""

# Display chip information
echo "📊 Hardware Information:"
echo "======================="
cat /tmp/esp32_info.txt | grep -E "(Chip is|Features:|Crystal is|MAC|Flash size)"

# Get flash information
echo ""
echo "💾 Flash Information:"
echo "===================="
esptool.py --port "$SERIAL_PORT" flash_id 2>/dev/null | grep -E "(Manufacturer|Device|Detected flash size)"

# Check if bootloader is responsive
echo ""
echo "🔄 Bootloader Status:"
echo "===================="
if timeout 10s esptool.py --port "$SERIAL_PORT" read_flash 0x0 0x10 /tmp/test_read.bin >/dev/null 2>&1; then
    echo "✅ Bootloader responding normally"
    FLASH_HEADER=$(xxd -l 4 -p /tmp/test_read.bin | tr -d '\n')
    echo "   Flash header: 0x$FLASH_HEADER"
    
    if [ "${FLASH_HEADER:0:2}" = "e9" ]; then
        echo "   ✅ Valid ESP32 firmware detected"
    elif [ "$FLASH_HEADER" = "ffffffff" ]; then
        echo "   ⚠️  Flash appears empty/erased"
    else
        echo "   ⚠️  Unknown firmware signature"
    fi
else
    echo "⚠️  Bootloader not responding or corrupted"
fi

# Test current firmware boot (if any)
echo ""
echo "🔍 Current Firmware Test:"
echo "========================"
echo "Checking for boot messages (5 second timeout)..."

# Reset ESP32 and capture boot output
if command -v screen &> /dev/null; then
    echo "   Resetting ESP32..."
    # Trigger reset via DTR/RTS (works on most dev boards)
    python3 -c "
import serial
import time
try:
    ser = serial.Serial('$SERIAL_PORT', 115200, timeout=1)
    ser.setDTR(False)
    ser.setRTS(True)
    time.sleep(0.1)
    ser.setRTS(False)
    time.sleep(0.1)
    
    # Read boot messages
    start_time = time.time()
    boot_output = ''
    while time.time() - start_time < 5:
        if ser.in_waiting:
            data = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
            boot_output += data
            print(data, end='')
        time.sleep(0.1)
    
    ser.close()
    
    # Analyze boot output
    if 'wrong chip id' in boot_output:
        print('\n❌ CHIP ID ERROR DETECTED!')
        print('   This confirms the issue exists.')
    elif 'rst:' in boot_output and 'load:' in boot_output:
        print('\n✅ Normal boot sequence detected')
    elif boot_output.strip():
        print('\n⚠️  Partial boot detected')
    else:
        print('\n⚠️  No boot output captured')
except Exception as e:
    print(f'Error during boot test: {e}')
" 2>/dev/null || echo "   Python serial test failed"
else
    echo "   screen command not available for boot test"
fi

echo ""
echo "📋 Diagnostic Summary:"
echo "====================="
echo "Hardware: $(cat /tmp/esp32_info.txt | grep "Chip is" | cut -d' ' -f3-)"
echo "Flash: $(esptool.py --port "$SERIAL_PORT" flash_id 2>/dev/null | grep "Detected flash size" | cut -d':' -f2 | xargs)"
echo "Port: $SERIAL_PORT"

echo ""
echo "🎯 Next Steps:"
echo "============="
echo "1. If hardware looks good, run firmware verification:"
echo "   ./verify_firmware.sh"
echo ""
echo "2. Flash the verified firmware:"
echo "   esptool.py --chip esp32 --port $SERIAL_PORT write_flash 0x0 aura-firmware-24-ili9341.bin"
echo ""
echo "3. Monitor for successful boot:"
echo "   screen $SERIAL_PORT 115200"

# Cleanup
rm -f /tmp/esp32_info.txt /tmp/test_read.bin

echo ""
echo "✅ Diagnostic complete!"
