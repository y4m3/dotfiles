local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local mem = sbar.add("item", "memory", {
  position = "right",
  icon = {
    string = icons.memory,
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
  update_freq = 5,
  background = { drawing = false },
})

local function update()
  sbar.exec(
    "memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$NF}'",
    function(result)
      local usage = tonumber(
        result and result:gsub("%%", ""):gsub("%s+", "")
      ) or 0

      local color = colors.muted_green
      if usage >= 80 then
        color = colors.muted_red
      elseif usage >= 50 then
        color = colors.muted_yellow
      end

      mem:set({
        label = {
          string = string.format("%d%%", usage),
          color = color,
        },
        icon = { color = color },
      })
    end
  )
end

mem:subscribe("routine", update)
mem:subscribe("forced", update)

update()
