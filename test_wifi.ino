#include <WiFi.h>
#include <WiFiManager.h>

void setup() {
  Serial.begin(115200);
  
  WiFiManager wm;
  
  if (!wm.autoConnect("Test")) {
    Serial.println("Failed to connect");
  } else {
    Serial.println("Connected");
  }
}

void loop() {
}
