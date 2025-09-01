#pragma once
#include <Arduino.h>

// These helpers intentionally DO NOT expose WiFiManager in the header.
// That keeps library types out of public headers and avoids incomplete-type errors.

#ifdef AURA_ENABLE_WIFI
void setup_wifi_manager(const char* ap_ssid);
void wifi_reset_settings();
#else
// No-ops when WiFi is disabled
inline void setup_wifi_manager(const char*) {}
inline void wifi_reset_settings() {}
#endif
