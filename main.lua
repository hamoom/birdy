---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

-- require the composer library
local composer = require("composer")


-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)


-- Add any system wide event handlers, location, key events, system resume/suspend, memory, etc.

-- load scene1
composer.gotoScene("scene1")
