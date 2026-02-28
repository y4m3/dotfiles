local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local cal = sbar.add("item", "calendar", {
  position = "right",
  icon = {
    string = icons.clock,
    color = colors.muted_blue,
    font = {
      family = settings.font,
      style = "Regular",
      size = 14.0,
    },
    padding_left = 8,
    padding_right = 4,
  },
  label = {
    color = colors.comment,
    font = {
      family = settings.font,
      style = "Regular",
      size = 12.0,
    },
    padding_left = 0,
    padding_right = 8,
  },
  update_freq = 30,
  background = { drawing = false },
})

local function update()
  local time = os.date("%H:%M")
  local date = os.date("%m/%d %a")
  cal:set({ label = time .. "  " .. date })
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)

update()
