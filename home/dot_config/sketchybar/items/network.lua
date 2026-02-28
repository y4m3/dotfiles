local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local network = sbar.add("item", "network", {
  position = "right",
  icon = {
    string = icons.wifi.connected,
    color = colors.muted_cyan,
    font = {
      family = settings.font,
      style = "Regular",
      size = 14.0,
    },
    padding_left = 4,
    padding_right = 4,
  },
  label = {
    color = colors.comment,
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
    "scutil --nwi | awk '/IPv4 network interface/{found=1} found && /en0/{print \"wifi\"; exit} /utun/{print \"vpn\"; exit}'",
    function(result)
      local net_type = result and result:gsub("%s+", "") or ""
      if net_type == "vpn" then
        network:set({
          icon = { string = icons.vpn, color = colors.muted_green },
          label = "VPN",
        })
      elseif net_type == "wifi" then
        network:set({
          icon = { string = icons.wifi.connected, color = colors.muted_cyan },
          label = "Wi-Fi",
        })
      else
        -- Fallback: check if en0 has an IP
        sbar.exec(
          "ipconfig getifaddr en0 2>/dev/null",
          function(ip)
            local addr = ip and ip:gsub("%s+", "") or ""
            if addr ~= "" then
              network:set({
                icon = { string = icons.wifi.connected, color = colors.muted_cyan },
                label = "Wi-Fi",
              })
            else
              network:set({
                icon = {
                  string = icons.wifi.disconnected,
                  color = colors.comment,
                },
                label = "Disconnected",
              })
            end
          end
        )
      end
    end
  )
end

network:subscribe("routine", update)
network:subscribe("forced", update)
network:subscribe("wifi_change", update)

update()
