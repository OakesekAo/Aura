#pragma once

// Minimal compile-time shape info; refine pin maps/User_Setup later
#if defined(AURA_SCREEN_24_ST7789)
	#define AURA_TFT_WIDTH   240
	#define AURA_TFT_HEIGHT  320
	#define AURA_TFT_DRIVER_ST7789 1
#elif defined(AURA_SCREEN_24_ILI9341)
	#define AURA_TFT_WIDTH   240
	#define AURA_TFT_HEIGHT  320
	#define AURA_TFT_DRIVER_ILI9341 1
#else /* default to 2.8" ILI9341 */
	#define AURA_TFT_WIDTH   320
	#define AURA_TFT_HEIGHT  240
	#define AURA_TFT_DRIVER_ILI9341 1
#endif
