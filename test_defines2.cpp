#ifdef AURA_28_ILI9341
#include "config/screen/aura_28_ili9341.h"
#endif
void test() {
#ifdef AURA_TFT_BL
Serial.println("AURA_TFT_BL is defined: " + String(AURA_TFT_BL));
#else
Serial.println("AURA_TFT_BL is NOT defined");
#endif
}
