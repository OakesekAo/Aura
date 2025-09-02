#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <lvgl.h>
#include "compat.h"

// Bring LocalizedStrings in BEFORE any function using it.
#if defined(__has_include)
#  if __has_include("strings.h")
#    include "strings.h"
#  endif
#else
// Fallback: try to include; if the file doesn’t exist, compiler will tell us.
#include "strings.h"
#endif
