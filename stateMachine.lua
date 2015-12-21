---------------------------------------------------------------------------------
-- stateMachine.lua
-- class for FSMs
---------------------------------------------------------------------------------
local StateMachine = OOP.newClass({ 	name = "StateMachine", })

---------------------------------------------------------------------------------
function StateMachine:addState(name, state)
	if self.states[name] then 
		warn("State machine already has a state named: " .. tostring(name))
	end
	self.states[name] = state
end

---------------------------------------------------------------------------------
function StateMachine:setState(name)
	vprint(self, "setting state machine state to ", name)
	
	local newState = self.states[name]
	if not newState then warn("no state found named " .. tostring(name)) end

	if newState then
		if self.currentState and self.currentState.onExit then
			vprint(self, "onExit: ", name)
			self.currentState.onExit(self)
		end

		self.currentState = newState
		if self.currentState and self.currentState.onEnter then
			vprint(self, "onEnter: ", name)
			newState.onEnter(self) 
		end
	end
end

---------------------------------------------------------------------------------
function StateMachine:update(params)
	if self.currentState and self.currentState.onUpdate then
		self.currentState.onUpdate(self, params)
	end
end

---------------------------------------------------------------------------------
function StateMachine:new()
	local fsm = {}
	setmetatable(fsm, self)
	self.__index = self

	fsm.states = {}
	fsm.currentState = nil

	return fsm
end

return StateMachine