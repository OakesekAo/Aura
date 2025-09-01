#include "wifi_manager_helpers.h"
#include "config/screen_select.h"

void apModeCallback(WiFiManager* mgr) {
    // Splash screen logic (move from aura.ino)
    extern void wifi_splash_screen();
    extern void flush_wifi_splashscreen();
    wifi_splash_screen();
    flush_wifi_splashscreen();
}

void setup_wifi_manager(const char* ssid) {
    WiFiManager wm;
    wm.setAPCallback(apModeCallback);
    wm.autoConnect(ssid);
}
