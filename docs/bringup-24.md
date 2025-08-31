# Aura 2.4″ Screen Bring-Up Guide

## Supported Drivers
- ILI9341 (default)
- ST7789 (alternate)

## Steps

1. **Wiring/Pinout**
   - Ensure your ESP32 is wired to the 2.4″ TFT as per the pin map in `config/screen/aura_24_ili9341.h` or `aura_24_st7789.h`.
   - Double-check power and backlight connections.

2. **Build & Flash**
   - Use Arduino CLI or IDE to build with:
     - ILI9341: `arduino-cli compile --fqbn esp32:esp32:esp32 --build-properties build.partitions=huge_app --build-properties build.extra_flags="-DAURA_SCREEN=24_ILI9341" aura/weather.ino`
     - ST7789:  `arduino-cli compile --fqbn esp32:esp32:esp32 --build-properties build.partitions=huge_app --build-properties build.extra_flags="-DAURA_SCREEN=24_ST7789" aura/weather.ino`
   - Flash the resulting `.bin` to your ESP32.

3. **If Screen Is Black**
   - Try the alternate driver (`ST7789` if ILI9341 fails, or vice versa).
   - Confirm pinout matches your display.
   - Check backlight pin and voltage.

4. **Troubleshooting**
   - Use a simple TFT_eSPI example to verify display and pinout.
   - Check serial output for errors.
   - If touch is not working, verify `TOUCH_CS` pin and wiring.

## Notes
- The correct `User_Setup.h` is copied automatically in CI; for local builds, copy the matching file from `TFT_eSPI/` to your Arduino libraries path.
- For more details, see the README and config headers.
