# MCP Agent Instructions: Fix Aura Web Installer Chip ID Error

## 🎯 CRITICAL ISSUE
The web installer at `https://oakesekao.github.io/aura-installer/` is serving **ESP32-S2 firmware (chip ID 0x0002)** to **ESP32 hardware (needs chip ID 0x0000)**. This causes "wrong chip id 0x0002" errors.

## 🚨 REQUIRED ACTIONS

### 1. IMMEDIATELY Replace Broken Manifest Files

**File: `manifests/28_ILI9341.json`**
**CURRENT CONTENT (BROKEN - SERVES ESP32-S2 FIRMWARE):**
```json
{
  "name": "Aura (2.8\" ILI9341)",
  "version": "v1.4.2",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        { "path": "https://oakesekao.github.io/aura-installer/firmware/aura-firmware-28-ILI9341.bin", "offset": 0 }
      ]
    }
  ]
}
```

**REPLACE WITH (CORRECT ESP32 FIRMWARE):**
```json
{
  "name": "Aura (2.8\" ILI9341) - Standard",
  "version": "v1.0.7-dual-flash",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        { 
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-firmware-28-ili9341.bin", 
          "offset": 0 
        }
      ]
    }
  ]
}
```

**File: `manifests/24_ILI9341.json`**
**REPLACE ENTIRE CONTENT WITH:**
```json
{
  "name": "Aura (2.4\" ILI9341) - Standard",
  "version": "v1.0.7-dual-flash",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        { 
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-firmware-24-ili9341.bin", 
          "offset": 0 
        }
      ]
    }
  ]
}
```

**File: `manifests/24_ST7789.json`**
**REPLACE ENTIRE CONTENT WITH:**
```json
{
  "name": "Aura (2.4\" ST7789) - Standard",
  "version": "v1.0.7-dual-flash", 
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        { 
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-firmware-24-st7789.bin", 
          "offset": 0 
        }
      ]
    }
  ]
}
```

### 2. CREATE New Component-Based Manifests (BongoCat Fix)

**CREATE FILE: `manifests/28_ILI9341_components.json`**
```json
{
  "name": "Aura (2.8\" ILI9341) - Components (Fix Chip ID Error)",
  "version": "v1.0.7-dual-flash",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-bootloader-28-ili9341.bin",
          "offset": 4096
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-partitions-28-ili9341.bin",
          "offset": 32768
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-boot-app0-28-ili9341.bin",
          "offset": 57344
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-app-28-ili9341.bin",
          "offset": 65536
        }
      ]
    }
  ]
}
```

**CREATE FILE: `manifests/24_ILI9341_components.json`**
```json
{
  "name": "Aura (2.4\" ILI9341) - Components (Fix Chip ID Error)",
  "version": "v1.0.7-dual-flash",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-bootloader-24-ili9341.bin",
          "offset": 4096
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-partitions-24-ili9341.bin",
          "offset": 32768
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-boot-app0-24-ili9341.bin",
          "offset": 57344
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-app-24-ili9341.bin",
          "offset": 65536
        }
      ]
    }
  ]
}
```

**CREATE FILE: `manifests/24_ST7789_components.json`**
```json
{
  "name": "Aura (2.4\" ST7789) - Components (Fix Chip ID Error)",
  "version": "v1.0.7-dual-flash",
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-bootloader-24-st7789.bin",
          "offset": 4096
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-partitions-24-st7789.bin",
          "offset": 32768
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-boot-app0-24-st7789.bin",
          "offset": 57344
        },
        {
          "path": "https://github.com/OakesekAo/Aura/releases/download/v1.0.7-dual-flash/aura-app-24-st7789.bin",
          "offset": 65536
        }
      ]
    }
  ]
}
```

### 3. UPDATE index.html

**FIND THIS SECTION IN index.html:**
```html
<div class="mb-4">
  <label for="variant" class="form-label"><strong>Screen Type:</strong></label>
  <select id="variant" class="form-select">
    <option value="24_ILI9341">2.4" ILI9341</option>
    <option value="24_ST7789">2.4" ST7789</option>
    <option value="28_ILI9341" selected>2.8" ILI9341 (Most Common)</option>
  </select>
</div>
```

**REPLACE WITH:**
```html
<div class="mb-4">
  <label for="variant" class="form-label"><strong>Screen Type:</strong></label>
  <select id="variant" class="form-select">
    <option value="24_ILI9341">2.4" ILI9341 (Standard)</option>
    <option value="24_ILI9341_components">2.4" ILI9341 (Fix Chip ID Error)</option>
    <option value="24_ST7789">2.4" ST7789 (Standard)</option>
    <option value="24_ST7789_components">2.4" ST7789 (Fix Chip ID Error)</option>
    <option value="28_ILI9341" selected>2.8" ILI9341 (Standard)</option>
    <option value="28_ILI9341_components">2.8" ILI9341 (Fix Chip ID Error)</option>
  </select>
</div>

<div class="alert alert-info">
  <h6>🔧 Having "wrong chip id 0x0002" errors?</h6>
  <p>Select the "Fix Chip ID Error" variant for your display type. This uses separate components approach that works better with some ESP32 boards.</p>
</div>
```

**FIND THIS SECTION (around line 100+):**
```html
<h4>Help! Installation gets stuck at "Preparing to Install."</h4>
```

**ADD BEFORE THAT SECTION:**
```html
<h4>🚨 Wrong Chip ID 0x0002 Error?</h4>
<p>If you're getting "wrong chip id 0x0002" errors:</p>
<ol>
  <li><strong>Try the "Fix Chip ID Error" variant</strong> - Select your display type with "(Fix Chip ID Error)" in the dropdown above</li>
  <li><strong>Hold BOOT button</strong> - Press and hold during connection</li>
  <li><strong>Try different USB cable/port</strong> - Some cables are power-only</li>
</ol>
<p><strong>Technical reason:</strong> The old firmware was compiled for ESP32-S2 (chip ID 0x0002) but your hardware is ESP32 (chip ID 0x0000). The "Fix Chip ID Error" variants use the correct ESP32 firmware.</p>
```

## ⚡ EXECUTION COMMANDS

1. **Clone the repo:**
```bash
git clone https://github.com/OakesekAo/aura-installer.git
cd aura-installer
```

2. **Replace broken manifests:**
```bash
# Replace all 3 existing manifest files with correct content above
```

3. **Create new component manifests:**
```bash
# Create the 3 new _components.json files with content above
```

4. **Update index.html:**
```bash
# Update the HTML sections as specified above
```

5. **Commit and push:**
```bash
git add .
git commit -m "CRITICAL FIX: Replace ESP32-S2 firmware with correct ESP32 firmware

- Fix 'wrong chip id 0x0002' error by serving correct ESP32 firmware
- Add component-based flashing option for better hardware compatibility  
- Update UI to provide both standard and component flash methods
- All manifests now point to v1.0.7-dual-flash with correct chip ID"

git push
```

## 🎯 VERIFICATION

After deployment, verify:
- [ ] https://oakesekao.github.io/aura-installer/manifests/28_ILI9341.json shows v1.0.7-dual-flash
- [ ] https://oakesekao.github.io/aura-installer/manifests/28_ILI9341_components.json exists
- [ ] Web installer shows both Standard and "Fix Chip ID Error" options
- [ ] No more "wrong chip id 0x0002" errors when using updated firmware

## 💡 WHY THIS FIXES THE ERROR

**Current problem:** Serving ESP32-S2 firmware (0x0002) to ESP32 hardware (0x0000)
**Solution:** Serve correct ESP32 firmware (0x0000) that matches the hardware
**Result:** No more chip ID mismatch errors

The component-based approach provides additional compatibility for ESP32 boards that have trouble with merged binaries.
