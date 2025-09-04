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

---

**Last Updated**: September 4, 2025  
**Current Release**: v1.0.2-web-installer  
**Primary Hardware**: 2.4" ILI9341/ST7789 displays
