
local composer = require("composer") 
local scene = composer.newScene()
local widget = require("widget")

local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
    elseif (phase == "did") then
    	composer.removeScene("scene1")
    end
end

function scene:create(event)
	local sceneGroup = self.view

	local function restart()
		composer.removeScene("retry")
		composer.gotoScene("scene1", {effect="fade", time=200})
	end
	
	local restartBtn = widget.newButton({label="Restart", fontSize=50, x=screenW/2, y=screenH/2, onPress=restart })
	sceneGroup:insert(restartBtn)
end


function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)


return scene