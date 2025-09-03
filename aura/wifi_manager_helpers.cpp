


#include <Arduino.h>
#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
    #ifndef ESP32
    #define ESP32
    #endif
    #include <WiFi.h>
    #include <WiFiManager.h>

void setup_wifi_manager(const char* captive_ssid) {
    WiFiManager wm;
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
