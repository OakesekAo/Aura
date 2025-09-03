#pragma once
#include <Arduino.h>
#include <WiFi.h>

// Provide a local fallback if the app didn't define this already.
#ifndef AURA_HAVE_WIFI_RESET_SETTINGS
static inline void wifi_reset_settings() {
  // Disconnect and erase saved credentials, then reboot
  WiFi.disconnect(true /* wifioff */, true /* erase */);
  delay(150);
  ESP.restart();
}
#endif
