-----------------------------------------------------------------------------------------
-- sets.lua
-----------------------------------------------------------------------------------------
-- lightweight functional programming library. If you prefer a more academic
-- definition of "functional programming", this is probably not the library for you
-----------------------------------------------------------------------------------------
local set = {}
set.__index = set
set.NULL = {}

-----------------------------------------------------------------------------------------
-- the null set
-- not the DRYest code in the world but we are too early in the init process to do this more
-- cleanly. 
local setMT = {}
setMT.__newindex = function(self, key, value)
    if key == "NULL" then return end
    rawset(self, key, value)
end
setmetatable(set, setMT)

local nullMT = {}
setmetatable(set.NULL, nullMT)
nullMT.__newindex = function(self, key, value)
	warn("You tried to write to a field on the null set called " 
		.. key .. ", I know you didn't mean it.")
end
nullMT.__index = function(self, key) 
	warn("You tried to read a field from the null set called " 
		.. key .. ", I know you didn't mean it.")
end

-----------------------------------------------------------------------------------------
local function hookIfPossible(A)
	if getmetatable(A) == nil then setmetatable(A, set) end
end

-----------------------------------------------------------------------------------------
function set.new(A)
	local newSet = A or {}
	if getmetatable(A) ~= nil then
		print(" ")
		print("WARNING: Tried to convert a table with a non-nil metatable to a set")
		print(debug.traceback())
	end
	setmetatable(newSet, set)
	return newSet
end

-----------------------------------------------------------------------------------------
local function matches(object, search)
	for k,v in pairs(search) do
		if object[k] ~= v then return false end
	end

	return true
end

-----------------------------------------------------------------------------------------
function set.first(A, search)
	if not A then return nil end
	if search == nil then return A[1] end

	for index,object in pairs(A) do
		if matches(object, search) then return object end
	end
end

-----------------------------------------------------------------------------------------
function set.last(A)
	-- assumes a continuous array
	if not A then return nil end
	return A[#A]
end

-----------------------------------------------------------------------------------------
function set.contains(A, x)
	set.each(A, function(xPrime)
		if x == xPrime then return true end
	end)

	return false
end

-----------------------------------------------------------------------------------------
function set.empty(A)
	if not A then return true end
	return set.hashSize(A) == 0
end

-----------------------------------------------------------------------------------------
function set.hashSize(A)
	local count = 0
	if A then
		for k,v in pairs(A) do count = count + 1 end
	end
	return count
end

-----------------------------------------------------------------------------------------
set.count = set.hashSize

-----------------------------------------------------------------------------------------
function set.print(A, indent)
	indent = indent or 1
	if not A then return end
	tprint(A, indent)
	return A
end

-----------------------------------------------------------------------------------------
function set.randomFromRangeInSet(A, min, max)
	if #A == 0 then return nil end
	if #A == 1 then return A[1] end
	if min == max then return A[min] end
	return A[ math.random(min, max) ]
end

-----------------------------------------------------------------------------------------
function set.randomFrom(A)
	return set.randomFromRangeInSet(A, 1, #A)
end

-----------------------------------------------------------------------------------------
function set.randomFromHash(A)
	set.randomFrom( set.fromHashValues(A) )
end

-----------------------------------------------------------------------------------------
-- optimization
local function append(A, x)
	A[#A+1] = x
	return A
end

-----------------------------------------------------------------------------------------
function set.append(A, x)
	if not A then A = {} end
	hookIfPossible(A)
	return append(A, x)	
end

-----------------------------------------------------------------------------------------
function set.limit(A, count)
	if not A then return A end
	local output = set.new()

	for i = 1, count do
		if not A[i] then return output end
		append(output, A[i])
	end

	return output
end

-----------------------------------------------------------------------------------------
function set.keys( A )
	local output = set.new()
	for k,v in pairs(A) do
		append(output, k)
	end
	return output
end

-----------------------------------------------------------------------------------------
function set.fromHashValues( A )
	local output = set.new()
	for k,v in pairs(A) do
		append(output, v)
	end
	return output
end

-----------------------------------------------------------------------------------------
function set.each( A, predicate )
	if not A then return nil end
	hookIfPossible(A)
	for k,v in pairs(A) do predicate(v, k) end
	return A
end

-----------------------------------------------------------------------------------------
function set.reverseHash(A)
	local output = set.new()
	for k,v in pairs(A) do output[v] = k end
	return output
end

-----------------------------------------------------------------------------------------
function set.map( A, predicate )
	local output = set.new()
	set.each( A, function(x) output[x] = predicate(x) end )
	return output
end

-----------------------------------------------------------------------------------------
function set.mapKVP( A, predicate )
	local output = set.new()
	set.each( A, function(v, k) output[k] = predicate(v) end )
	return output
end

-----------------------------------------------------------------------------------------
function set.pluck( A, childIndex )
	return set.map( A, function(x) return x[childIndex] end )
end

-----------------------------------------------------------------------------------------
function set.filter( A, predicate )
	local output = set.new()
	set.each( A, 	function(x, k)
						if predicate(x, k) then output[k] = x end
					end )
	return output
end

-----------------------------------------------------------------------------------------
function set.concatenate(A, B)
	if not A then A = set.new() end
	if not B then return A end
	set.each(B, function(x) append(A, x) end)
	return A
end

-----------------------------------------------------------------------------------------
function set.concatenateKVP(A, B, allowOverwrite)
	if not A then A = set.new() end
	if not B then return A end
	set.each(B, function(v, k)
					-- best collision resolution is no collision resolution =\
					if not allowOverwrite and A[k] then
						print("WARNING: Overwrote key " .. k .. " in set.concatenateKVP") 
						exception_if_not_ship()
					end
					A[k] = v 
				end)
	return A
end

-----------------------------------------------------------------------------------------
function set.union( A, B )
	local output = set.new()
	set.concatenate(output, A)
	set.concatenate(output, B)
	return output
end

-----------------------------------------------------------------------------------------
function set.unionKVP( A, B )
	local output = set.new()
	set.concatenateKVP(output, A)
	set.concatenateKVP(output, B)
	return output
end

-----------------------------------------------------------------------------------------
function set.unionKVPwithOverwrite( A, B )
	local output = set.new()
	set.concatenateKVP(output, A, true)
	set.concatenateKVP(output, B, true)
	return output
end

-----------------------------------------------------------------------------------------
function set.presenceHash( A )
	local output = {}
	set.each( A, function(x) output[x] = true end )
	return output
end

-----------------------------------------------------------------------------------------
function set.distinct( A )
	local A_has = set.presenceHash(A)
	return set.keys(A_has)
end

-----------------------------------------------------------------------------------------
set.unique = set.distinct

-----------------------------------------------------------------------------------------
function set.intersection( A, B )
	local output = set.new()
	local B_has = set.presenceHash(B)
	set.each( A, 	function(x) 
						if B_has[x] then
							 append(output, x) 
						end 
					end )
	return output
end

-----------------------------------------------------------------------------------------
function set.relativeComplement(A, B)	-- the set of all A not in B
	local output = set.new()
	local B_has = set.presenceHash(B)
	set.each( A, 	function(x) 
						if not B_has[x] then
							 append(output, x) 
						end 
					end )
	return output
end

-----------------------------------------------------------------------------------------
return set










