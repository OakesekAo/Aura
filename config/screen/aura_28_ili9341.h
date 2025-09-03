#pragma once
// Use dimensions matching the CYD 2.8" ILI9341
#define AURA_TFT_WIDTH   320
#define AURA_TFT_HEIGHT  240
// Map Aura backlight to TFT_eSPI's BL macro from User_Setup
#ifndef TFT_BL
	// fallback only if User_Setup doesn't define it (keeps compile going)
	#define TFT_BL 21
#endif
#define AURA_TFT_BL      TFT_BL
#define AURA_TFT_HEIGHT 320
