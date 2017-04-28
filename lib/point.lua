local Point = {}
local Point_mt = { __index = Point }

local sin, cos, atan2, sqrt = math.sin, math.cos, math.atan2, math.sqrt

local function createXAndY(arg)
    local x,y
    if arg.n == 1 then
        local val = arg[1]
        if type(arg[1]) == "number" then
            x,y = val, val
        else
            local obj = arg[1]
            x,y = val.x, val.y
        end
    elseif arg.n == 2 then
        x,y = arg[1], arg[2]
    else 
        error("incorrect parameter count")
    end
    return x,y
end

local function createXandYNonMut(arg)
    local x1,y1,x2,y2
    if arg.n == 2 then
        x1,y1 = arg[1].x, arg[1].y
        x2,y2 = arg[2].x, arg[2].y   
    elseif arg.n == 4 then
        x1,y1 = arg[1], arg[2]
        x2,y2 = arg[3], arg[4]
    else
        error("incorrect parameter count")
    end
    return x1,y1,x2,y2
end

function Point.new(...)
    local x,y = createXAndY(arg)
    local thisPoint = {x=x, y=y}
    return setmetatable(thisPoint, Point_mt)
end

function Point.newFromAng(angle)
    local angle = (math.pi * angle) / 180
    return Point.newFromAngRad(angle)
end

function Point.newFromAngRad(angle)
    local thisPoint = {x=cos(angle), y=sin(angle)}
    return Point.new(thisPoint)
end


function Point.newFromAddition(...)
    local x1,y1,x2,y2 = createXandYNonMut(arg)

    return Point.new(x1+x2, y1+y2)
end

function Point.newFromSubtraction(...)
    local x1,y1,x2,y2 = createXandYNonMut(arg)
    return Point.new(x1-x2, y1-y2)
end

function Point.newFromMultiplication(...)
    local x1,y1,x2,y2 = createXandYNonMut(arg)
    return Point.new(x1*x2, y1*y2)
end

function Point.newFromDivision(...)
    local x1,y1,x2,y2 = createXandYNonMut(arg)
    return Point.new(x1/x2, y1/y2)
end

function Point:add(...)
    local x,y = createXAndY(arg)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

function Point:subtract(...)
    local x,y = createXAndY(arg)
    self.x = self.x - x
    self.y = self.y - y
    return self
end

function Point:multiply(...)
    local x,y = createXAndY(arg)
    self.x = self.x * x
    self.y = self.y * y
    return self
end

function Point:divide(...)
    local x,y = createXAndY(arg)
    self.x = self.x / x
    self.y = self.y / y
    return self
end

function Point:length()
    return sqrt((self.x*self.x) + (self.y*self.y))
end

function Point:normalize()
    local tempPoint = self:normalized()
    self.x, self.y = tempPoint.x, tempPoint.y
    return self
end

function Point:normalized()
    local length = self:length()
    if length > 0 then
        return self:divide(length, length)
    else
        return self:setPosition(0,0)
    end
end

function Point:rounded()
    return self:setPosition(math.round(self.x), math.round(self.y))
end

function Point:distanceTo(...)
    local x,y = createXAndY(arg)
    local tempPoint = Point.new(self.x-x, self.y-y)
    return tempPoint:length()
end

function Point:angleRad()
    return atan2(self.y, self.x)
end

function Point:angle()
    return self:angleRad() * 180 / math.pi
end

function Point:print()
    print("x: " .. self.x .. " y: " .. self.y)
end

function Point:getPosition()
    return self.x, self.y
end

function Point:getPositionRounded()
    return math.round(self.x), math.round(self.y)
end

function Point:setPosition(...)
    self.x, self.y = createXAndY(arg) 
    return self
end

function Point.shortestAngleBetween(target, source)
   local a = target - source
   
   if (a > 180) then
      a = a - 360
   elseif (a < -180) then
      a = a + 360
   end
   
   return a
end

return Point


