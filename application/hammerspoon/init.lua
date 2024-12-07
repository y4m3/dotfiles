function toggleApp(appName)
  local app = hs.application.find(appName)
  if app and app:isFrontmost() then
    app:hide()
  else
    hs.application.launchOrFocus(appName)
  end
end

hs.hotkey.bind({ "shift", "ctrl" }, "H", function()
  toggleApp("Wezterm")
end)

hs.hotkey.bind({ "shift", "ctrl" }, "Space", function()
  toggleApp("Visual Studio Code")
end)
