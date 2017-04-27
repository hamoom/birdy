
local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")

physics.start()
---------------------------------------------------------------------------------

local screenTouched
local update
local getDeltaTime
local onCollision
local gameOver

local lastUpdate = 0
local dt = 0

local death = false
local score = 0
local scoreText
local rect

local leftId
local rightId
local touchDirection
local maxX = 180
local maxUp = -350
local accelX = 7

local platformSpeed = 2.5
local platformSpeedMax = 8
local platformTimer = 0
local platformTimerMax = 1
local platformGroup = display.newGroup()
local platforms = {}

function getDeltaTime()
    if lastUpdate == 0 then
        dt = 0
    else
        dt = (system.getTimer() - lastUpdate) / 1000
    end
    lastUpdate = system.getTimer()

    if dt > 0.02 then
        dt = 0.02
    end
end

function update() 
    getDeltaTime()

    local vx, vy = rect:getLinearVelocity()

    local newVx, newVy = 0,0


    if touchDirection == "left" and leftId then 
        newVx = vx - accelX
        newVy = vy - 50
    elseif touchDirection == "right" and rightId then
        newVx = vx + accelX
        newVy = vy - 50
    end    

    if newVx < -maxX then
        newVx = -maxX
    end

    if newVx > maxX then
        newVx = maxX
    end    

    if newVy < maxUp then
        newVy = maxUp
    end

    if touchDirection then
        rect:setLinearVelocity(newVx, newVy)
    end

    if rect.x > display.contentWidth then 
        rect.x = 0 
    end

    if rect.x < 0 then 
        rect.x = display.contentWidth
    end

    if rect.y >= (display.contentHeight + rect.height) then
        gameOver()
    end

    platformTimer = platformTimer - dt

    if platformTimer <= 0 then
        platformTimer = platformTimerMax

        local platform = platforms[#platforms]
        platform.isVisible = true
        platforms[#platforms] = nil
        table.insert(platforms, 1, platform)
        platform.x = math.random(platform.width/2, display.contentWidth-(platform.width/2))
        platform.y = display.contentHeight + (display.contentHeight/2)

    end

    for _, platform in pairs(platforms) do
        if platform.isVisible then
            platform.y = platform.y - platformSpeed
            
            if platform.y <= 0 and platform.isVisible then

                platform.x, platform.y = 10000, 10000
                platformSpeed = platformSpeed + 0.15
                if platformSpeed >= platformSpeedMax then platformSpeed = platformSpeedMax end

                score = score + 1
                scoreText.text = score
                platform.isVisible = false
            end
        end
    end
end

function screenTouched(event)
    if event.phase == "began" or event.phase == "moved" then
        if event.x < display.contentCenterX then
            touchDirection = "left" 
            leftId = event.id
        else
            touchDirection = "right" 
            rightId = event.id
        end

    elseif event.phase == "ended" then
        if event.id == leftId then leftId = nil end
        if event.id == rightId then rightId = nil end
        touchDirection = nil
    end
end

function gameOver()
    if not death then
        death = true
        composer.gotoScene("retry", {effect="fade", time=100})
    end
end

function onCollision(self, e)
    if e.phase == "began" then
        gameOver()
    end
end

function scene:create(event)
    local sceneGroup = self.view


    scoreText = display.newText({
        text = score,
        x = display.contentCenterX + 15,
        y = 30,
        width = display.contentWidth,
        fontSize = 24,
        font = native.systemFont,
        align = "left"
    })
    sceneGroup:insert(scoreText)
    scoreText:setFillColor(1,0,0)

    rect = display.newRect(
        sceneGroup, 
        display.contentCenterX, 
        display.contentCenterY-100, 
        20, 
        20
    )
    rect:setFillColor(1,1,0)
    physics.addBody(rect, "dynamic", {})
    rect.collision = onCollision
    rect:addEventListener("collision", rect)  
    rect.gravityScale = 5.0  


    for i=1, 12, 1 do 
        local platform = display.newRect(sceneGroup, 10000, 1000, 75, 10)
        physics.addBody(platform, "static")
        platform.isVisible = false
        platforms[#platforms+1] = platform
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
        Runtime:removeEventListener("enterFrame", update)
        Runtime:removeEventListener("touch", screenTouched)
        Runtime:removeEventListener("collision", onCollision)
    elseif phase == "did" then

    end 
end


function scene:destroy(event)
    local sceneGroup = self.view


    -- Called prior to the removal of scene"s "view" (sceneGroup)
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
