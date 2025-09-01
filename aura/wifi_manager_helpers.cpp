

#include "wifi_manager_helpers.h"
#include <WiFiManager.h>

static void apModeCallback(WiFiManager *mgr) {
    (void)mgr; // optional: add your AP-mode logging, LED flash, etc.
}

extern "C" {
void setup_wifi_manager(const char* ap_ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    const char* ssid = (ap_ssid && *ap_ssid) ? ap_ssid : "Aura";
    // Attempt to connect; if it fails, starts a captive portal with given SSID
    (void)wm.autoConnect(ssid);
}

void reset_wifi_settings() {
    WiFiManager wm;
    wm.resetSettings();
}
} // extern "C"
#ifndef AURA_ENABLE_WIFI
#define AURA_ENABLE_WIFI 1
#endif

#if AURA_ENABLE_WIFI
    #include <WiFiManager.h>

    // Keep callback internal to this TU so the header never mentions WiFiManager
    static void apModeCallback(WiFiManager* mgr) {
        (void)mgr; // placeholder; add logging if desired
    }

#else
    void setup_wifi_manager(const char*) {}
    void reset_wifi_settings() {}
#endif
