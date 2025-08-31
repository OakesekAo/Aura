#pragma once
// Default to 2.8" ILI9341 unless a 2.4" target is defined

#if defined(AURA_SCREEN_24_ILI9341)
  #include "screen/aura_24_ili9341.h"
#elif defined(AURA_SCREEN_24_ST7789)
  #include "screen/aura_24_st7789.h"
#else
  // Fallback / default
  #include "screen/aura_28_ili9341.h"
#endif
