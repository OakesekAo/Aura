


#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
    #include <WiFi.h>
    #include <WiFiManager.h>

// Local-only callback; not exposed in headers
static void apModeCallback(WiFiManager* mgr) {
    (void)mgr; // no-op for now
}

void setup_wifi_manager(const char* captive_ssid) {
    WiFi.mode(WIFI_STA);
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    const char* ssid = (captive_ssid && *captive_ssid) ? captive_ssid : "Aura";
    (void)wm.autoConnect(ssid); // ignore result in CI build
}

void reset_wifi_settings(void) {
    WiFiManager wm;
    wm.resetSettings();
}
#else
void setup_wifi_manager(const char*) {}
void reset_wifi_settings(void)    {}
#endif
