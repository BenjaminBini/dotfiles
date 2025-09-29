local sbar = require("sketchybar")
local deferred = require('deferred')
local logger = require("logger")
local bar_helper = require("helpers.spaces.bar")
local aerospace = {}


local output_format = {
    monitors   =    "%{monitor-id}%{monitor-appkit-nsscreen-screens-id}%{monitor-name}",
    workspaces =    "%{workspace}%{monitor-id}%{monitor-appkit-nsscreen-screens-id}%{workspace-is-focused}%{workspace-is-visible}",
    windows    =    "%{window-id}%{window-title}%{app-name}%{workspace}%{monitor-id}%{monitor-appkit-nsscreen-screens-id}",
    apps       =    "%{app-bundle-id}%{app-name}"
}

function aerospace.query(command_type, options)
    local cmd = "aerospace list-" .. command_type
    if (not options.count) then
        cmd = cmd .. " --json --format " .. output_format[command_type]
    else
        cmd = cmd .. " --count"
    end

    if options.focused then
        cmd = cmd .. " --focused"
    elseif options.all then
        cmd = cmd .. " --all"
    elseif options.monitor then
        cmd = cmd .. " --monitor " .. options.monitor
    elseif options.workspace then
        cmd = cmd .. " --workspace " .. options.workspace
    end

    logger.trace("Querrying  " .. command_type .. ": " .. cmd)

    local d = deferred.new()
    return bar_helper.exec(cmd)
end

local function change_response_index(index_key)
    return function(response)
        if (response == nil or type(response) ~= "table") then
            error("Invalid response format")
        end
        local result = {}
        for _, item in pairs(response) do
            if item[index_key] then
                result[tostring(item[index_key])] = item
            end
        end
        return deferred.new():resolve(result)
    end
end

function aerospace.query_all_windows()
    return aerospace.query("windows", {
        all = true
    }):next(change_response_index("window-id"))
end

function aerospace.query_focused_window()
    return aerospace.query("windows", {
        focused = true
    }):next(function(response)
        for _, window in pairs(response) do
            logger.trace("Focused window: " .. window["window-id"])
            return deferred.new():resolve(window)
        end
        return deferred.new():resolve(nil)
    end, function(error)
        logger.warning("No window is focused")
        return deferred.new():resolve(nil)
    end)
end


function aerospace.query_focused_workspace()
    logger.standard("Querying focused workspace")
    return aerospace.query("workspaces", {
            focused = true
        })
        :next(function(response)
            for _, workspace in pairs(response) do
                return deferred.new():resolve(workspace)
            end
            return deferred.new():reject("No focused workspace")
        end, function(error)
            logger.warning("Failed to query focused workspace: " .. error)
            return deferred.new():resolve(nil)
        end)
end

function aerospace.query_all_workspaces()
    logger.debug("Querying all workspaces")
    return aerospace.query("workspaces", {
            all = true
        })
        :next(change_response_index("workspace"))
end

return aerospace
