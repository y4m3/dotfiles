local colors = require("colors")
local settings = require("settings")

-- Detect if built-in display has a notch (camera housing)
-- MacBook Air M2 (2560x1664), MacBook Pro 14" (3024x1964), 16" (3456x2234)
-- These resolutions have notch displays; external monitors do not
local function detect_bar_height()
  local handle = io.popen(
    "system_profiler SPDisplaysDataType 2>/dev/null"
    .. " | grep -B2 'Main Display: Yes'"
    .. " | grep 'Resolution'"
    .. " | head -1"
  )
  if not handle then return settings.bar_height end
  local result = handle:read("*a")
  handle:close()

  -- Check for known notch display resolutions
  local has_notch = result
    and (result:match("2560 x 1664")   -- MacBook Air M2
      or result:match("3024 x 1964")   -- MacBook Pro 14"
      or result:match("3456 x 2234")   -- MacBook Pro 16"
      or result:match("2560 x 1600")   -- MacBook Air M1
      or result:match("Liquid Retina"))

  if has_notch then
    return 37 -- Match notch height
  else
    return 28 -- Compact for external displays
  end
end

local bar_height = detect_bar_height()

sbar.bar({
  height = bar_height,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  border_width = 0,
  shadow = false,
  sticky = true,
  padding_right = 10,
  padding_left = 10,
  notch_width = settings.notch_width,
  blur_radius = 20,
  topmost = "window",
  y_offset = 0,
  corner_radius = 0,
  position = "top",
  display = "all",
})
