local logger = require("logger")
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local sbar = require("sketchybar")
local deferred = require("deferred")

local function exec(cmd)
    local d = deferred.new()
    sbar.exec(cmd, function(result, exit_code)
        if exit_code ~= 0 then
            logger.warning("Failed to execute command: " .. cmd .. " (exit code: " .. exit_code .. ")")
            logger.warning("Result: " .. tostring(result))
            return d:reject(exit_code)
        end
        return d:resolve(result)
    end)
    return d
end

local function move_item_after_other_item(item_name, other_item_name)
    -- Add a small delay to ensure items exist before moving
    return exec("sketchybar --move " .. item_name .. " after " .. other_item_name)
end


local function move_window_item_after_workspace(window_item_name, workspace)
    if (workspace == nil) then
        error("Cannot move window item after workspace, workspace is nil", 2)
    end
    return move_item_after_other_item(window_item_name, workspace)
end

local function get_display_id_for_monitor_id(
    monitor_id)
    local displays_items = sbar.query("displays")
    for _, display in pairs(displays_items) do
        if display["DirectDisplayID"] == monitor_id then
            return display["arrangement-id"]
        end
    end
end

local function get_display_id_for_sbar_item(aerospace_object)
    local monitor_id = aerospace_object["monitor-appkit-nsscreen-screens-id"]
    if monitor_id == nil then
        return nil
    end
    return get_display_id_for_monitor_id(monitor_id)
end

local function set_item_color(item_name, color)
    sbar.set(item_name, {
        icon = {
            color = color
        }
    })
end
return {
    move_item_after_other_item       = move_item_after_other_item,
    move_window_item_after_workspace = move_window_item_after_workspace,
    get_display_id_for_sbar_item     = get_display_id_for_sbar_item,
    get_display_id_for_monitor_id    = get_display_id_for_monitor_id,
    set_item_color                   = set_item_color,
    exec                             = exec
}
