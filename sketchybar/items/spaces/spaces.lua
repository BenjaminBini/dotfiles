local sbar = require("sketchybar")
local aerospace = require("helpers.spaces.aerospace")
local colors = require("colors")
local settings = require("settings")
local bar_helper = require("helpers.spaces.bar")
local logger = require("logger")
local app_icons = require("helpers.app_icons")
local inspect = require("inspect")
local currently_focused_window_id = nil
local opened_windows = {}    -- Map window ID to item name
local opened_workspaces = {} -- Map workspace to display id name
-- local workspace_window_count = {} -- Map workspace to number of windows

local handle_error = function(err)
    logger.error("Error: " .. tostring(err))
    return nil
end

local function delete_window_item(window_id, callback)
    sbar.animate("tanh", 10, function()
        sbar.set(tostring(window_id), {
            padding_left = -28,
            icon = {
                color = colors.transparent
            }
        })
    end)

    -- Remove from tracking
    local existing_window = opened_windows[tostring(window_id)]
    if (existing_window ~= nil) then
        sbar.exec("sleep .1", function()
            sbar.remove(tostring(window_id))
            logger.info("Removing window item " .. window_id .. " (" .. existing_window["app-name"] .. ")")
            opened_windows[tostring(window_id)] = nil
            if callback then callback() end
        end)
    else
        logger.warning("No opened window found for window item " .. window_id)
    end

    -- Clear focus if this was the focused window
    if currently_focused_window_id == tostring(window_id) then
        currently_focused_window_id = nil
    end
end

local function add_window_item(window)
    local window_id = tostring(window["window-id"])
    if opened_windows[tostring(window_id)] then
        logger.warning("Window item for window ID " .. window_id .. " already exists, skipping creation")
        return window_id
    end
    if not opened_windows[window_id] then
        local workspace = window["workspace"]
        local window_item = {
            display      = bar_helper.get_display_id_for_monitor_id(window["monitor-appkit-nsscreen-screens-id"]),
            drawing      = true,
            click_script = "/opt/homebrew/bin/aerospace focus --window-id " .. tostring(window_id),
            padding_left = -28,
            icon         = {
                string        = app_icons[window["app-name"]] or app_icons["default"],
                font          = settings.icons,
                color         = colors.transparent,
                padding_right = 0,
                padding_left  = 4,
            },
            label        = {
                drawing = false
            },
            background   = {
                drawing = false
            }
        }
        sbar.add("item", window_id, window_item)
        opened_windows[window_id] = window
        bar_helper.exec("sketchybar --move " .. tostring(window_id) .. " after " .. workspace)
        sbar.animate("tanh", 20, function()
            sbar.set(window_id, {
                padding_left = 4,
                icon = {
                    color = colors.apps_colors[workspace] or colors.grey,
                },
            })
        end)
    end
end


local function update_focused_window(new_focused_window)
    local new_focused_window_id = new_focused_window and tostring(new_focused_window["window-id"]) or nil
    local current_focused_window_id = currently_focused_window_id and tostring(currently_focused_window_id) or nil
    if new_focused_window_id == current_focused_window_id then
        logger.debug("Focused window unchanged, no action needed")
        return current_focused_window_id
    end
    if current_focused_window_id ~= nil then
        sbar.set(current_focused_window_id, {
            icon = {
                color = colors.with_alpha(colors.white, 0.4)
            }
        })
    end
    if (new_focused_window_id ~= nil) then
        sbar.set(tostring(new_focused_window_id), {
            icon = {
                color = colors.white
            }
        })
        logger.debug("Focused window item " .. new_focused_window_id)
    end
    currently_focused_window_id = new_focused_window_id
    return new_focused_window_id
end

local function init_window_items()
    logger.startup("START - WINDOWS_INIT - nitializing window items")
    return aerospace.query_all_windows()
        :next(function(all_windows)
            for _, window in pairs(all_windows) do
                add_window_item(window)
                logger.info("Added window " .. window["window-id"])
            end
            return all_windows
        end, handle_error)
        :next(function()
            logger.success("SUCCESS - WINDOWS_INIT - Window items initialized")
        end, function(err)
            logger.error("ERROR - WINDOWS_INIT - Failed to initialize window items: " .. err)
        end)
end

local function add_workspace_item(workspace_object)
    local workspace = workspace_object.workspace
    local display_id = bar_helper.get_display_id_for_sbar_item(workspace_object)

    local workspace_item = {
        drawing       = true,
        display       = display_id,
        click_script  = "/opt/homebrew/bin/aerospace workspace " .. tostring(workspace),
        icon          = {
            string        = workspace,
            font          = {
                family = "FiraCode Nerd Font Mono",
                size   = 14
            },
            color         = colors.apps_colors[workspace],
            padding_left  = 8,
            padding_right = 8
        },
        background    = {
            color         = colors.apps_colors[workspace],
            padding_left  = 16,
            padding_right = 2,
            height        = 10,
            y_offset      = 18,
            border_width  = 0
        },
        label         = {
            drawing = false
        },
        padding_left  = 16,
        padding_right = 4
    }
    sbar.add("space", workspace, workspace_item)
    opened_workspaces[workspace] = display_id
end

local function update_focused_workspace(workspace, previously_focused_workspace)
    logger.info("Updating focused workspace to " .. workspace)
    if workspace == previously_focused_workspace then
        logger.warning("Focused workspace unchanged, no action needed")
        return
    end
    if previously_focused_workspace ~= nil then
        logger.debug("Unfocusing workspace item " .. previously_focused_workspace)
        sbar.animate("tanh", 10, function()
            sbar.set(previously_focused_workspace, {
                icon = {
                    color = colors.apps_colors[previously_focused_workspace]
                },
                background = {
                    height = 10,
                }
            })
        end)
    end
    sbar.animate("tanh", 10, function()
        sbar.set(workspace, {
            icon = {
                color = workspace == "T" and colors.dark or colors.white
            },
            background = {
                height = 62
            }
        })
    end)
    return workspace
end

local function focus_active_workspace_item()
    return aerospace.query_focused_workspace()
        :next(function(workspace) return workspace.workspace end)
        :next(update_focused_workspace)
end

local function init_workspace_items()
    logger.startup("START - WORKSPACE_INIT - Initializing workspace items")

    return aerospace.query_all_workspaces()
        :next(function(all_workspaces)
            for _, workspace_object in pairs(all_workspaces) do
                add_workspace_item(workspace_object)
                logger.info("Added workspace " .. workspace_object.workspace)
            end
        end, handle_error)
        :next(focus_active_workspace_item)
        --:next(update_workspaces_padding)
        :next(function()
            logger.success("SUCCESS - WORKSPACE_INIT - Workspace items initialized")
        end, function(err)
            logger.error("ERROR - WOKSPACE_INIT - Failed to initialize workspace items: " .. err)
        end)
end

local function update_workspace_display(workspace_objects)
    for _, workspace_object in pairs(workspace_objects) do
        local workspace = workspace_object.workspace
        local existing_display_id = opened_workspaces[workspace]
        local new_display_id = bar_helper.get_display_id_for_sbar_item(workspace_object)
        if not new_display_id then
            logger.warning("Cannot determine new display ID for workspace " .. workspace)
            return nil
        end

        if existing_display_id ~= new_display_id then
            logger.success("Display ID changed from " ..
                tostring(existing_display_id) .. " to " .. tostring(new_display_id))

            logger.success("Setting workspace object display")
            sbar.set(workspace, {
                display = new_display_id
            })
            opened_workspaces[workspace] = new_display_id

            logger.success("Updating windows for workspace " .. workspace)
            for window_id, window in pairs(opened_windows) do
                if window["workspace"] == workspace then
                    logger.debug("Moving window " .. window_id .. " to display " .. new_display_id)
                    sbar.set(tostring(window_id), {
                        display = new_display_id
                    })
                end
            end

            logger.debug("Finished processing workspace " .. workspace)
        end
    end

    logger.debug("update_workspace_display completed")
end

local function remove_closed_windows(windows)
    for window_id, _ in pairs(opened_windows) do
        if windows[tostring(window_id)] == nil then
            delete_window_item(tostring(window_id))
        end
    end
    return windows
end

local function update_windows(windows)
    logger.info("Reload windows")
    remove_closed_windows(windows)
    for window_id, window in pairs(windows) do
        local perform_update = false
        local existing_window = opened_windows[tostring(window_id)]
        if not existing_window then
            add_window_item(window)
        elseif existing_window.workspace ~= window.workspace
            or existing_window["monitor-appkit-nsscreen-screens-id"] ~= window["monitor-appkit-nsscreen-screens-id"] then
            delete_window_item(tostring(window_id), function()
                add_window_item(window)
            end)
            perform_update = true
        end
        if (currently_focused_window_id == tostring(window_id)) then
            update_focused_window(window)
        end
        if perform_update then
            opened_windows[tostring(window_id)] = window
        end
    end
    --    compute_workspaces_window_count(windows)
    --    update_workspaces_padding()
    return windows
end

local function setup_observers()
    logger.startup("START - LISERNERS_INIT - Setting up event listeners")
    local space_window_observer = sbar.add("item", {
        drawing = false,
        updates = true
    })

    space_window_observer:subscribe("aerospace_workspace_change",
        function(env)
            logger.startup("AEROSPACE_WORKSPACE_CHANGE")
            local new_focused_workspace = update_focused_workspace(env.FOCUSED, env.PREVIOUSLY_FOCUSED)
            logger.success("AEROSPACE_WORKSPACE_CHANGE - Focused workspace is now " .. (new_focused_workspace or "nil"))
        end)

    space_window_observer:subscribe("aerospace_focus_change",
        function(env)
            logger.startup("AEROSPACE_FOCUS_CHANGE")
            logger.success(inspect(env))
            return aerospace.query_all_windows()
                :next(update_windows)
                --   :next(focus_active_window)
                --  :next(update_workspaces_padding)
                :next(function()
                    logger.success("AEROSPACE_FOCUS_CHANGE - Focus change handling completed")
                end, handle_error)
            --[[
            return sync_workspace_windows(currently_focused_workspace)
                :next(focus_active_window_item)
                :next(function()
                    return sync_workspace_windows(currently_focused_workspace)
                end)
                :next(function() logger.success("AEROSPACE_FOCUS_CHANGE - Focus change handling completed") end,
                    handle_error) ]]
        end)


    space_window_observer:subscribe("workspace_changed_monitor",
        function()
            logger.startup("WORKSPACE_CHANGED_MONITOR")
            return aerospace.query_all_workspaces()
                :next(update_workspace_display, handle_error)
                --   :next(update_workspaces_padding)
                :next(function(workspace)
                    logger.success("WORKSPACE_CHANGED_MONITOR - Monitor change handling completed \
         Workspace " .. workspace .. " moved to " .. (opened_workspaces[workspace] or "unknown monitor"))
                end)
        end)

    logger.success("SUCCESS - LISERNERS_INIT - Event listeners set up")
end

local function run()
    logger.startup("Starting spaces and windows items configuration")
    return init_workspace_items()
        :next(init_window_items)
        --  :next(update_workspaces_padding)
        :next(setup_observers, handle_error)
end

return run()
