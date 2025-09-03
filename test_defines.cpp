#include "config/screen_select.h"
void test() {
#ifdef AURA_TFT_BL
Serial.println("AURA_TFT_BL is defined");
#else
Serial.println("AURA_TFT_BL is NOT defined");
#endif
}
