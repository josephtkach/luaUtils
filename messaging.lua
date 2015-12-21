--------------------------------------------------------------------------------
-- messaging.lua
--------------------------------------------------------------------------------
-- lightweight messaging system
--------------------------------------------------------------------------------
local Messaging = {}
Messaging.Once = false
Messaging.Forever = true

--------------------------------------------------------------------------------
local subscriptions = {}

--------------------------------------------------------------------------------
function _subscribe(message, doRepeat, callback)
	local receivers = subscriptions[message]
	if not receivers then
		receivers = {}
		subscriptions[message] = receivers
	end

	receivers[#receivers+1] = { callback = callback, doRepeat = doRepeat }

	-- return the callback so that we can use it as a key for removal
	return callback
end

--------------------------------------------------------------------------------
function Messaging.subscribeOnce(message, callback)
	_subscribe(message, Messaging.Once, callback)
end

--------------------------------------------------------------------------------
function Messaging.subscribe(message, callback)
	_subscribe(message, Messaging.Forever, callback)
end

--------------------------------------------------------------------------------
function Messaging.send(message, data)
	print(("---- sent " .. message).bluebg)
	
	subscriptions[message] = Set.filter( subscriptions[message], function(receiver)
		receiver.callback(data)
		return receiver.doRepeat == Messaging.Forever
	end)
end

--------------------------------------------------------------------------------
function Messaging.unsubscribe(message, callback)
	subscriptions[message] = Set.filter(subscriptions[message], function(x) 
																	return x.callback ~= callback
																end)
end

--------------------------------------------------------------------------------
function Messaging.resetSubscriptions(message)
	if not message then
		warn("no message supplied, clearing all subscriptions")
		subscriptions = {}
	else
		subscriptions[message] = nil
	end
end

--------------------------------------------------------------------------------
function Messaging.funcSendEvent(eventName, data)
	return function()
		Messaging.send(eventName, data)
	end
end

--------------------------------------------------------------------------------
return Messaging
