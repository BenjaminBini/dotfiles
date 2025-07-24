local settings = require("settings")
local app_icons = require("helpers.app_icons")
local sbar = require("sketchybar")
local colors = require("colors")
local aerospace = require("helpers.aerospace")

local ANIMATION_DURATION = 10
local ACTIVE_WORKSPACE_BG_HEIGHT = 62
local INACTIVE_WORKSPACE_BG_HEIGHT = 8
local WORKSPACE_BG_Y_OFFSET = 18

sbar.add("event", "monitor_change")

local function find_display_by_appkit_id(appkit_id)
    local sbar_displays = sbar.query("displays")
    for _, display in pairs(sbar_displays) do
        if display["DirectDisplayID"] == appkit_id then
            return sbar_displays[display["arrangement-id"]]
        end
    end
    return nil
end
-- Global state

All_spaces = {}


local function setCurrentWorkspace(workspace_id)
    for _, barSpace in pairs(All_spaces) do
        if barSpace.name == workspace_id then
            sbar:animate("tanh", ANIMATION_DURATION, function()
                barSpace:set({ background = { height = ACTIVE_WORKSPACE_BG_HEIGHT } })
            end)
        else
            sbar:animate("tanh", ANIMATION_DURATION, function()
                barSpace:set({ background = { height = INACTIVE_WORKSPACE_BG_HEIGHT } })
            end)
        end
    end
end

local function update_workspace_icons(barSpace)
    local current_icons = barSpace:query("label.string") or ""
    aerospace.query_workspace_windows(barSpace.name, function(workspace_windows)
        local icon_line = ""

        for _, window in pairs(workspace_windows) do
            local window_app_icon = app_icons[window["app-name"]] or app_icons["default"]
            icon_line = icon_line .. " " .. window_app_icon
        end
        if icon_line == current_icons then
            return
        end

        barSpace:set({
            label = { string = icon_line },
        })
        sbar:animate("tanh", ANIMATION_DURATION, function()
            -- Update the icon line in the label
            barSpace:set({
                label = {
                    width = #workspace_windows * 30, -- Adjust width based on icon length
                }
            })
        end)
    end)
end

local function update_all_workspace_icons()
    for _, bar_space in pairs(All_spaces) do
        update_workspace_icons(bar_space)
    end
end

local function update_all_workspaces_display()
    aerospace.query_all_workspaces(function(workspaces)
        for _, workspace in pairs(workspaces) do
            local bar_space = All_spaces[workspace.workspace]
            if bar_space then
                local sbar_display = find_display_by_appkit_id(workspace["monitor-appkit-nsscreen-screens-id"])
                if sbar_display then
                    bar_space:set({ display = sbar_display["arrangement-id"] })
                end
            end
        end
    end)
end


aerospace.query_all_workspaces(function(workspaces)
    for _, workspace in pairs(workspaces) do
        local sbar_display = find_display_by_appkit_id(workspace["monitor-appkit-nsscreen-screens-id"])
        local display_id = sbar_display and sbar_display["arrangement-id"] or 1
        local workspace_color = colors.apps_colors[workspace.workspace] or colors.default
        local bar_space = sbar.add("space", workspace.workspace, {
            display = display_id,
            click_script = "/opt/homebrew/bin/aerospace workspace " .. workspace.workspace,
            name = workspace.workspace,
            icon = {
                string = workspace.workspace,
                font = {
                    family = settings.font.numbers,
                    size = 14
                },
                padding_left = 8,
                padding_right = 8,
            },
            background = {
                color = workspace_color,
                height = INACTIVE_WORKSPACE_BG_HEIGHT,
                y_offset = WORKSPACE_BG_Y_OFFSET,
                border_width = 0,

            },
            label = {
                width = 0,
                string = "",
                font = settings.icons,
                padding_left = 3,
                padding_right = 0,
                y_offset = -1,
            }

        })
        All_spaces[workspace.workspace] = bar_space
        update_workspace_icons(bar_space)
        if (workspace["workspace-is-focused"]) then
            setCurrentWorkspace(workspace.workspace)
        end
    end
end)


local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
})


space_window_observer:subscribe("window_change", update_all_workspace_icons)

space_window_observer:subscribe("monitor_change", function()
    update_all_workspaces_display()
end)

space_window_observer:subscribe("space_windows_change", function(env)
    update_all_workspaces_display()
    update_all_workspace_icons()
end)

space_window_observer:subscribe("demo", function()
    update_all_workspace_icons()
    update_all_workspaces_display()
end)

space_window_observer:subscribe("aerospace_workspace_change", function(env)
    local previousBarSpace = All_spaces[env.PREVIOUSLY_FOCUSED]
    local newBarSpace = All_spaces[env.FOCUSED]
    if not previousBarSpace or not newBarSpace then
        return
    end
    -- Update the current workspace and bar space
    update_workspace_icons(newBarSpace)
    update_workspace_icons(previousBarSpace)
    setCurrentWorkspace(newBarSpace.name)
end)



sbar.subscribe("space_change", function(env)
    print("Space changed")
    print(env.INFO)
end)

space_window_observer:subscribe("space_change", function(env)
    print("Space changed")
    print(env.INFO)
end)
