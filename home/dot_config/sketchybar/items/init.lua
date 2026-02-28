local colors = require("colors")

-- Left side
require("items.aerospace")

-- Right side (first added = rightmost)
require("items.cpu")
require("items.memory")
require("items.battery")
require("items.network")
require("items.calendar")

-- Right-side bracket: system info grouping
sbar.add("bracket", { "cpu", "memory", "battery", "network" }, {
  background = {
    color = colors.bracket.bg,
    border_color = colors.bracket.border,
    border_width = 1,
    corner_radius = 4,
    height = 24,
  },
})
