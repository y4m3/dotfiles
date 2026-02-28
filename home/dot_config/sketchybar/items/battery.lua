local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = {
    string = icons.battery.full,
    color = colors.muted_green,
    font = {
      family = settings.font,
      style = "Regular",
      size = 16.0,
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
  update_freq = 30,
  background = { drawing = false },
})

local function update()
  local function set_fallback()
    battery:set({
      icon = {
        string = icons.battery.full,
        color = colors.comment,
      },
      label = {
        string = "--%",
        color = colors.comment,
      },
    })
  end

  sbar.exec(
    "pmset -g batt",
    function(result)
      if not result then
        set_fallback()
        return
      end

      local percent = tonumber(result:match("(%d+)%%"))
      local state = result:match(";%s*([^;]+);")
      state = state and state:lower()
      local charging = state == "charging"
        or state == "charged"
        or state == "finishing charge"

      local icon_str
      local color
      local label_str = percent and string.format("%d%%", percent) or "--%"

      if charging then
        icon_str = icons.battery.charging
        color = colors.muted_green
      elseif not percent then
        icon_str = icons.battery.full
        color = colors.comment
      elseif percent > 75 then
        icon_str = icons.battery.full
        color = colors.muted_green
      elseif percent > 50 then
        icon_str = icons.battery.b75
        color = colors.muted_green
      elseif percent > 25 then
        icon_str = icons.battery.b50
        color = colors.muted_yellow
      elseif percent > 10 then
        icon_str = icons.battery.b25
        color = colors.muted_red
      else
        icon_str = icons.battery.empty
        color = colors.muted_red
      end

      battery:set({
        icon = {
          string = icon_str,
          color = color,
        },
        label = {
          string = label_str,
          color = color,
        },
      })
    end
  )
end

battery:subscribe("routine", update)
battery:subscribe("forced", update)
battery:subscribe("power_source_change", update)
battery:subscribe("system_woke", update)

update()
