
#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
    #include <Arduino.h>
    #include <WiFiManager.h>

    static void apModeCallback(WiFiManager* mgr) {
        (void)mgr;
        // optional: Serial.println("AP mode started");
    }

    void wifi_begin_portal(const char* ssid) {
        WiFiManager wm;
        wm.setAPCallback(apModeCallback);
        wm.autoConnect((ssid && ssid[0]) ? ssid : "Aura");
    }

    void wifi_reset_all(void) {
        WiFiManager wm;
        wm.resetSettings();
    }
#else
    void wifi_begin_portal(const char*) {}
    void wifi_reset_all(void) {}
#endif
