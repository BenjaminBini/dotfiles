local colors = require("colors")
local settings = require("settings")

local menu_watcher = sbar.add("item", {
    drawing = false,
    updates = false
})
local space_menu_swap = sbar.add("item", {
    drawing = false,
    updates = true
})
sbar.add("event", "swap_menus_and_spaces")

local max_items = 15


sbar.add("bracket", {'/menu\\..*/'}, {
    background = {
        color = colors.bg1
    }
})


return menu_watcher
