--------------------------------------------------------------------------------
-- permissions.lua
-- set properties and read/write permissions on objects
-------------------------------------------------------------------------------
local Permissions = {}

--------------------------------------------------------------------------------
-- disable logging in data
local _print = print
--local print = function() end

--------------------------------------------------------------------------------
local function each(self, predicate)
    local mt = getmetatable(self)
    return Set.each(mt.original, predicate)
end

--------------------------------------------------------------------------------
local function index(self, key)
    if key == "readonly" then return true end
    if key == "each" then return each end
    local mt = getmetatable(self)
    return mt.original[key]
end

--------------------------------------------------------------------------------
local function readOnlyNewIndex(self, key, value)
    warn("tried to assign " .. tostring(value) .. " to key: " .. key .. " on table: " .. tostring(self))
    print(debug.traceback().yellow)
end

--------------------------------------------------------------------------------
local function replaceWithProxy(object, recursive, newindex)
    if recursive then warn("Permissions: recursive not implemented yet") end
  
    local original = {}
    for k,v in pairs(object) do
        original[k] = v
        object[k] = nil
    end
    setmetatable(original, getmetatable(object))

    ----------------------------------------------------------------------------
    setmetatable(object, { 
        readonly = true, 
        original = original, 
        __index = index, 
        __newindex = newindex
    })
end

--------------------------------------------------------------------------------
function Permissions.makeReadOnly(object, recursive)
     print("making an object: " .. tostring(object).cyan .. (" read-only").magenta)
    replaceWithProxy(object, recursive, readOnlyNewIndex)
end

--------------------------------------------------------------------------------
--  options: 
--      recursive - create the proxy recursively
function Permissions.watch(object, field, options)
    print("setting a watch on " .. tostring(object) .. "." .. field)
    local function watchNewIndex(self, key, value)
        if key == field then
            local oldValue = rawget(getmetatable(object).original, key)
            warn("modified key: " .. key .. " on table: " .. tostring(self)
                .. "\nold value: " .. tostring(oldValue)
                .. "\nnew value: " .. tostring(value))
        end
        rawset(getmetatable(object).original, key, value)
    end

    replaceWithProxy(object, recursive, watchNewIndex)
end

--------------------------------------------------------------------------------
function Permissions.makeReadAndWrite(object, recursive)
    print("making an object: " .. tostring(object).cyan .. (" read and write").magenta)
    if recursive then warn("Permissions: recursive not implemented yet") end
  
    local mt = getmetatable(object)
    if not mt.readonly then return end

    local original = mt.original
    setmetatable(object, nil)

    for k,v in pairs(original) do
        object[k] = v
    end

    setmetatable(object, getmetatable(original))
end

--------------------------------------------------------------------------------
function Permissions.initProperties(object)
    vprint(object, "initializing properties for object " .. tostring(object.name))

    local accessors = {}
    local mutators = {}

    local mt = getmetatable(object)

    -- case 0: the object is, itself, a 'class' and intended to be used as a metatable
    if object.__index == object then
        vprint(object, "\t initProperties case 0")
        mt = object
    end

    -- case 1: the object is a proxy with read-only permissinos
    if mt.readonly and mt.original then
        vprint(object, "\t initProperties case 1")
        object = mt.original
        mt = getmetatable(object)
    end

    -- case 2: the object is plain old data
    if not mt then 
        vprint(object, "\t initProperties case 2")
        mt = {}
        setmetatable(object, mt)
    end
    
    function mt:addProperty(name, accessor, mutator)
        accessors[name] = accessor
        mutators[name] = mutator
    end

    mt.__index = function(self, key)
        local accessor = accessors[key]
        if accessor then return accessor(self) end
        return mt[key] or rawget(self, key)
    end

    mt.__newindex = function(self, key, value)
        local mutator = mutators[key]
        if mutator then return mutator(self, value) end
        rawset(self, key, value)
    end
end

--------------------------------------------------------------------------------
return Permissions

