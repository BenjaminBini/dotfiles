-- Simple call stack visualizer trigger
-- Usage: Just require this file and call stack_viz() anywhere in your code

local enhanced_profile = require("enhanced_profile")

-- Global function to trigger call stack visualization
function stack_viz()
    enhanced_profile.generate_callstack()
    print("📊 Call stack visualization generated and opened in browser!")
end

-- Alternative shorter name
function cs()
    stack_viz()
end

-- Export the function
return {
    stack_viz = stack_viz,
    cs = cs,
    generate = enhanced_profile.generate_callstack
}