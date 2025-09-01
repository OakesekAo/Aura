#pragma once

#ifndef AURA_ENABLE_WIFI
#define AURA_ENABLE_WIFI 1
#endif

#if AURA_ENABLE_WIFI
	#include <WiFiManager.h>
	// Called by WiFiManager when the AP portal starts
	void apModeCallback(WiFiManager* mgr);
	// Start/configure WiFi via captive portal
	void wifi_begin_portal(const char* ssid);
	// Factory-reset WiFi credentials
	void wifi_reset_all();
#else
	inline void wifi_begin_portal(const char*) {}
	inline void wifi_reset_all() {}
#endif
