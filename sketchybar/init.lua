local logger = require("logger")

logger.info("Starting sketchybar configurations")

-- Add the sketchybar module to the package cpath (the module could be
-- installed into the default search path then this would not be needed)
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"
package.cpath = package.cpath ..
    ';/Users/benjaminbini/Library/Application Support/JetBrains/IntelliJIdea2025.2/plugins/IntelliJ-EmmyLua/debugger/emmy/mac/arm64/?.dylib'
--local dbg = require('emmy_core')
--dbg.tcpConnect('localhost', 9966)

-- Require the sketchybar module
sbar = require("sketchybar")

-- Bundle the entire initial configuration into a single message to sketchybar
-- This improves startup times drastically, try removing both the begin and end
-- config calls to see the difference -- yeah..
logger.info("Configuration started")
sbar.begin_config()

require("bar")
require("default")
require("items")
sbar.hotload(true)
sbar.end_config()
logger.info("Synchronous configuration done")

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
logger.success("Starting event loop...")
sbar.event_loop()
