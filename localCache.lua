-------------------------------------------------------------------------------
-- localCache.lua
-------------------------------------------------------------------------------
local localCache = {}

-- disable logging
local _print = print
local print = function() end

-------------------------------------------------------------------------------
local mt = {}
setmetatable(localCache, mt)

-------------------------------------------------------------------------------
local cache = {}

-------------------------------------------------------------------------------
mt.__index = function(table, key)
    local data = cache[key]
    if data then
        if data.value == nil then
            print(("cached data is dirty for " .. key.red .. "! recomputing!"))
            data.value = data.compute()
        end

        return data.value
    end

    return nil
end

-------------------------------------------------------------------------------
mt.__newindex = function(table, key, value)
    print("adding a cache called " .. key.red .. " to localCache")
    if cache[key] == nil and type(value) == "function" then
        cache[key] = {
            compute = value,
        }
        return
    end

    if cache[key] then
        if value == nil then cache[value] = nil end
        if value == "dirty" then 
            cache[key].value = nil
        end
    end
end

-------------------------------------------------------------------------------
return localCache
