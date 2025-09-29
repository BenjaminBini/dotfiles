--[[
Enhanced Logger for SketchyBar
Provides color-coded logging functionality completely separate from profiling.
]] --- Enhanced logger module with color coding
-- @module logger
local logger = {}

-- Load settings
local settings = require("settings")
local config = settings.logger

-- ANSI Color codes for different log types
local colors = {
    -- Standard logs (subtle)
    STANDARD = "\27[37m",      -- Light gray
    CONFIG = "\27[36m",        -- Cyan
    STARTUP = "\27[38;5;214m", -- Orange
    -- System logs
    ERROR = "\27[91m",         -- Bright red
    WARNING = "\27[93m",       -- Bright yellow
    SUCCESS = "\27[32m",       -- Green
    INFO = "\27[94m",          -- Blue
    DEBUG = "\27[90m",         -- Dark gray
    TRACE = "\27[2m\27[90m",   -- Dim dark gray

    -- Special
    RESET = "\27[0m", -- Reset color
    BOLD = "\27[1m",  -- Bold
    DIM = "\27[2m"    -- Dim
}

-- Color helper functions
local function colorize(color, text, bold)
    if os.getenv("NO_COLOR") == "1" then
        return text
    end
    local prefix = bold and (colors.BOLD .. color) or color
    return prefix .. text .. colors.RESET
end

-- Check if debug mode is enabled
local function is_debug_enabled()
    local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
    return debug_mode ~= "0" and debug_mode ~= "false"
end

-- Get detailed call site information
local function get_call_site_info(trace_levels, show_all_levels)
    trace_levels = trace_levels or 0
    show_all_levels = show_all_levels or false

    if not show_all_levels then
        -- Original behavior - just get the nth level
        local info = debug.getinfo(4 + trace_levels, "Snl")
        local result = {
            filename = "unknown",
            line = 0,
            method = "unknown"
        }

        if info then
            -- Extract filename with extension
            if info.source then
                local source = info.source
                if source:sub(1, 1) == "@" then
                    source = source:sub(2) -- Remove @ prefix
                end

                -- Handle different source types
                if source:match("^=%(.+%)$") then
                    result.filename = source:match("^=%((.+)%)$") -- Extract content from =(...)
                else
                    -- Keep full filename with extension
                    local filename = source:match("/([^/]+)$") or source:match("([^/]+)$") or source
                    result.filename = filename
                end
            end

            -- Get line number
            result.line = info.currentline or 0

            -- Get method/function name
            if info.name then
                result.method = info.name
            elseif info.what == "main" then
                result.method = "main"
            elseif info.what == "C" then
                result.method = "C"
            else
                result.method = "anonymous"
            end
        end

        return result
    else
        -- New behavior - concatenate all levels from 4 to 4+trace_levels
        local call_chain = {}
        local primary_result = {
            filename = "unknown",
            line = 0,
            method = "unknown"
        }

        for level = 4, 4 + trace_levels do
            local info = debug.getinfo(level, "Snl")
            if not info then
                break
            end

            local filename = "unknown"
            local method_name = "unknown"
            local line_num = info.currentline or 0

            -- Extract filename
            if info.source then
                local source = info.source
                if source:sub(1, 1) == "@" then
                    source = source:sub(2) -- Remove @ prefix
                end

                if source:match("^=%(.+%)$") then
                    filename = source:match("^=%((.+)%)$") -- Extract content from =(...)
                else
                    local fn = source:match("/([^/]+)$") or source:match("([^/]+)$") or source
                    filename = fn
                end
            end

            -- Get method name
            if info.name then
                method_name = info.name
            elseif info.what == "main" then
                method_name = "main"
            elseif info.what == "C" then
                method_name = "C"
            else
                method_name = "anonymous"
            end

            -- Store the first (closest) call info as primary
            if level == 4 then
                primary_result.filename = filename
                primary_result.line = line_num
                primary_result.method = method_name
            end

            -- Skip repetitive framework calls but keep important ones
            local is_framework_noise = (filename == "deferred.lua" and
                    (method_name == "pcall" or
                        method_name == "nonpromisecb" or
                        method_name == "promise" or
                        method_name == "fire" or
                        method_name == "finish")) or
                (filename == "=[C]" and method_name == "pcall")

            -- Always include spaces.lua calls and non-repetitive calls
            local should_include = filename == "spaces.lua" or
                not is_framework_noise or
                level == 4 or   -- Always include first level
                #call_chain < 3 -- Include first few levels for context

            if should_include then
                -- Add full location info to call chain
                local location_info = string.format("[%s:%d@%s]", filename, line_num, method_name)
                table.insert(call_chain, location_info)
            end
        end

        -- Format call chain with line breaks for readability
        if #call_chain > 1 then
            local formatted_chain = {}
            for i, location in ipairs(call_chain) do
                if i == 1 then
                    -- First line (current call) - just the method name for consistency with single-line format
                    table.insert(formatted_chain, primary_result.method)
                else
                    -- Subsequent lines with indentation and arrow, showing full location
                    table.insert(formatted_chain, "  " .. string.rep("  ", i - 2) .. "└─ " .. location)
                end
            end
            primary_result.method = table.concat(formatted_chain, "\n")
        else
            primary_result.method = primary_result.method or "unknown"
        end

        return primary_result
    end
end

-- Base logging function
local function log_message(level, message, color_func, icon, trace_levels, show_all_levels)
    if is_debug_enabled() then
        local call_info = get_call_site_info(trace_levels, show_all_levels)

        -- Get current timestamp with milliseconds
        local time = os.time()
        local ms = math.floor((os.clock() * 1000) % 1000)
        local timestamp = os.date("[%H:%M:%S", time) .. string.format(".%03d]", ms)

        -- Handle method name - extract call stack if multiline
        local method_name = call_info.method
        local call_stack = ""
        local is_multiline = string.find(method_name, "\n") ~= nil

        if is_multiline then
            -- Split method name into first line and call stack
            local lines = {}
            for line in method_name:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            method_name = lines[1] or "unknown"

            -- Build call stack with proper padding
            if #lines > 1 then
                local stack_lines = {}
                for i = 2, #lines do
                    -- Add timestamp padding to align with main message
                    local padding = string.rep(" ", string.len(timestamp) + 1)
                    table.insert(stack_lines, padding .. lines[i])
                end
                call_stack = "\n" .. table.concat(stack_lines, "\n")
            end
        end

        if string.len(method_name) > 25 then
            method_name = string.sub(method_name, 1, 22) .. "..."
        end

        local location_info = string.format("[%s:%d@%s]", call_info.filename, call_info.line, method_name)

        -- Pad location info to consistent width
        local padded_location = string.format("%-" .. config.location_width .. "s", location_info)

        local prefixed_message = timestamp .. " " .. padded_location .. " " .. message
        local colored_entry = color_func and color_func(prefixed_message) or prefixed_message
        local colored_call_stack = color_func and color_func(call_stack) or call_stack
        print(icon .. " " .. colored_entry .. colored_call_stack)
    end
end

--- Public logging methods with automatic coloring and distinct icons
logger.standard = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.STANDARD, text)
    end, "➡️", trace_levels, show_all_levels)
end

logger.config = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.CONFIG, text)
    end, "⚙️", trace_levels, show_all_levels)
end

logger.startup = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.STARTUP, text, true)
    end, "🚀", trace_levels, show_all_levels)
end

logger.success = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.SUCCESS, text, true)
    end, "✅", trace_levels, show_all_levels)
end

logger.error = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.ERROR, text, true)
    end, "❌", trace_levels, show_all_levels)
end

logger.warning = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.WARNING, text)
    end, "⚠️", trace_levels, show_all_levels)
end

logger.info = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.INFO, text)
    end, "ℹ️", trace_levels, show_all_levels)
end

logger.debug = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.DEBUG, text)
    end, "🐛", trace_levels, show_all_levels)
end

logger.dim = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.DIM, text)
    end, "💭", trace_levels, show_all_levels)
end

logger.trace = function(message, trace_levels, show_all_levels)
    log_message(nil, message, function(text)
        return colorize(colors.TRACE, text)
    end, "🔍", trace_levels, show_all_levels)
end

-- Get full stack trace
local function get_stack_trace(skip_levels)
    skip_levels = skip_levels or 0
    local stack = {}
    local level = 2 + skip_levels -- Skip this function and the calling function

    while true do
        local info = debug.getinfo(level, "Snl")
        if not info then
            break
        end

        local source = info.source or "unknown"
        if source:sub(1, 1) == "@" then
            source = source:sub(2) -- Remove @ prefix
        end

        local filename = source:match("/([^/]+)$") or source:match("([^/]+)$") or source
        local line = info.currentline or 0
        local name = info.name or (info.what == "main" and "main" or "anonymous")

        table.insert(stack, string.format("  %d. %s:%d in %s()", level - 1, filename, line, name))
        level = level + 1

        -- Limit stack depth to prevent spam
        if level > 20 then
            break
        end
    end

    return table.concat(stack, "\n")
end

-- Log error with full stack trace
logger.error_with_stack = function(message)
    if is_debug_enabled() then
        local stack_trace = get_stack_trace(1)
        log_message(nil, message .. "\nStack trace:\n" .. stack_trace, function(text)
            return colorize(colors.ERROR, text, true)
        end, "💥")
    end
end

-- Color helper functions for direct use
logger.colors = {
    standard = function(text)
        return colorize(colors.STANDARD, text)
    end,
    config = function(text)
        return colorize(colors.CONFIG, text)
    end,
    startup = function(text)
        return colorize(colors.STARTUP, text, true)
    end,
    success = function(text)
        return colorize(colors.SUCCESS, text, true)
    end,
    error = function(text)
        return colorize(colors.ERROR, text, true)
    end,
    warning = function(text)
        return colorize(colors.WARNING, text)
    end,
    info = function(text)
        return colorize(colors.INFO, text)
    end,
    debug = function(text)
        return colorize(colors.DEBUG, text)
    end,
    dim = function(text)
        return colorize(colors.DIM, text)
    end,
    trace = function(text)
        return colorize(colors.TRACE, text)
    end
}

return logger
