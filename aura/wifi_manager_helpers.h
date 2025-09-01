#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Public helpers. Keep header free of WiFiManager-dependent types/symbols.
void setup_wifi_manager(const char *ap_ssid);
void wifi_reset_settings(void);

#ifdef __cplusplus
}
#endif
