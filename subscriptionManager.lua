--------------------------------------------------------------------------------
-- subscriptionManager.lua
--------------------------------------------------------------------------------
require "scripts.lowlevel.messaging"

--------------------------------------------------------------------------------
local SubscriptionManager = {}
SubscriptionManager.__index = SubscriptionManager

--------------------------------------------------------------------------------
function SubscriptionManager:new()
	local subManager = {}
	setmetatable(subManager, self)

	subManager.subscriptions = {}

	return subManager
end

--------------------------------------------------------------------------------
function SubscriptionManager:add(message, callback)
	if self.subscriptions[message] then
		print ("warning, attempted double subscription on " .. tostring(message))
		print (debug.traceback())
		Messaging.unsubscribe(message, self.subscriptions[message])
	end

	self.subscriptions[message] = callback
	Messaging.subscribe(message, callback)
end

--------------------------------------------------------------------------------
function SubscriptionManager:clear(message)
	if message then 
		Messaging.unsubscribe(message, self.subscriptions[message])
	else
		for k,v in pairs(self.subscriptions) do
			Messaging.unsubscribe(k, v)
		end
		self.subscriptions = {}
	end
end

--------------------------------------------------------------------------------
return SubscriptionManager