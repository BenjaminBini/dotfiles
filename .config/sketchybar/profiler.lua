--[[
Pure Profiler for SketchyBar
Performance measurement functionality completely separate from logging.
]]

local base_profile = require("profile")

--- Pure profiler module (no logging)
-- @module profiler
local profiler = {}

-- Import base profiler functions
for k, v in pairs(base_profile) do
    profiler[k] = v
end

-- Global state tracking
local _startup_time = os.clock()
local _global_start_time = _startup_time
local _phase_timers = {}
local _async_operations = {}
local _event_timers = {}
local _total_events = 0
local _log_file = nil

-- Performance metrics
local _metrics = {
    startup_duration = 0,
    total_runtime = 0,
    event_count = 0,
    async_count = 0,
    avg_event_time = 0,
    peak_event_time = 0
}

--- Initialize logging
local function init_logging()
    local log_dir = "/Users/" .. os.getenv("USER") .. "/.config/sketchybar/logs"
    os.execute("mkdir -p " .. log_dir)
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local log_path = log_dir .. "/profile_" .. timestamp .. ".log"
    
    _log_file = io.open(log_path, "w")
    if _log_file then
        _log_file:write("=== SketchyBar Pure Profiler Log ===\n")
        _log_file:write("Started at: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
        _log_file:write("PID: " .. tostring(os.getenv("SKETCHYBAR_PID") or "unknown") .. "\n\n")
        _log_file:flush()
    end
end

--- Log performance data to file only (no console output)
local function log_performance_data(level, message)
    local timestamp = string.format("%.3f", os.clock() - _global_start_time)
    local log_entry = string.format("[%s] %s: %s\n", timestamp, level, message)
    
    if _log_file then
        _log_file:write(log_entry)
        _log_file:flush()
    end
end

--- Start a named phase timer
function profiler.start_phase(phase_name)
    _phase_timers[phase_name] = {
        start_time = os.clock(),
        operations = 0
    }
    log_performance_data("PHASE", "Starting " .. phase_name)
end

--- End a named phase timer
function profiler.end_phase(phase_name)
    local timer = _phase_timers[phase_name]
    if timer then
        timer.duration = os.clock() - timer.start_time
        log_performance_data("PHASE", string.format("Completed %s in %.3fms (%d operations)", 
            phase_name, timer.duration * 1000, timer.operations))
        return timer.duration
    end
    return 0
end

--- Track async operation
function profiler.track_async(operation_name, callback)
    local async_id = operation_name .. "_" .. tostring(os.clock())
    local start_time = os.clock()
    
    _async_operations[async_id] = {
        name = operation_name,
        start_time = start_time,
        status = "pending"
    }
    
    log_performance_data("ASYNC", "Started " .. operation_name)
    
    return function(...)
        local duration = os.clock() - start_time
        _async_operations[async_id].status = "completed"
        _async_operations[async_id].duration = duration
        
        _metrics.async_count = _metrics.async_count + 1
        
        log_performance_data("ASYNC", string.format("Completed %s in %.3fms", 
            operation_name, duration * 1000))
        
        if callback then
            return callback(...)
        end
    end
end

--- Start event timing
function profiler.start_event(event_name)
    local event_id = event_name .. "_" .. tostring(os.clock())
    _event_timers[event_id] = {
        name = event_name,
        start_time = os.clock()
    }
    return event_id
end

--- End event timing
function profiler.end_event(event_id)
    local timer = _event_timers[event_id]
    if timer then
        local duration = os.clock() - timer.start_time
        timer.duration = duration
        
        _total_events = _total_events + 1
        _metrics.event_count = _total_events
        
        -- Update metrics
        local total_time = (_metrics.avg_event_time * (_total_events - 1)) + duration
        _metrics.avg_event_time = total_time / _total_events
        
        if duration > _metrics.peak_event_time then
            _metrics.peak_event_time = duration
        end
        
        log_performance_data("EVENT", string.format("%s completed in %.3fms", 
            timer.name, duration * 1000))
        
        return duration
    end
    return 0
end

--- Mark startup completion
function profiler.startup_complete()
    _metrics.startup_duration = os.clock() - _startup_time
    log_performance_data("STARTUP", string.format("Startup completed in %.3fms", 
        _metrics.startup_duration * 1000))
end

--- Generate comprehensive performance report
function profiler.comprehensive_report(limit)
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

--- Increment phase operation counter
function profiler.phase_operation(phase_name)
    if _phase_timers[phase_name] then
        _phase_timers[phase_name].operations = _phase_timers[phase_name].operations + 1
    end
end

--- Initialize profiler
function profiler.init()
    init_logging()
    log_performance_data("INIT", "Pure profiler initialized")
end

--- Finalize and generate final report
function profiler.finalize_and_exit()
    log_performance_data("SHUTDOWN", "Finalizing profiler and generating report")
    
    -- Generate final report
    local final_report = profiler.comprehensive_report(15)
    
    if _log_file then
        _log_file:write("\n" .. final_report .. "\n")
        _log_file:write("\n=== SESSION END ===\n")
        _log_file:write("Ended at: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
        _log_file:close()
    end
end

-- Auto-initialize if not already done
if not _log_file then
    profiler.init()
end

return profiler