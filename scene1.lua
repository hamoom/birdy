
local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")
physics.start()
---------------------------------------------------------------------------------

local screenTouched
local update

local rect
local touchDirection


function update() 
    local vx, vy = rect:getLinearVelocity()

    local newVx, newVy = 0,0
    if touchDirection == "left" then 
        newVx = vx - 10
        newVy = vy - 10
    elseif touchDirection == "right" then
        newVx = vx + 10
        newVy = vy - 10
    end    

    if newVx < -100 then
        newVx = -100
    end

    if newVx > 100 then
        newVx = 100
    end    

    if touchDirection then
        rect:setLinearVelocity(newVx, newVy)
    end
end

function screenTouched(event)
    if event.phase == "began" or event.phase == "moved" then
        touchDirection = (event.x < display.contentCenterX) and "left" or "right"
    elseif event.phase == "ended" then
        touchDirection = nil
    end
end

function scene:create(event)
    local sceneGroup = self.view

    rect = display.newRect(
        sceneGroup, 
        display.contentCenterX, 
        display.contentCenterY, 
        20, 
        20
    )
    rect:setFillColor(1,0,0)
    physics.addBody(rect, "dynamic", {
   
    })

    local floor = display.newRect(
        sceneGroup, 
        display.contentCenterX, 
        display.contentHeight-1, 
        display.contentWidth, 
        1
    )

    physics.addBody(floor, "static", {
        bounce = 0.0    
    })

end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        Runtime:addEventListener("enterFrame", update)
    elseif phase == "did" then

    end 
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then

    elseif phase == "did" then

    end 
end


function scene:destroy(event)
    local sceneGroup = self.view


    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("touch", screenTouched)

---------------------------------------------------------------------------------

return scene
