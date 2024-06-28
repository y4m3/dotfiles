local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu"

config.enable_kitty_graphics = true
config.enable_wayland = true

-- window
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 0,
  top = 10,
  bottom = 0,
}
config.window_background_opacity = 0.8
config.text_background_opacity = 0.8

-- tab
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  return {
    { Text = "   " .. tostring(tab.tab_index + 1) .. "   " },
  }
end)
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 30
config.use_fancy_tab_bar = false

-- font
config.adjust_window_size_when_changing_font_size = true
config.font = wezterm.font("UDEV Gothic NFLG", {
  weight = "Regular",
  stretch = "Normal",
  style = "Normal",
})
config.font_size = 14
config.window_frame = {
  active_titlebar_bg = "#333333",
  font = wezterm.font("UDEV Gothic NFLG", {
    weight = "Bold",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 10,
}

-- colors
config.color_scheme = "Tokyo Night (Gogh)"

-- key mappings
config.keys = {
  {
    key = "T",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab("DefaultDomain"),
  },
  {
    key = "W",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentTab({ confirm = true }),
  },
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ToggleFullScreen,
  },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "CTRL",
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config
