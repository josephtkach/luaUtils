-----------------------------------------------------------------
-- logging.lua
-----------------------------------------------------------------
-- string colors. Assumes you are printing to a terminal that
-- supports this type of escape sequence
-----------------------------------------------------------------
local colorKeys = {
  -- reset
  reset =      0,

  -- misc
  bright     = 1,
  dim        = 2,
  underline  = 4,
  blink      = 5,
  reverse    = 7,
  hidden     = 8,

  -- foreground colors
  black     = 30,
  red       = 31,
  green     = 32,
  yellow    = 33,
  blue      = 34,
  magenta   = 35,
  cyan      = 36,
  white     = 37,

  -- background colors
  blackbg   = 40,
  redbg     = 41,
  greenbg   = 42,
  yellowbg  = 43,
  bluebg    = 44,
  magentabg = 45,
  cyanbg    = 46,
  whitebg   = 47
}

local escapeString = string.char(27) .. '[%dm'

colorKeys = Set.mapKVP(colorKeys, function(code)
    return escapeString:format(code)
  end)

getmetatable('').__index = function(str,i)
	if type(i) == 'number' then
		return string.sub(str,i,i)
	elseif type(i) == 'string' and colorKeys[i] then
        return colorKeys[i] .. str .. colorKeys.reset
    else
		return string[i]
	end
end

--------------------------------------------------------------------------------
-- Compatibility: Lua-5.0
--------------------------------------------------------------------------------
function string.split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

--------------------------------------------------------------------------------
function string.lastIndexOf(haystack, needle)
    local i = haystack:match(".*"..needle.."()")
    if i == nil then return nil else return i-1 end
end

--------------------------------------------------------------------------------
-- printing
--------------------------------------------------------------------------------
function warn(msg)
    print(("WARNING: " .. msg).yellowbg)
    print(debug.traceback().yellow)
end

-----------------------------------------------------------------------------------------
function raiseError(msg, shortMessage)
    print(("ERROR: " .. msg).red)
    if shortMessage then
        _G[shortMessage] = function() crash() end
        _G[shortMessage]()
    end
end

--------------------------------------------------------------------------------
function vprint(object, msg)
	local indenting = string.rep("\t", (object.treeDepth or 0)+1)

	if object.verbose then print(indenting .. msg) end
end

--------------------------------------------------------------------------------
local defaultColor = "reset"
function vprint_default_color(color)
    defaultColor = color
end

--------------------------------------------------------------------------------
function vprintfield(object, msg, field)
  if not object.verbose then return end

  local indenting = string.rep("\t", (object.treeDepth or 0)+1)
  local color = "yellow"
  if field == nil then color = "red" end
  if type(field) == "table" then field = table_contents_to_oneliner(field) end

  print(indenting .. msg[defaultColor] .. " " .. tostring(field)[color]) 
end

--------------------------------------------------------------------------------
function vtprint(object)
    if object.verbose then 
        local depth = (object.treeDepth or 0)+1
        tprint(object, depth, depth+5) 
    end
end

--------------------------------------------------------------------------------
function vtprint_nr(object, color)
    if object.verbose then 
        local depth = (object.treeDepth or 0)+1
        tprint_nr(object, depth, color)
    end
end

-----------------------------------------------------------------
-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent, maxRecursions)
    maxRecursions = maxRecursions or 5
    if indent and indent > maxRecursions then return end
    if not indent then indent = 0 end
   
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(k).blue .. ": "
        -- this only fixes the bug when a table is its own __index, not for more complicated cycles
        if type(v) == "table" then
            print(formatting .."{")
            tprint(v, indent+1, maxRecursions)
            print(string.rep("  ", indent) .."}")
        else
          print(formatting .. tostring(v).yellow)      
        end
    end
end

-----------------------------------------------------------------
-- tprint "no recursive"
function tprint_nr(table, indent, color)
    if getmetatable(table) and getmetatable(table).readonly then
        tprint_nr(getmetatable(table).original, indent, color)
        return
    end

    local printedSomething = false
    if not indent then indent = 1 end
    for k, v in pairs(table) do
        formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        local output = formatting .. tostring(v)
        if color then output = output[color] end
        print(output)      
        printedSomething = true
    end

    if printedSomething == false then print(("table was empty").red) end
end

--------------------------------------------------------------------------------
function table_contents_to_oneliner(table)
    local printedSomething = false
    if not indent then indent = 1 end
    local output = ""
    for k, v in pairs(table) do
        output = output .. tostring(v) .. ", "
        printedSomething = true
    end
    
    if printedSomething == false then output = ("table was empty").red end
    return output
end

-----------------------------------------------------------------
function dateTimeToNumber(dateTime)
    local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)Z"
    local y, m, d, h, M, s, z = string.match(dateTime, pattern)
    return os.time({year = y, month = m, day = d, hour = h, min = m, sec = s})
end 
