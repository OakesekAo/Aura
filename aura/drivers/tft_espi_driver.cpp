#include "tft_espi_driver.h"
#include <TFT_eSPI.h>

static TFT_eSPI tft;  // uses User_Setup.h selected in CI

static void my_flush_cb(lv_display_t* disp, const lv_area_t* area, uint8_t* px_map) {
  // area defines a rectangle to update; px_map points to lv_color_t pixels
  int32_t w = area->x2 - area->x1 + 1;
  int32_t h = area->y2 - area->y1 + 1;

  tft.startWrite();
  tft.setAddrWindow(area->x1, area->y1, w, h);
  tft.pushPixels(reinterpret_cast<const uint16_t*>(px_map), w * h);
  tft.endWrite();

  lv_display_flush_ready(disp);
}

lv_display_t* lv_aura_tft_espi_create(int32_t hor_res, int32_t ver_res, void* buf, size_t buf_size) {
  tft.begin();
  // Rotation: 1 suits 320x240 landscape on many ILI9341 boards; adjust later per screen config if needed
  tft.setRotation(1);

  lv_display_t* disp = lv_display_create(hor_res, ver_res);

  // buf is a raw byte buffer provided by the sketch; convert bytes to pixels
  size_t px_cnt = buf_size / sizeof(lv_color_t);
  lv_display_set_buffers(disp, buf, nullptr, px_cnt, LV_DISPLAY_RENDER_MODE_PARTIAL);
  lv_display_set_flush_cb(disp, my_flush_cb);

  return disp;
}
