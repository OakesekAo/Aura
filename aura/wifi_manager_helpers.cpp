
#include "wifi_manager_helpers.h"

#include <WiFiManager.h>

static void apModeCallback(WiFiManager *mgr) {
    (void)mgr; // optional: add your AP-mode logging, LED flash, etc.
}

void setup_wifi_manager(const char *ap_ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    // NOTE: Customize to your project behavior. For a clean bring-up, try autoConnect().
    // You can replace with startConfigPortal if you want to force captive.
    if (!wm.autoConnect(ap_ssid && *ap_ssid ? ap_ssid : "Aura")) {
        // If it fails to connect, you can reset, or just return.
        // ESP.restart();  // optional
    }
}

void wifi_reset_settings(void) {
    WiFiManager wm;
    wm.resetSettings();
}
