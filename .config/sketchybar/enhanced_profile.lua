--[[
Enhanced Profiler for SketchyBar
Extends the basic profile.lua with startup tracking, async operations, 
global runtime profiling, exit logging, and color-coded output.
]]

local base_profile = require("profile")
local sbar = require("sketchybar")

--- Enhanced profiler module with color coding
-- @module enhanced_profile
local enhanced_profile = {}

-- ANSI Color codes for different log types
local colors = {
    -- Standard logs (subtle)
    STANDARD = "\27[37m",      -- Light gray
    CONFIG = "\27[36m",        -- Cyan
    STARTUP = "\27[32m",       -- Green
    
    -- Profiling logs (prominent)
    PROFILE = "\27[35m",       -- Magenta
    PHASE = "\27[33m",         -- Yellow
    ASYNC = "\27[34m",         -- Blue
    EVENT = "\27[96m",         -- Bright cyan
    METRICS = "\27[95m",       -- Bright magenta
    
    -- System logs
    ERROR = "\27[91m",         -- Bright red
    WARNING = "\27[93m",       -- Bright yellow
    SUCCESS = "\27[92m",       -- Bright green
    
    -- Special
    RESET = "\27[0m",          -- Reset color
    BOLD = "\27[1m",           -- Bold
    DIM = "\27[2m"             -- Dim
}

-- Color helper functions
local function colorize(color, text, bold)
    if os.getenv("NO_COLOR") == "1" then
        return text
    end
    local prefix = bold and (colors.BOLD .. color) or color
    return prefix .. text .. colors.RESET
end

-- Specific color functions for different log types
enhanced_profile.colors = {
    standard = function(text) return colorize(colors.STANDARD, text) end,
    config = function(text) return colorize(colors.CONFIG, text) end,
    startup = function(text) return colorize(colors.STARTUP, text, true) end,
    profile = function(text) return colorize(colors.PROFILE, text, true) end,
    phase = function(text) return colorize(colors.PHASE, text) end,
    async = function(text) return colorize(colors.ASYNC, text) end,
    event = function(text) return colorize(colors.EVENT, text) end,
    metrics = function(text) return colorize(colors.METRICS, text, true) end,
    error = function(text) return colorize(colors.ERROR, text, true) end,
    warning = function(text) return colorize(colors.WARNING, text) end,
    success = function(text) return colorize(colors.SUCCESS, text, true) end,
    dim = function(text) return colorize(colors.DIM, text) end
}

-- Import base profiler functions
for k, v in pairs(base_profile) do
    enhanced_profile[k] = v
end

-- Global state tracking
local _startup_time = os.clock()
local _global_start_time = _startup_time
local _phase_timers = {}
local _async_operations = {}
local _event_timers = {}
local _total_events = 0
local _log_file = nil

-- Event ID generation tracking
local _global_event_index = 0
local _event_type_counters = {
    PHASE = 0,
    EVENT = 0,
    ASYNC = 0
}

-- Function call tracking for hierarchy analysis
local _function_call_stack = {}
local _event_profiles = {}
local _call_stack_monitor = false
local _real_time_stack = {}

-- Performance metrics
local _metrics = {
    startup_duration = 0,
    total_runtime = 0,
    event_count = 0,
    async_count = 0,
    avg_event_time = 0,
    peak_event_time = 0
}

--- Generate a unique ID for profiled events
-- @param event_type string The type of event (PHASE, EVENT, ASYNC)
-- @return string The generated ID in format TYPEOFEVENT_INDEXOFEVENTOFTYPE_GLOBALINDEX
local function generate_event_id(event_type)
    _global_event_index = _global_event_index + 1
    _event_type_counters[event_type] = _event_type_counters[event_type] + 1
    return event_type .. "_" .. _event_type_counters[event_type] .. "_" .. _global_event_index
end

--- Capture profile data before event starts
local function capture_profile_before()
    return base_profile.query(100) -- Get current state
end

--- Calculate profile difference and create summary table
-- @param before_data table Profile data before event
-- @param event_id string The event ID  
-- @param event_name string The event name
-- @param duration number Duration in seconds
local function print_event_profile_summary(before_data, event_id, event_name, duration)
    local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
    if debug_mode == "0" or debug_mode == "false" then
        return
    end
    
    -- Get current profile state
    local after_data = base_profile.query(100)
    
    -- Create lookup for before data
    local before_lookup = {}
    if before_data then
        for _, row in ipairs(before_data) do
            local func_name = row[2]
            local func_def = row[5]
            local key = func_name .. "@" .. func_def
            before_lookup[key] = {
                calls = row[3],
                time = row[4]
            }
        end
    end
    
    -- Calculate differences and group anonymous functions
    local function_groups = {}
    for _, row in ipairs(after_data) do
        local func_name = row[2]
        local func_def = row[5]
        local key = func_name .. "@" .. func_def
        local current_calls = row[3]
        local current_time = row[4]
        
        -- Debug: Print what the profiler actually captured
        if func_def and (func_def:match("spaces%.lua") or func_def:match("aerospace%.lua")) then
            local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
            if debug_mode ~= "0" and debug_mode ~= "false" then
                print("🔍 PROFILER DEBUG: name='" .. tostring(func_name) .. "' def='" .. tostring(func_def) .. "' calls=" .. current_calls .. " time=" .. string.format("%.3f", current_time * 1000) .. "ms")
            end
        end
        
        local before = before_lookup[key] or {calls = 0, time = 0}
        local call_diff = current_calls - before.calls
        local time_diff = current_time - before.time
        
        if call_diff > 0 or time_diff > 0.001 then -- Only show functions that were actually called
            -- Filter to only include functions from space* and aerospace.lua files
            -- and exclude profiling infrastructure
            local should_include = false
            if func_def then
                local lowercase_def = func_def:lower()
                -- Include space and aerospace functions
                if lowercase_def:match("space") or lowercase_def:match("aerospace%.lua") then
                    should_include = true
                end
                
                -- Exclude profiling infrastructure functions
                if func_name == "profile_event" or 
                    lowercase_def:match("enhanced_profile%.lua") or
                    func_name:match("^enhanced_profile%.") then
                    should_include = false
                end
            end
            
            if should_include then
                -- For anonymous functions, use the unique key to distinguish different 
                -- anonymous functions, but group repeated calls to the same function
                local group_key = key -- This preserves function identity
                
                if function_groups[group_key] then
                    -- Add to existing group (same anonymous function called multiple times)
                    function_groups[group_key].calls = function_groups[group_key].calls + call_diff
                    function_groups[group_key].total_time = function_groups[group_key].total_time + time_diff
                else
                    -- Create new group - distinguish anonymous functions from same location
                    local display_name
                    
                    -- First, try to infer better names for unknown functions
                    if func_name == "?" and func_def then
                        local line_num = func_def:match(":(%d+)$")
                        if line_num then
                            line_num = tonumber(line_num)
                            if func_def:match("spaces%.lua") then
                                if line_num == 169 then
                                    func_name = "focus_window_item*"
                                elseif line_num == 193 then
                                    func_name = "focus_workspace_item*"
                                end
                            end
                        end
                    end
                    
                    if func_name and func_name:match("^anonymous") then
                        -- Count how many anonymous functions we've seen from this location
                        local location_count = 0
                        for existing_key, existing_group in pairs(function_groups) do
                            if existing_group.definition == func_def and existing_group.name:match("^anonymous") then
                                location_count = location_count + 1
                            end
                        end
                        
                        -- Extract just filename:line from definition
                        local short_location = "unknown"
                        if func_def then
                            local filename = func_def:match("([^/]+)$") or func_def
                            short_location = filename
                        end
                        
                        if location_count > 0 then
                            display_name = "anonymous (" .. short_location .. ") #" .. (location_count + 1)
                        else
                            display_name = "anonymous (" .. short_location .. ")"
                        end
                    elseif func_name == "func" or func_name == "" or func_name == "?" or not func_name then
                        -- Handle generic "func" names or missing names by adding location context
                        -- Try to make a better guess based on location
                        local short_location = "unknown"
                        local better_name = "func"
                        
                        if func_def then
                            local filename = func_def:match("([^/]+)$") or func_def
                            short_location = filename
                            
                            -- Try to infer better name from common patterns
                            local line_num = func_def:match(":(%d+)$")
                            if line_num then
                                line_num = tonumber(line_num)
                                -- Infer function names based on known patterns in spaces.lua
                                if filename:match("spaces%.lua") then
                                    if line_num == 169 then
                                        better_name = "focus_window_item*"  -- * indicates inferred
                                    elseif line_num and line_num >= 170 and line_num <= 183 then
                                        better_name = "focus_window_callback*"  -- callback inside focus_window_item
                                    elseif line_num == 193 then
                                        better_name = "focus_workspace_item*"
                                    elseif line_num and line_num >= 200 and line_num <= 210 then
                                        better_name = "focus_workspace_callback*"
                                    end
                                end
                            end
                        end
                        
                        display_name = better_name .. " (" .. short_location .. ")"
                    else
                        -- Use the (possibly inferred) function name
                        display_name = func_name
                    end
                    
                    function_groups[group_key] = {
                        name = display_name,
                        calls = call_diff,
                        total_time = time_diff,
                        definition = func_def or "unknown"
                    }
                end
            end
        end
    end
    
    -- Convert grouped data to array and calculate averages
    local diff_data = {}
    for _, group in pairs(function_groups) do
        group.avg_time = group.calls > 0 and (group.total_time / group.calls) or 0
        table.insert(diff_data, group)
    end
    
    -- Sort by total time descending
    table.sort(diff_data, function(a, b) return a.total_time > b.total_time end)
    
    -- Print summary header with overall metrics
    local summary_header = string.format(
        "\n📊 PROFILE SUMMARY [%s] %s (%.3fms)",
        event_id, event_name, duration * 1000
    )
    print(enhanced_profile.colors.metrics(summary_header))
    
    -- Calculate and show summary statistics
    local total_calls = 0
    local total_function_time = 0
    for _, func in ipairs(diff_data) do
        total_calls = total_calls + func.calls
        total_function_time = total_function_time + func.total_time
    end
    
    local summary_stats = string.format(
        "├─ Functions Called: %d  │  Total Function Calls: %d  │  Function Time: %.3fms (%.1f%%)",
        #diff_data, total_calls, total_function_time * 1000, 
        duration > 0 and (total_function_time / duration * 100) or 0
    )
    print(enhanced_profile.colors.dim(summary_stats))
    print(enhanced_profile.colors.dim("├─ Event Details:"))
    print(enhanced_profile.colors.dim(string.format("│  └─ Event Duration: %.3fms", duration * 1000)))
    print(enhanced_profile.colors.dim(string.format("│  └─ Overhead Time: %.3fms", (duration - total_function_time) * 1000)))
    
    if #diff_data > 0 then
        print(enhanced_profile.colors.dim("└─ Function Call Details:"))
        print("")
        
        -- Print detailed function table with better formatting
        print(enhanced_profile.colors.dim("┌─────┬────────────────────────────────────────┬───────┬──────────┬──────────┬─────────────────────────┐"))
        print(enhanced_profile.colors.dim("│ #   │ Function                               │ Calls │ Total(ms)│ Avg(ms)  │ Location                │"))
        print(enhanced_profile.colors.dim("├─────┼────────────────────────────────────────┼───────┼──────────┼──────────┼─────────────────────────┤"))
        
        -- Print top 10 functions
        for i = 1, math.min(10, #diff_data) do
            local func = diff_data[i]
            
            -- Smart truncation for function names - preserve important parts
            local display_name = func.name
            if #display_name > 38 then
                if display_name:match("^anonymous") then
                    -- For anonymous functions, keep the file part readable
                    local prefix = "anonymous ("
                    local suffix = display_name:match("%)(.*)$") or ""
                    local file_part = display_name:match("anonymous %((.-)%)")
                    if file_part then
                        -- Extract just filename from path
                        local filename = file_part:match("([^/]+)$") or file_part
                        display_name = prefix .. filename .. ")" .. suffix
                        if #display_name > 38 then
                            display_name = prefix .. filename:sub(1, 20) .. "...)" .. suffix
                        end
                    end
                else
                    display_name = display_name:sub(1, 35) .. "..."
                end
            end
            
            -- Smart truncation for location - show just filename:line
            local location = func.definition or "unknown"
            if #location > 23 then
                -- Extract filename:line from full path
                local filename = location:match("([^/]+)$") or location
                if #filename > 23 then
                    filename = filename:sub(1, 20) .. "..."
                end
                location = filename
            end
            
            local line = string.format("│ %-3d │ %-38s │ %-5d │ %8.3f │ %8.3f │ %-23s │",
                i,
                display_name,
                func.calls,
                func.total_time * 1000,
                func.avg_time * 1000,
                location
            )
            print(enhanced_profile.colors.dim(line))
        end
        
        print(enhanced_profile.colors.dim("└─────┴────────────────────────────────────────┴───────┴──────────┴──────────┴─────────────────────────┘"))
    else
        print(enhanced_profile.colors.dim("└─ No function calls detected during event"))
    end
    
    print("") -- Empty line for separation
end

--- Generate HTML call-stack visualization
local function generate_callstack_html()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local html_file = "/tmp/sketchybar_callstack_" .. timestamp .. ".html"
    
    -- Capture current call stack
    local stack_info = {}
    for i = 1, 20 do -- Capture up to 20 levels
        local info = debug.getinfo(i, "Snlf")
        if not info then break end
        
        if info.what == "Lua" and not info.source:match("enhanced_profile%.lua") then
            table.insert(stack_info, {
                level = i,
                name = info.name or "anonymous",
                source = info.short_src,
                line = info.currentline,
                defined_line = info.linedefined,
                func_type = info.what,
                upvalues = info.nups or 0
            })
        end
    end
    
    -- Get current profiler data
    local profile_data = base_profile.query(50)
    
    -- Generate HTML content
    local html_content = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SketchyBar Call Stack - ]] .. timestamp .. [[</title>
    <style>
        body { 
            font-family: 'Monaco', 'Menlo', 'Courier New', monospace; 
            background: #1a1a1a; 
            color: #e0e0e0; 
            margin: 0; 
            padding: 20px;
            font-size: 13px;
        }
        .header { 
            background: #2d2d2d; 
            padding: 15px; 
            border-radius: 8px; 
            margin-bottom: 20px;
            border-left: 4px solid #007acc;
        }
        .stack-container { 
            display: flex; 
            gap: 20px; 
            height: calc(100vh - 120px);
        }
        .call-stack, .profile-data { 
            flex: 1; 
            background: #252525; 
            border-radius: 8px; 
            padding: 15px;
            overflow-y: auto;
        }
        .stack-frame { 
            background: #333; 
            margin: 8px 0; 
            padding: 12px; 
            border-radius: 6px;
            border-left: 3px solid #007acc;
            transition: all 0.2s ease;
        }
        .stack-frame:hover { 
            background: #404040; 
            transform: translateX(5px);
        }
        .stack-level { 
            color: #4CAF50; 
            font-weight: bold; 
            font-size: 11px;
        }
        .func-name { 
            color: #61DAFB; 
            font-weight: bold; 
            font-size: 14px;
        }
        .file-info { 
            color: #FFA726; 
            font-size: 11px; 
            margin-top: 4px;
        }
        .line-info { 
            color: #9E9E9E; 
            font-size: 11px;
        }
        .profile-row { 
            display: flex; 
            padding: 8px 0; 
            border-bottom: 1px solid #404040;
            font-size: 11px;
        }
        .profile-row:nth-child(even) { 
            background: rgba(255,255,255,0.02);
        }
        .profile-col { 
            padding: 0 8px;
        }
        .profile-header { 
            background: #404040; 
            font-weight: bold; 
            color: #FFA726;
        }
        h2 { 
            color: #61DAFB; 
            margin-top: 0;
            font-size: 18px;
        }
        .timestamp { 
            color: #9E9E9E; 
            font-size: 12px;
        }
        .refresh-btn {
            background: #007acc;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-family: inherit;
            float: right;
        }
        .refresh-btn:hover { background: #005a9e; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 SketchyBar Call Stack Visualization</h1>
        <div class="timestamp">Generated: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[</div>
        <button class="refresh-btn" onclick="location.reload()">Refresh</button>
    </div>
    
    <div class="stack-container">
        <div class="call-stack">
            <h2>🔗 Call Stack (Live)</h2>
]]

    -- Add call stack frames
    for _, frame in ipairs(stack_info) do
        html_content = html_content .. [[
            <div class="stack-frame">
                <div class="stack-level">Level ]] .. frame.level .. [[</div>
                <div class="func-name">]] .. frame.name .. [[</div>
                <div class="file-info">]] .. frame.source .. [[</div>
                <div class="line-info">Current: line ]] .. (frame.line or "?") .. [[ | Defined: line ]] .. (frame.defined_line or "?") .. [[</div>
            </div>
]]
    end

    html_content = html_content .. [[
        </div>
        
        <div class="profile-data">
            <h2>⚡ Function Performance</h2>
            <div class="profile-row profile-header">
                <div class="profile-col" style="width:40px">#</div>
                <div class="profile-col" style="width:200px">Function</div>
                <div class="profile-col" style="width:60px">Calls</div>
                <div class="profile-col" style="width:80px">Time(ms)</div>
                <div class="profile-col" style="flex:1">Location</div>
            </div>
]]

    -- Add profile data
    for i, row in ipairs(profile_data) do
        if i <= 20 then -- Show top 20
            local rank, name, calls, time, location = row[1], row[2], row[3], row[4], row[5]
            html_content = html_content .. [[
            <div class="profile-row">
                <div class="profile-col" style="width:40px">]] .. rank .. [[</div>
                <div class="profile-col" style="width:200px">]] .. (name or "?") .. [[</div>
                <div class="profile-col" style="width:60px">]] .. calls .. [[</div>
                <div class="profile-col" style="width:80px">]] .. string.format("%.3f", (time or 0) * 1000) .. [[</div>
                <div class="profile-col" style="flex:1">]] .. (location or "unknown") .. [[</div>
            </div>
]]
        end
    end

    html_content = html_content .. [[
        </div>
    </div>
    
    <script>
        // Auto-refresh every 5 seconds if page is active
        let autoRefresh = true;
        
        document.addEventListener('keydown', function(e) {
            if (e.key === 'r' || e.key === 'R') {
                location.reload();
            }
            if (e.key === ' ') {
                autoRefresh = !autoRefresh;
                console.log('Auto-refresh:', autoRefresh);
            }
        });
        
        // Optional: Auto-refresh (commented out for now)
        // setInterval(() => {
        //     if (autoRefresh && document.visibilityState === 'visible') {
        //         location.reload();
        //     }
        // }, 5000);
        
        console.log('📊 SketchyBar Call Stack loaded');
        console.log('Press R to refresh, Space to toggle auto-refresh');
    </script>
</body>
</html>
]]

    -- Write HTML file
    local file = io.open(html_file, "w")
    if file then
        file:write(html_content)
        file:close()
        
        -- Open in default browser
        os.execute("open '" .. html_file .. "'")
        
        enhanced_profile.log.success("Call stack visualization generated: " .. html_file)
        return html_file
    else
        enhanced_profile.log.error("Failed to create HTML file: " .. html_file)
        return nil
    end
end

--- Initialize logging
local function init_logging()
    local log_dir = "/Users/" .. os.getenv("USER") .. "/.config/sketchybar/logs"
    os.execute("mkdir -p " .. log_dir)
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local log_path = log_dir .. "/profile_" .. timestamp .. ".log"
    
    _log_file = io.open(log_path, "w")
    if _log_file then
        _log_file:write("=== SketchyBar Enhanced Profiler Log ===\n")
        _log_file:write("Started at: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
        _log_file:write("PID: " .. tostring(os.getenv("SKETCHYBAR_PID") or "unknown") .. "\n\n")
        _log_file:flush()
    end
end

--- Base logging function
local function log_message(level, message, color_func)
    local timestamp = string.format("%.3f", os.clock() - _global_start_time)
    local log_entry = string.format("[%s] %s: %s", timestamp, level, message)
    
    -- Write plain text to log file
    if _log_file then
        _log_file:write(log_entry .. "\n")
        _log_file:flush()
    end
    
    -- Print with colors if debug mode (default on)
    local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
    if debug_mode ~= "0" and debug_mode ~= "false" then  -- Default to on unless explicitly disabled
        local colored_entry = color_func and color_func(log_entry) or log_entry
        print("🔍 " .. colored_entry)
    end
end

--- Specialized logging methods with automatic coloring
local function log_phase(message)
    log_message("PHASE", message, enhanced_profile.colors.phase)
end

local function log_async(message)
    log_message("ASYNC", message, enhanced_profile.colors.async)
end

local function log_event(message)
    log_message("EVENT", message, enhanced_profile.colors.event)
end

local function log_startup(message)
    log_message("STARTUP", message, enhanced_profile.colors.startup)
end

local function log_shutdown(message)
    log_message("SHUTDOWN", message, enhanced_profile.colors.warning)
end

local function log_init(message)
    log_message("INIT", message, enhanced_profile.colors.startup)
end

--- Public logging methods
enhanced_profile.log = {
    phase = log_phase,
    async = log_async,
    event = log_event,
    startup = log_startup,
    shutdown = log_shutdown,
    init = log_init,
    
    -- Additional convenience methods
    standard = function(message) 
        local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
        if debug_mode ~= "0" and debug_mode ~= "false" then
            print(enhanced_profile.colors.standard(message))
        end
    end,
    
    profile = function(message)
        local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
        if debug_mode ~= "0" and debug_mode ~= "false" then
            print(enhanced_profile.colors.profile(message))
        end
    end,
    
    metrics = function(message)
        local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
        if debug_mode ~= "0" and debug_mode ~= "false" then
            print(enhanced_profile.colors.metrics(message))
        end
    end,
    
    success = function(message)
        local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
        if debug_mode ~= "0" and debug_mode ~= "false" then
            print(enhanced_profile.colors.success(message))
        end
    end,
    
    error = function(message)
        local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
        if debug_mode ~= "0" and debug_mode ~= "false" then
            print(enhanced_profile.colors.error(message))
        end
    end
}

--- Start a named phase timer
function enhanced_profile.start_phase(phase_name)
    local phase_id = generate_event_id("PHASE")
    _phase_timers[phase_name] = {
        id = phase_id,
        start_time = os.clock(),
        operations = 0,
        profile_before = capture_profile_before()
    }
    log_phase("Starting " .. phase_name .. " [ID: " .. phase_id .. "]")
end

--- End a named phase timer
function enhanced_profile.end_phase(phase_name)
    local timer = _phase_timers[phase_name]
    if timer then
        timer.duration = os.clock() - timer.start_time
        log_phase(string.format("Completed %s in %.3fms (%d operations) [ID: %s]",
            phase_name, timer.duration * 1000, timer.operations, timer.id or "unknown"))
        
        -- Print profile summary
        print_event_profile_summary(timer.profile_before, timer.id or "unknown", phase_name, timer.duration)
        
        return timer.duration
    end
    return 0
end


--- Track async operation
function enhanced_profile.track_async(operation_name, callback)
    local event_id = generate_event_id("ASYNC")
    local async_id = operation_name .. "_" .. tostring(os.clock())
    local start_time = os.clock()
    local profile_before = capture_profile_before()
    
    _async_operations[async_id] = {
        id = event_id,
        name = operation_name,
        start_time = start_time,
        status = "pending"
    }
    
    log_async("Started " .. operation_name .. " [ID: " .. event_id .. "]")
    
    return function(...)
        local duration = os.clock() - start_time
        _async_operations[async_id].status = "completed"
        _async_operations[async_id].duration = duration
        
        _metrics.async_count = _metrics.async_count + 1
        
        log_async(string.format("Completed %s in %.3fms [ID: %s]", 
            operation_name, duration * 1000, event_id))
        
        -- Print profile summary
        print_event_profile_summary(profile_before, event_id, operation_name, duration)
        
        if callback then
            return callback(...)
        end
    end
end

--- Start event timing
function enhanced_profile.start_event(event_name)
    local unique_id = generate_event_id("EVENT")
    local event_id = event_name .. "_" .. tostring(os.clock())
    _event_timers[event_id] = {
        id = unique_id,
        name = event_name,
        start_time = os.clock(),
        profile_before = capture_profile_before()
    }
    log_event("Starting " .. event_name .. " [ID: " .. unique_id .. "]")
    return event_id
end

--- End event timing
function enhanced_profile.end_event(event_id)
    local timer = _event_timers[event_id]
    if timer then
        local duration = os.clock() - timer.start_time
        timer.duration = duration
        
        _total_events = _total_events + 1
        _metrics.event_count = _total_events
        
        -- Update metrics
        local total_time = (_metrics.avg_event_time * (_total_events - 1)) + duration
        _metrics.avg_event_time = math.floor(total_time / _total_events)
        
        if duration > _metrics.peak_event_time then
            _metrics.peak_event_time = duration
        end
        
        log_event(string.format("%s completed in %.3fms [ID: %s]", 
            timer.name, duration * 1000, timer.id or "unknown"))
        
        -- Print profile summary
        print_event_profile_summary(timer.profile_before, timer.id or "unknown", timer.name, duration)
        
        return duration
    end
    return 0
end

--- Mark startup completion
function enhanced_profile.startup_complete()
    _metrics.startup_duration = os.clock() - _startup_time
    log_startup(string.format("Startup completed in %.3fms", 
        _metrics.startup_duration * 1000))
end

--- Generate comprehensive performance report
function enhanced_profile.comprehensive_report(limit)
    local report = {}
    
    -- Basic profiling report
    table.insert(report, "=== FUNCTION PROFILING ===")
    table.insert(report, base_profile.report(limit or 10))
    
    -- Startup metrics
    table.insert(report, "\n=== STARTUP METRICS ===")
    table.insert(report, string.format("Startup Duration: %.3fms", 
        _metrics.startup_duration * 1000))
    
    -- Runtime metrics
    _metrics.total_runtime = os.clock() - _global_start_time
    table.insert(report, "\n=== RUNTIME METRICS ===")
    table.insert(report, string.format("Total Runtime: %.3fs", _metrics.total_runtime))
    table.insert(report, string.format("Total Events: %d", _metrics.event_count))
    table.insert(report, string.format("Average Event Time: %.3fms", 
        _metrics.avg_event_time * 1000))
    table.insert(report, string.format("Peak Event Time: %.3fms", 
        _metrics.peak_event_time * 1000))
    table.insert(report, string.format("Async Operations: %d", _metrics.async_count))
    
    -- Phase timing report
    table.insert(report, "\n=== PHASE TIMING ===")
    for phase_name, timer in pairs(_phase_timers) do
        if timer.duration then
            table.insert(report, string.format("%s: %.3fms (%d ops)", 
                phase_name, timer.duration * 1000, timer.operations))
        end
    end
    
    -- Active async operations
    local pending_async = {}
    for _, op in pairs(_async_operations) do
        if op.status == "pending" then
            table.insert(pending_async, op.name)
        end
    end
    
    if #pending_async > 0 then
        table.insert(report, "\n=== PENDING ASYNC OPERATIONS ===")
        for _, op_name in ipairs(pending_async) do
            table.insert(report, "• " .. op_name)
        end
    end
    
    return table.concat(report, "\n")
end

--- Log final performance report and cleanup
function enhanced_profile.finalize_and_exit()
    log_shutdown("Finalizing profiler and generating report")
    
    -- Generate final report
    local final_report = enhanced_profile.comprehensive_report(15)
    
    if _log_file then
        _log_file:write("\n" .. final_report .. "\n")
        _log_file:write("\n=== SESSION END ===\n")
        _log_file:write("Ended at: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
        _log_file:close()
    end
    
    -- Also print to console if debug mode
    local debug_mode = os.getenv("SKETCHYBAR_DEBUG")
    if debug_mode ~= "0" and debug_mode ~= "false" then
        enhanced_profile.log.success("\n🎯 FINAL PERFORMANCE REPORT:")
        enhanced_profile.log.metrics(final_report)
    end
    
    -- Attempt to register exit handler
    if sbar and sbar.exec then
        -- Create a cleanup script that will be called on exit
        local cleanup_script = [[
            echo "]] .. final_report:gsub('"', '\\"') .. [["
        ]]
        
        -- Note: This is a best effort - Lua doesn't have reliable exit handlers
        pcall(function()
            os.execute('echo "SketchyBar profiler session ended" >> /tmp/sketchybar_profile.log')
        end)
    end
end

--- Increment phase operation counter
function enhanced_profile.phase_operation(phase_name)
    if _phase_timers[phase_name] then
        _phase_timers[phase_name].operations = _phase_timers[phase_name].operations + 1
    end
end

--- Generate call stack visualization (public function)
function enhanced_profile.generate_callstack()
    return generate_callstack_html()
end

--- Enable/disable call stack monitoring
function enhanced_profile.set_callstack_monitoring(enabled)
    _call_stack_monitor = enabled
    if enabled then
        enhanced_profile.log.success("Call stack monitoring enabled - use enhanced_profile.generate_callstack() to capture")
    else
        enhanced_profile.log.standard("Call stack monitoring disabled")
    end
end

--- Initialize enhanced profiler
function enhanced_profile.init()
    init_logging()
    log_init("Enhanced profiler initialized")
    
    -- Start the base profiler to collect function call data
    base_profile.start()
    log_init("Base profiler started for function tracking")
    
    -- Set up signal handlers for cleanup (best effort)
    pcall(function()
        -- Try to set up cleanup on common termination signals
        os.execute([[
            trap 'echo "SketchyBar terminated, check profile logs"' TERM INT HUP
        ]])
    end)
end

-- Auto-initialize if not already done
if not _log_file then
    enhanced_profile.init()
end

return enhanced_profile