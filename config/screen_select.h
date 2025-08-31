// Select screen config based on AURA_SCREEN macro
#if defined(AURA_SCREEN) && AURA_SCREEN == 24_ILI9341
  #include "config/screen/aura_24_ili9341.h"
#elif defined(AURA_SCREEN) && AURA_SCREEN == 24_ST7789
  #include "config/screen/aura_24_st7789.h"
#else
  #include "config/screen/aura_28_ili9341.h"
#endif
