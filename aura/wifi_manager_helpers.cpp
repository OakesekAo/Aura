
#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
#include <Arduino.h>

void apModeCallback(WiFiManager* mgr) {
    (void)mgr; // hook for logging/LED if you want
}

void wifi_begin_portal(const char* ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    wm.autoConnect((ssid && ssid[0]) ? ssid : "Aura");
}

void wifi_reset_all() {
    WiFiManager wm;
    wm.resetSettings();
}
#endif
