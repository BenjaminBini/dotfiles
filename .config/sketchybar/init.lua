-- Require the sketchybar module
sbar = require("sketchybar")

-- Debug mode - use print statements for debugging
print("=== SketchyBar Debug Mode ===")
print("Starting initialization...")

require("LuaPanda").start("127.0.0.1", 8818);

-- Uncomment for EmmyLua debugging when working:
-- package.cpath = package.cpath .. ";/Users/benjaminbini/.vscode/extensions/tangzx.emmylua-0.9.24-darwin-arm64/debugger/emmy/mac/arm64/emmy_core.dylib"
-- local dbg = require("emmys_core")
-- dbg.tcpListen("localhost", 9966)
-- dbg.waitIDE()

-- Set the bar name, if you are using another bar instance than sketchybar
-- sbar.set_bar_name("bottom_bar")

-- Bundle the entire initial configuration into a single message to sketchybar
print("Loading configuration modules...")
sbar.begin_config()

print("Loading bar configuration...")
require("bar")

print("Loading default settings...")
require("default")

print("Loading items...")
require("items")

print("Configuration complete!")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
print("Starting event loop...")
sbar.event_loop()
