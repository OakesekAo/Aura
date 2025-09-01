
#include "wifi_manager_helpers.h"

#if AURA_ENABLE_WIFI
    #include <WiFiManager.h>
    #include <Arduino.h>

    static void apModeCallback(WiFiManager* mgr) {
        (void)mgr; // optional: add logging/LED here
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
