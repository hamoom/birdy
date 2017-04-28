local floor = math.floor
local Helper = {}

function Helper.formatTime(seconds)
    local secs = floor(seconds)
    local secsDec = (seconds - secs) * 100
    return string.format("%02d.%02d", secs, secsDec)
end

function Helper.sign(num)
    return (num < 0) and -1 or 1
end

function Helper.easeSin(f,a, damping)
    local a = a
    return function(t, tMax, start, delta)
        a = a * damping
        return start + delta + a * math.sin((t/tMax) * f * math.pi * 2)
    end
end 

function Helper.randomSign()
    return (math.random(0, 1) == 1) and 1 or -1
end

function Helper.oscillate(f, a, axis, howlong, damping, fn)

    if not damping then damping = 0.7 end
    return function(thing)
        transition.to(thing, {time=howlong, delta=true, [axis]=0, transition=Helper.easeSin(f,a, damping), onComplete=function()
            if fn then
                fn()
            end
        end})
    end
end

function Helper.clamp(num, min, max)
    if num < min then num = min elseif num > max then num = max end
    return num
end


return Helper