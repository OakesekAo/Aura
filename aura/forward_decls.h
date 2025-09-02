#pragma once
#include <lvgl.h>

// Avoid Arduino auto-proto pitfalls by declaring the callbacks we use.
// Keep "static" on callbacks to match definitions inside aura.ino.
#ifdef __cplusplus
extern "C" {
#endif

// Callbacks (defined as static in aura.ino)
static void daily_cb(lv_event_t *e);
static void hourly_cb(lv_event_t *e);
static void reset_confirm_yes_cb(lv_event_t *e);
static void reset_confirm_no_cb(lv_event_t *e);
static void change_location_event_cb(lv_event_t *e);

// Non-static helpers implemented in aura.ino
void update_clock(void);
const lv_font_t* get_font_12(void);
const lv_font_t* get_font_14(void);
const lv_font_t* get_font_16(void);
const lv_font_t* get_font_20(void);
const lv_font_t* get_font_42(void);

// We only need a forward-decl for LocalizedStrings here.
// (The full definition comes via strings.h in aura_includes.h)
struct LocalizedStrings;
static inline const LocalizedStrings* get_strings(void); // implemented in aura.ino

const lv_img_dsc_t* choose_image(int code, int is_day);
const lv_img_dsc_t* choose_icon(int code, int is_day);

#ifdef __cplusplus
}
#endif
