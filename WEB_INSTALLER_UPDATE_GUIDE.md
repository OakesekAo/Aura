# Aura Web Installer Update Guide

## 🚨 Current Issues

Your existing web installer at `https://oakesekao.github.io/aura-installer/` has the following problems:

1. **Outdated firmware URLs**: Points to old v1.4.2 release that no longer exists
2. **Missing dual-flash support**: No option for component-based flashing (needed for chip ID error fix)
3. **Broken firmware links**: Current manifests point to non-existent firmware files

## ✅ Required Updates

### 1. Update Manifest Files

Replace the content of these files in your `aura-installer` repo:

#### `manifests/24_ILI9341.json` (Standard Method)
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

#### `manifests/24_ST7789.json` (Standard Method)
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

#### `manifests/28_ILI9341.json` (Standard Method)
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

### 2. Add Component-Based Manifests (Recommended for Chip ID Fix)

Create these new files:

#### `manifests/24_ILI9341_components.json`
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

#### `manifests/24_ST7789_components.json`
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

#### `manifests/28_ILI9341_components.json`
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

### 3. Update index.html for Dual Flash Support

Replace the variant selector section with:

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

### 4. Update Troubleshooting Section

Add this to your troubleshooting section:

```html
<h4>Wrong Chip ID 0x0002 Error?</h4>
<p>If you're getting "wrong chip id 0x0002" errors:</p>
<ol>
  <li><strong>Try the "Fix Chip ID Error" variant</strong> - Select your display type with "(Fix Chip ID Error)" in the dropdown</li>
  <li><strong>Hold BOOT button</strong> - Press and hold during connection</li>
  <li><strong>Try different USB cable/port</strong> - Some cables are power-only</li>
</ol>
```

## 🚀 Implementation Steps

1. **Clone your aura-installer repo**
2. **Update all manifest files** with the new URLs pointing to v1.0.7-dual-flash
3. **Add the new component-based manifest files**
4. **Update index.html** with dual flash support
5. **Commit and push changes**
6. **Test the installer** with both standard and component methods

## ✅ Verification

After updating, verify:
- [ ] All manifest URLs point to existing v1.0.7-dual-flash release assets
- [ ] Both standard and component variants are available for each display type
- [ ] Web installer loads without errors
- [ ] Firmware downloads work for both methods

## 🎯 Expected Result

After these updates, your web installer will:
- ✅ Work with the latest firmware (v1.0.7-dual-flash)
- ✅ Provide both standard and component-based flashing
- ✅ Fix the "wrong chip id 0x0002" error for problematic ESP32 boards
- ✅ Maintain backward compatibility with existing functionality

The component-based approach matches the BongoCat method that works on your hardware and should resolve the chip ID compatibility issues.
