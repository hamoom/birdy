
local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")
physics.start()
---------------------------------------------------------------------------------

local screenTouched
local update

local rect
local touchDirection
local maxX = 180
local accelX = 5
local platformGroup = display.newGroup()
local platforms = {}

function update() 
    local vx, vy = rect:getLinearVelocity()

    local newVx, newVy = 0,0
    if touchDirection == "left" then 
        newVx = vx - accelX
        newVy = vy - 10
    elseif touchDirection == "right" then
        newVx = vx + accelX
        newVy = vy - 10
    end    

    if newVx < -maxX then
        newVx = -maxX
    end

    if newVx > maxX then
        newVx = maxX
    end    

    if newVy < -100 then
        newVy = -100
    end

    if touchDirection then
        rect:setLinearVelocity(newVx, newVy)
    end

    if rect.x > display.contentWidth then rect.x = 0 end
    if rect.x < 0 then rect.x = display.contentWidth end

    platformGroup.y = platformGroup.y - 1

    if platformGroup.y <= -display.contentHeight then platformGroup.y = display.contentHeight end
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

    platformGroup.y = display.contentHeight
    for i=1, 3, 1 do 
        platforms[#platforms+1] = display.newRect(platformGroup, 100, (i/3)*display.contentHeight, 50, 10)
    end 

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
