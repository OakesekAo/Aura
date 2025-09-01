#pragma once
#include <lvgl.h>
#ifdef __cplusplus
extern "C" {
#endif
lv_display_t* lv_tft_espi_create(int32_t hor_res, int32_t ver_res, void* buf, size_t buf_size);
#ifdef __cplusplus
}
#endif
