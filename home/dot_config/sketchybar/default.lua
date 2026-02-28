local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font,
      style = "Bold",
      size = settings.icon_size,
    },
    color = colors.comment,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font,
      style = "Regular",
      size = settings.label_size,
    },
    color = colors.comment,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 22,
    corner_radius = 4,
    border_width = 0,
  },
  popup = {
    background = {
      border_width = 1,
      corner_radius = 6,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 20,
  },
  padding_left = 2,
  padding_right = 2,
})
