

#include "wifi_manager_helpers.h"
#include <WiFiManager.h>

static void apModeCallback(WiFiManager *mgr) {
    (void)mgr; // optional: add your AP-mode logging, LED flash, etc.
}

extern "C" {
void setup_wifi_manager(const char *ap_ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    const char *ssid = (ap_ssid && *ap_ssid) ? ap_ssid : "Aura";
    wm.autoConnect(ssid);
}

void wifi_reset_settings(void) {
    WiFiManager wm;
    wm.resetSettings();
}
} // extern "C"
