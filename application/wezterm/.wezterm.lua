local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu"

config.enable_kitty_keyboard = true
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
config.window_background_opacity = 0.9
config.text_background_opacity = 0.9

-- tab
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  return { {
    Text = "   " .. tostring(tab.tab_index + 1) .. "   ",
  } }
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
  active_titlebar_bg = "#4285f4",
  font = wezterm.font("UDEV Gothic NFLG", {
    weight = "Bold",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 10,
}

-- colors
config.color_scheme = "Tokyo Night (Gogh)"
-- config.color_scheme = "Catppuccin Latte"
-- config.color_scheme = "Solar Flare Light (base16)"

-- key mappings
config.leader = {
  key = "q",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}
config.keys = {
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "q",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentTab({
      confirm = true,
    }),
  },
  {
    key = "n",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "w",
    mods = "LEADER",
    action = wezterm.action.ShowTabNavigator,
  },
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentTab({
      confirm = true,
    }),
  },
  {
    key = "v",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({
      domain = "CurrentPaneDomain",
    }),
  },
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({
      domain = "CurrentPaneDomain",
    }),
  },
  {
    key = "x",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({
      confirm = true,
    }),
  },
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "H",
    mods = "LEADER",
    action = wezterm.action.AdjustPaneSize({ "Left", 10 }),
  },
  {
    key = "L",
    mods = "LEADER",
    action = wezterm.action.AdjustPaneSize({ "Right", 10 }),
  },
  {
    key = "K",
    mods = "LEADER",
    action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "J",
    mods = "LEADER",
    action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
  },
  {
    key = "v",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PasteFrom("Clipboard"),
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
