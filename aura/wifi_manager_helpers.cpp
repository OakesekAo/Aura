

#include "wifi_manager_helpers.h"
#include <WiFiManager.h>

static void apModeCallback(WiFiManager *mgr) {
    (void)mgr; // optional: add your AP-mode logging, LED flash, etc.
}

extern "C" {
void setup_wifi_manager(const char* ap_ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    // blocking connect; returns bool, but we don't need it for CI compile
    (void)wm.autoConnect(ap_ssid);
}

void reset_wifi_settings() {
    WiFiManager wm;
    wm.resetSettings();
}
} // extern "C"
