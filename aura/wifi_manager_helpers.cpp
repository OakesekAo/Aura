


#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
    #include <WiFi.h>
    #include <WiFiManager.h>

// Local-only callback; not exposed in headers
static void apModeCallback(WiFiManager* mgr) {
    (void)mgr;
    Serial.println("[Aura] WiFiManager AP mode active");
}

void setup_wifi_manager(const char* captive_ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    const char* ssid = (captive_ssid && *captive_ssid) ? captive_ssid : "Aura";
    if (!wm.autoConnect(ssid)) {
        Serial.println("[Aura] WiFi autoConnect failed, continuing without WiFi");
    } else {
        Serial.println("[Aura] WiFi connected");
    }
}

void reset_wifi_settings() {
    WiFiManager wm;
    wm.resetSettings();
}
#else
void setup_wifi_manager(const char*) {}
void reset_wifi_settings(void)    {}
#endif
