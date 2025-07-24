-- aàc  
-- stackline = require("stackline")
-- stackline:init()
--    

local hyper = require('hyper')
local hyper = {"rctrl"}

-- ======================================= Switcher
    --  // Window switcher
   -- local switcher  = require('switcher')   
    -- Alt-B is bound to the switcher dialog for all apps.
    -- Alt-shift-B is bound to the switcher dialog for the current app.
    
    -- Hyper + "app key" launches/switches to the window of the app or cycles through its open windows if already focused
      -- switcherfunc() cycles through all widows of the frontmost app.
    -- Hyper + tab cycles to the previously focused app.
    
    --  function to either open apps or switch through them using switcher
    function openswitch(name)
        return function()
            if hs.application.frontmostApplication():name() == name then
              switcherfunc()
            else
              hs.application.launchOrFocus(name)
            end
        end
    end
    
  -- hs.hotkey.bind({"rctrl"}, "x", openswitch("Finder"))
    --hs.hotkey.bind({"rctrl"}, "f", openswitch("Firefox Nightly"))
    --hs.hotkey.bind({"rctrl"}, "z", openswitch("Visual Studio Code"))
    
    
-- ======================================= Load Spoons and .lua files

require("rcmd")
