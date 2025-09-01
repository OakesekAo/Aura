#pragma once

#if defined(AURA_SCREEN_24_ILI9341)
  #define AURA_TFT_WIDTH   240
  #define AURA_TFT_HEIGHT  320
  #define AURA_TFT_BL      32     // adjust if your BL pin differs
  #define AURA_SCREEN_NAME "2.4\" ILI9341"
#elif defined(AURA_SCREEN_24_ST7789)
  #define AURA_TFT_WIDTH   240
  #define AURA_TFT_HEIGHT  320
  #define AURA_TFT_BL      32
  #define AURA_SCREEN_NAME "2.4\" ST7789"
#elif defined(AURA_SCREEN_28_ILI9341)
  #define AURA_TFT_WIDTH   240
  #define AURA_TFT_HEIGHT  320
  #define AURA_TFT_BL      32
  #define AURA_SCREEN_NAME "2.8\" ILI9341"
#else
  #error "Select one: AURA_SCREEN_24_ILI9341, AURA_SCREEN_24_ST7789, or AURA_SCREEN_28_ILI9341"
#endif
