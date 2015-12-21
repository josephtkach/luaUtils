--------------------------------------------------------------------------------
-- OOP.lua
-- object-oriented idioms
-- this is probably the most WIP file in the repo
-- but it sometimes comes in handy
--------------------------------------------------------------------------------
local OOP = {}
OOP.name = "OOP"

--------------------------------------------------------------------------------
local function getSuperClass(object, class)
	if class == nil then
		return getmetatable(object)
	else
		return getmetatable(class)
	end
end

--------------------------------------------------------------------------------
function OOP.isA(object, class)	
	local objectClass = getSuperClass(object)
	while objectClass do
		if objectClass == class then return true end
		objectClass = getSuperClass(object, objectClass)
	end
	return false
end

--------------------------------------------------------------------------------
function OOP.newClass(params)
	local class = {}
	class.__index = class

	for k,v in pairs(params) do 
		class[k] = v
	end
	
	setmetatable(class, OOP)
	Permissions.initProperties(class)
	return class
end

--------------------------------------------------------------------------------
function OOP.deriveFrom(parent, params)
	local class = OOP.newClass(params)
	setmetatable(class, parent)
	return class
end

--------------------------------------------------------------------------------
function OOP.baseInit(object, params, class, debug)
	debug = debug or OOP

	object.params = params
	object.verbose = params.verbose
	object.name = params.name

	if class then
		vprint(debug,"class is " .. tostring(class.name)) 
	else
		vprint(debug,"class is nil") 
	end

	class = getSuperClass(object, class)

	if class then vprint(debug,"resolved class to " .. tostring(class.name)) end

	if class and class.baseInit then
		vprint(debug,"calling class base init with class: " .. tostring(class.name))
		class.baseInit(object, params, class)
	else
		vprint(debug,"did not recursively call baseInit")
	end
end

--------------------------------------------------------------------------------
function OOP.baseRemoveSelf(object, class)
	class = getSuperClass(object, class)

	if class and class.baseRemoveSelf then
		class.baseRemoveSelf(object, class)
	end
end

--------------------------------------------------------------------------------
return OOP