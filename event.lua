Event = {}
Event.__index = Event

function Event:new()
	local this = {
		hooks = {},
		_lock = false
	}

	this.hooks[0] = 0 -- index 0 is used for hooks table length

	setmetatable(this, Event)

	return this
end

-- if an event is locked, it won't notify any of its hooks
-- in Event:raise()
function Event:lock()
	self._lock = true end
function Event:unlock()
	self._lock = false end
function Event:isLocked()
	return self._lock end

function Event:raise(args)
	if self._lock then return end

	local h = self.hooks
	for i=1,h[0] do
		h[i].call(args)
	end
end

function Event:addHook( hook )
	hook.current_link = self
	local h = self.hooks
	h[h[0] + 1] = hook
	h[0] = h[0] + 1
end

function Event:removeHook( hook_ref )
	local h = self.hooks
	for i,hook in ipairs(h) do
		if hook == hook_ref then
			hook_ref.current_link = nil
			for j = i,h[0]-1 do
				h[j] = h[j+1]
			end
			h[h[0]] = nil
			h[0] = h[0] - 1
			return
		end
	end
end

function Event:clearAllHooks( )
	local h = self.hooks
	for i=1,h[0] do
		h[i].current_link = nil
		h[i] = nil
	end
	h[0] = 0
end

function Event:hookCount()
	return self.hooks[0]
end

Hook = {}
Hook.__index = Hook

function Hook:new(func)
	local this = {call = func, current_link = nil}
	setmetatable(this, Hook)
	return this
end

-- there should never be a reason to call this function (i think?)
function Hook:hookToEvent(event)
	event:addHook(self)
end

function Hook:disconnect()
	if self.current_link then
		self.current_link:removeHook(self)
	end
end
-- alias
Hook.clear = Hook.disconnect
