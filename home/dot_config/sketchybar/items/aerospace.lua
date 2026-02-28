local colors = require("colors")
local settings = require("settings")

local spaces = {}
local order = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }

sbar.add("event", "aerospace_workspace_change")

local function refresh_spaces(focused)
  -- Single command: get all occupied workspace numbers
  sbar.exec(
    "aerospace list-windows --all --format '%{workspace}' 2>/dev/null | sort -u | tr '\\n' ' '",
    function(result)
      local occupied = {}
      if result then
        for ws in result:gmatch("%S+") do
          occupied[ws] = true
        end
      end

      for _, i in ipairs(order) do
        local ws_str = tostring(i)
        local is_active = focused == ws_str
        local visible = is_active or occupied[ws_str] == true

        spaces[i]:set({
          drawing = visible,
          icon = {
            color = is_active and colors.blue or colors.dark5,
            font = {
              style = is_active and "Bold" or "Regular",
            },
          },
          background = {
            color = is_active and colors.selection or colors.transparent,
          },
        })
      end
    end
  )
end

local function refresh_with_query()
  sbar.exec("aerospace list-workspaces --focused", function(result)
    local focused = result and result:gsub("%s+", "") or "1"
    refresh_spaces(focused)
  end)
end

for _, i in ipairs(order) do
  local space = sbar.add("item", "space." .. i, {
    position = "left",
    drawing = false,
    icon = {
      string = tostring(i),
      font = {
        family = settings.font,
        style = "Bold",
        size = 13.0,
      },
      color = colors.comment,
      padding_left = 8,
      padding_right = 8,
    },
    label = { drawing = false },
    padding_left = 1,
    padding_right = 1,
    background = {
      color = colors.transparent,
      corner_radius = 4,
      height = 20,
    },
  })

  space:subscribe("mouse.clicked", function()
    sbar.exec("aerospace workspace " .. tostring(i))
  end)

  spaces[i] = space
end

-- Sentinel: always receives events regardless of drawing state
local space_sentinel = sbar.add("item", "space.sentinel", {
  drawing = false,
  updates = true,
  update_freq = 2,
})

space_sentinel:subscribe("aerospace_workspace_change", function(env)
  local focused = env.FOCUSED_WORKSPACE
  if focused and focused ~= "" then
    refresh_spaces(focused)
  else
    refresh_with_query()
  end
end)

space_sentinel:subscribe("routine", refresh_with_query)

-- Initialize on startup
refresh_with_query()
