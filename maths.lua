-----------------------------------------------------------------
-- maths
-- this is a random assortment of math-related things I have added
-- at one point or another
-----------------------------------------------------------------
-- code to round to nearest multiple (positive integers only)
function roundToFloor(number, nearestN)
    return math.floor(number * (1 / nearestN) ) * nearestN
end

-----------------------------------------------------------------
-- code to round to nearest multiple (positive integers only)
function roundToCeiling(number, nearestN)
    return math.ceil(number * (1 / nearestN) ) * nearestN
end

-----------------------------------------------------------------
function roundToNearest( number, multiple )
    local half = multiple/2;
    return number+half - (number+half) % multiple;
end

-----------------------------------------------------------------
function distance(x1, y1, x2, y2)
    local xd = x2-x1
    xd = xd * xd

    local yd = y2-y1
    yd = yd * yd
    return math.sqrt(xd+yd)
end

-----------------------------------------------------------------
function midpointSubdivision(x1, y1, x2, y2, subdivisions)
    local output = {}

    local function recurse(x1, y1, x2, y2, subdivisions, indexMin, indexMax)
        local mx = (x1 + x2)/2
        local my = (y1 + y2)/2

        local d = distance(mx, my, x2, y2)/2

        local index = math.floor( ((indexMax - indexMin)+1) / 2) + indexMin

        mx =  mx + math.random(-d,d)
        my = my + math.random(-d,d)
        output[index] = { x= mx, y = my }

        if subdivisions > 0 then
            recurse(x1, y1, mx, my, subdivisions - 1, indexMin, index)
            recurse(mx, my, x2, y2, subdivisions - 1, index, indexMax)
        end
    end

    recurse(x1, y1, x2, y2, subdivisions, 0, math.pow(2,subdivisions+1))

    return output
end

--------------------------------------------------------------------------------
--uses the polar form of the Box-Muller transformation to return one (or two) number with normal distribution (average=0 and variance=1)
local function internal_rand_normal()
    local x1, x2, w, y1, y2
    repeat 
        x1 = 2 * math.random() - 1
        x2 = 2 * math.random() - 1
        w = x1*x1+x2*x2
    until (w < 1)

    w = math.sqrt((-2*math.log(w))/w)
    y1 = x1*w
    y2 = x2*w
    return y1,y2
end

--------------------------------------------------------------------------------
function rand_normal(min, max, variance)
    local average = (min+max)/2
    if variance == nil then variance = 2.4 end --2.4 because it means that 98,36% from all values will be between min and max
    local escala = (max - average)/variance 
    local x = escala*internal_rand_normal()+average
    x = math.max(x, min)
    x = math.min(x, max)
    return math.ceil(x)
end

--------------------------------------------------------------------------------
function rand_normal_pyramid(max)
    local half = max / 2
    local result = math.abs( rand_normal(-half, half) )
    if result == 0 then result = 1 end
    return result 
end

--------------------------------------------------------------------------------
function numberWithVariance(number, variance)
    return number + (math.random() - .5) * (number * variance * 2)
end

-----------------------------------------------------------------------------------------
function coin_flip(a, b)
    local flip = math.random(1,2)
    if flip == 1 then return a end
    return b
end

-----------------------------------------------------------------------------------------
-- prints a number as a string in a base
local base = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' }
function tobase( aNumber, aBase )
    --assert( aNumber, 'bad argument #1 to \'tobase\' (nil number)' )
    --assert( aBase and aBase >= 2 and aBase <= #base, 'bad argument #2 to \'tobase\' (base out of range)' )

    local isNegative = aNumber < 0
    local aNumber = math.abs( math.floor( tonumber( aNumber ) ) )
    local aBuffer = {}
      
    repeat
        aBuffer[ #aBuffer + 1 ] = base[ ( aNumber % aBase ) + 1 ]
        aNumber = math.floor( aNumber / aBase )
    until aNumber == 0

    if isNegative then
        aBuffer[ #aBuffer + 1 ] = '-'
    end
    
    return table.concat( aBuffer ):reverse()
end

-----------------------------------------------------------------------------------------
local uniqueIDGenerator = 0
function generateUniqueID()
    uniqueIDGenerator = uniqueIDGenerator + 1
    return uniqueIDGenerator
end

--------------------------------------------------------------------------------
function getStepScale(x)
    local scale = math.floor(x / 5)
    if scale == 0 then scale = 1 end
    return scale*scale
end

--------------------------------------------------------------------------------
function ift(condition, a, b)
    if condition then return a else return b end
end

--------------------------------------------------------------------------------
function constantFunction(value)    
    return function() return value end
end
