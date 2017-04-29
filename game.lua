
local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")
local h = require("lib.helper")
local m = require("lib.mydata")

physics.start()
---------------------------------------------------------------------------------

-- FUNCTIONS
local screenTouched
local update
local getDeltaTime
local onCollision
local gameOver

-- TIME
local lastUpdate = 0
local dt = 0

-- GAME STARTED AND ENDED
local gameStarted = false
local death = false

-- TEXT
local startTextTimer
local startText
local scoreText

-- PLAYER
local rect
local indicator
local maxX = 220
local maxUp = 290
local accelX = 7
local gravityMax = 3

-- TOUCHES
local leftId
local rightId
local touchDirection

-- PLATFORMS
local platformSpeed = 0.75
local platformSpeedMax = 2.75
local platformTimer = 0
local platformTimerMax = 5.3
local platformTimerMin = 1.3
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

    -- PLAYER MOVEMENT
    local vx, vy = rect:getLinearVelocity()
    local newVx, newVy = 0,0

    if touchDirection == "left" and leftId then 
        newVx = vx - accelX
        newVy = vy - 50
    elseif touchDirection == "right" and rightId then
        newVx = vx + accelX
        newVy = vy - 50
    end    

    newVx = h.clamp(newVx, -maxX, maxX)
    newVy = h.clamp(newVy, -maxUp, 10000)

    if touchDirection then
        rect:setLinearVelocity(newVx, newVy)
    end

    if rect.x > display.contentWidth then 
        rect.x = 0 
    end

    if rect.x < 0 then 
        rect.x = display.contentWidth
    end

    rect.y = h.clamp(rect.y, -25, display.contentHeight + rect.height + 100)

    if rect.y >= (display.contentHeight + rect.height) then
        gameOver()
    end

    if rect.y < 0 then
        indicator.isVisible = true
        scoreText:setFillColor(0.3, 0.3, 0.3)
    else
        indicator.isVisible = false
        scoreText:setFillColor(1, 0, 0)
    end

    -- INDICATOR
    indicator.x = rect.x

    -- OBSTACLES
    if gameStarted then
        platformTimer = platformTimer - dt

        if platformTimer <= 0 then
            platformTimer = platformTimerMax

            local platform = platforms[#platforms]
            platform.isVisible = true
            platforms[#platforms] = nil
            table.insert(platforms, 1, platform)
            platform.x = math.random(platform.width/2, display.contentWidth-(platform.width/2))
            platform.y = display.contentHeight + 100

        end

        for _, platform in pairs(platforms) do
            if platform.isVisible then
                platform.randomSin = platform.randomSin + (platform.randomDir * 0.055)
                platform.x = platform.x + (math.sin(platform.randomSin) * 2.5)
                platform.y = platform.y - platformSpeed
                
                if platform.y <= 0 and platform.isVisible then

                    platform.x, platform.y = 10000, 10000
                    platformSpeed = platformSpeed + 0.15
                    if platformSpeed >= platformSpeedMax then platformSpeed = platformSpeedMax end

                    platformTimerMax = platformTimerMax - 0.2
                    if platformTimerMax <= platformTimerMin then platformTimerMax = platformTimerMin end
                    
                    platform.isVisible = false

                    if rect.y > 0 then
                        m.score = m.score + 1
                        scoreText.text = m.score
                    end
                end
            end
        end
    end
end

function screenTouched(event)
    if event.phase == "began" or event.phase == "moved" then

        if not gameStarted then
            gameStarted = true
            startText.isVisible = false
            timer.cancel(startTextTimer)
            rect.gravityScale = gravityMax
        end

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
        m.setBestScore()        
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

    -- START TEXT
    startText = display.newText({
        text = "TOUCH TO START",
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = display.contentWidth,
        fontSize = 35,
        font = native.systemFont,
        align = "center"
    })

    startTextTimer = timer.performWithDelay(1000, function()
        if startText.isVisible then
            startText.isVisible = false
        else
            startText.isVisible = true
        end    
    end, 0)

    -- SCORE TEXT
    m.score = 0
    scoreText = display.newText({
        text = m.score,
        x = display.contentCenterX + 15,
        y = 30,
        width = display.contentWidth,
        fontSize = 24,
        font = native.systemFont,
        align = "left"
    })
    sceneGroup:insert(scoreText)
    scoreText:setFillColor(1,0,0)

    -- OUT OF BOUNDS INDICATOR
    indicator = display.newRect(sceneGroup, 0, 0, 5, 10)
    indicator.isVisible = false

    -- PLAYER
    rect = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY-100, 20, 20)
    rect:setFillColor(1,1,0)
    physics.addBody(rect, "dynamic", {})
    rect.collision = onCollision
    rect:addEventListener("collision", rect)  
    rect.gravityScale = 0 
    rect.isFixedRotation = true

    -- PLATFORMS
    for i=1, 12, 1 do 
        local platform = display.newRect(sceneGroup, 10000, 1000, 75, 10)
        platform.randomSin = math.random(-1, 1)
        platform.randomDir = h.randomSign()
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
