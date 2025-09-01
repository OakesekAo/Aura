#pragma once

#ifndef AURA_ENABLE_WIFI
#define AURA_ENABLE_WIFI 1
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Start/configure WiFi via captive portal
void wifi_begin_portal(const char* ssid);

// Factory-reset WiFi credentials
void wifi_reset_all(void);

#ifdef __cplusplus
}
#endif
