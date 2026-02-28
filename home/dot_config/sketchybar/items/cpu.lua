local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local cpu = sbar.add("item", "cpu", {
  position = "right",
  icon = {
    string = icons.cpu,
    color = colors.comment,
    font = {
      family = settings.font,
      style = "Regular",
      size = 14.0,
    },
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    width = 34,
    align = "right",
    color = colors.comment,
    padding_left = 1,
    font = {
      family = settings.font,
      style = "Regular",
      size = 12.0,
    },
    padding_right = 4,
  },
  update_freq = 2,
  background = { drawing = false },
})

local function update()
  sbar.exec(
    "ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s/c}' c=$(sysctl -n hw.logicalcpu)",
    function(result)
      local usage = tonumber(result) or 0

      local color = colors.muted_green
      if usage >= 80 then
        color = colors.muted_red
      elseif usage >= 50 then
        color = colors.muted_yellow
      end

      cpu:set({
        label = {
          string = string.format("%d%%", math.min(usage, 999)),
          color = color,
        },
        icon = { color = color },
      })
    end
  )
end

cpu:subscribe("routine", update)
cpu:subscribe("forced", update)

update()
