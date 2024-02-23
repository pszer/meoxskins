require 'math'
require "tick"

-- tick globals
--TICKTIME = 1/60.0
--TICKACC = 0.0

--TICK = 0

--function GetTick()
--	return TICK
--end

--function IncrementTick()
--	TICK = TICK + 1
--end

--[[
--timer utility classes
--time function used is passed as argument to Timer:new
--]]

Timer = {}
Timer.__index = Timer
Timer.__type  = "timer"

function Timer:new(TIMEFUNC)
	local t = {
		timefunc = TIMEFUNC,
		starttick = 0,
		pausetick = -1,         -- pausetick is -1 if not paused
		pausedifference = 0
	}
	setmetatable(t, Timer)
	if TIMEFUNC then t:Start() end
	return t
end

-- starts the timer, restarts if paused
function Timer:Start()
	self.starttick = self.timefunc()
	self.pausedifference = 0
	self.pausetick = -1
end

-- gets the current time since started
function Timer:Time()
	if self.pausetick == -1 then -- if unpaused
		return self.timefunc() - self.starttick - self.pausedifference
	else -- if paused, get time from start up to when paused
		return self.pausetick - self.starttick - self.pausedifference
	end
end

-- pauses timing until resumed
-- if already paused do nothing
function Timer:Pause()
	if self.pausetick == -1 then
		self.pausetick = self.timefunc()
	end
end

-- resumes back to timing if paused
function Timer:Resume()
	if self.pausetick ~= -1 then
		local dif = self.timefunc() - self.pausetick
		self.pausetick = -1
		self.pausedifference = self.pausedifference + dif
	end
end

-- common timers
--
-- uses ingame tick for timing
-- getTickSmooth()
TimerTick = Timer:new()
TimerTick.__index = TimerTick
function TimerTick:new() return Timer:new(getTickSmooth) end

-- uses real time seconds
TimerReal = Timer:new()
TimerReal.__index = TimerReal
function TimerReal:new() return Timer:new(love.timer.getTime) end

-- counts down X amount of time from creation, Done() returns true after X time passes
CountdownTimer = Timer:new()
CountdownTimer.__index = CountdownTimer
function CountdownTimer:new(ticks, TIMEFUNC)
	local t = Timer:new(TIMEFUNC)
	setmetatable(t, CountdownTimer)
	t.__ticks__ = ticks
	return t
end
function CountdownTimer:Done() return self:Time() >= self.__ticks__ end

-- countdown with game ticks
CountdownTicks = CountdownTimer:new()
CountdownTicks.__index = CountdownTicks
function CountdownTicks:new(ticks) return CountdownTimer:new(ticks, GetTick) end
-- countdown with real seconds
CountdownReal = CountdownTimer:new()
CountdownReal.__index = CountdownReal
function CountdownReal:new(secs) return CountdownTimer:new(secs, GetSecond) end

-- Passes time passed through a given function
FunctionTimer = Timer:new()
FunctionTimer.__index = FunctionTimer
function FunctionTimer:new(func, TIMEFUNC)
	local t = Timer:new(TIMEFUNC)
	t.__func__ = func
	setmetatable(t, FunctionTimer)
	return t
end
function FunctionTimer:Get()
	return self.__func__(self:Time())
end

-- Raises a pulse of X duration every Y time
PulseClock = FunctionTimer:new()
PulseClock.__index = PulseClock
function PulseClock:new(pulsetime, pulsedelay, TIMEFUNC)
	local func = function (t)
		return math.fmod(t, pulsedelay) - pulsetime < 0
	end
	local t = FunctionTimer:new(func, TIMEFUNC)
	setmetatable(t, PulseClock)
	return t
end
