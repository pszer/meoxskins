--[[ ingame key/mouse inputs should be queried through here
--]]
--

--[[
-- When inputs are to be queried, they are queried at some control lock level.
-- Control locks can be opened/closed, if a control lock is closed
-- all queries at that control lock level will be blocked (false). When
-- control locks are open, only queries for the highest priority lock are
-- enabled. All control locks are placed at unique priority levels.
--
-- This means that controls are only read by one part of the game at a time, e.g.
-- if an inventory menu is opened inputs for character movement which is at a lower
-- priority is blocked.
--
-- A control lock can be forced open to read inputs even if higher priority locks
-- are open. It will be skipped in checking priority for other open locks.
-- A control lock can be given elevated priority to block inputs to all other locks
--
--]]

--[[
-- Use:
--
-- CONTROL_LOCK.lockname() returns if lockname is enabled
--
-- these functions change a locks status
-- CONTROL_LOCK.lockname.close()
-- CONTROL_LOCK.lockname.open()
-- CONTROL_LOCK.lockname.forceOpen()
-- CONTROL_LOCK.lockname.elevate()
--
--]]

require 'table'

require "timer"
require "cfg.keybinds"

-- lower priority number = higher priority
--
-- status
-- 0 = closed
-- 1 = opened
-- 2 = forced open
-- 3 = elevated priority
--
CONTROL_LOCK = {
--              priority | status | queued status
	CONSOLE      = {0,        0,     0},

	EDIT_CONTEXT   = {100,      0,0},
	EDIT_WINDOW    = {102,      0,0},
	EDIT_PANEL     = {104,      0,0},
	EDIT_VIEW      = {105,      0,0},

	META       = {9999,     2,     2}
}

-- shorter alias
CTRL = CONTROL_LOCK

-- if additional control locks are needed only add them through this
-- ensures priorities dont clash and correct metatables are set
function ADD_CONTROL_LOCK(name, priority)
	for _,lock in pairs(CONTROL_LOCK) do
		if priority == lock[1] then
			print("Failed adding control lock " .. name .. ". Priority level " .. priority
			      .. " already exists")
			return
		end
	end
	CONTROL_LOCK[name] = {priority, 0,0}
	setmetatable(CONTROL_LOCK, CONTROL_LOCK_METATABLE)
end

-- metatable for each control lock in CONTROL_LOCK
CONTROL_LOCK_METATABLE = {
	close      = function(lock) lock[2] = 0 lock[3] = 0 end,
	open       = function(lock) lock[2] = 1 lock[3] = 1 end,
	forceOpen  = function(lock) lock[2] = 2 lock[3] = 2 end,
	elevate    = function(lock) lock[2] = 3 lock[3] = 3 end,

	queueClose      = function(lock) lock[3] = 0 end,
	queueOpen       = function(lock) lock[3] = 1 end,
	queueForceOpen  = function(lock) lock[3] = 2 end,
	queueElevate    = function(lock) lock[3] = 3 end
}
CONTROL_LOCK_METATABLE.__index = function (lock,t)
	return function() CONTROL_LOCK_METATABLE[t](lock) end
end
CONTROL_LOCK_METATABLE.__call  = function(t)
	if t == nil then
		print("Control lock " .. lock_name .. " doesn't exist!")
		return false
	end

	-- closed
	if t[2] == 0 then
		return false
	end

	-- forced open / elevated priority
	if t[2] == 3 or t[2] == 2 then
		return true
	end

	-- open
	-- check if a higher priority lock is open
	for _,lock in pairs(CONTROL_LOCK) do
		if lock ~= t then
			-- ignore this lock if its closed/forced open
			if not (lock[2] == 0 or t[2] == 2) then

				-- if a lock has elevated priority this lock
				-- and all others open locks are disabled
				if lock[2] == 3 then
					return false
				end

				-- if a lock with higher priority is open
				-- this lock is disabled
				if lock[2] == 1 and (lock[1] < t[1]) then
					return false
				end
			end
		end
	end

	return true
end
setmetatable(CONTROL_LOCK_METATABLE, CONTROL_LOCK_METATABLE)

for _,lock in pairs(CONTROL_LOCK) do
	setmetatable(lock, CONTROL_LOCK_METATABLE)
end

--[[
-- input recording system
--
-- keys that are currently being pressed are added to here using
-- callback functions. includes time information for how long a key has been
-- pressed and such
--
-- each keypress has 3 stages, the first tick where it is down, the ticks after
-- where it is held, and the tick it is released
--]]

CONTROL_KEYS_DOWN = {}

function KEY_PRESS(key, scancode, isrepeat)
	if isrepeat then return end

	CONTROL_KEYS_DOWN[scancode] = { "down" , TimerTick:new() , TimerReal:new() }
	CONTROL_KEYS_DOWN[scancode][2]:Start()
	CONTROL_KEYS_DOWN[scancode][3]:Start()
end

function KEY_RELEASE(key, scancode)
	if CONTROL_KEYS_DOWN[scancode] then
		CONTROL_KEYS_DOWN[scancode][1] = "up"
	end	
end

-- this is used for wheelup/wheeldown. these are discrete inputs i.e no "down"/"held"/"up" phase,
-- so their inputs are registered as "up"
local niltimer = {
	Time = function() return 0 end}
function KEY_UP(key, scancode)
	CONTROL_KEYS_DOWN[scancode] = {"up", niltimer, niltimer}
end

function updateKeys()
	for k,v in pairs(CONTROL_KEYS_DOWN) do
		if v[1] == "down" then
			v[1] = "held"
		elseif v[1] == "up" then
			CONTROL_KEYS_DOWN[k] = nil
		end
	end

	for i,v in pairs(CONTROL_LOCK) do
		v[2] = v[3]
	end
end

function clearKeys()
	CONTROL_KEYS_DOWN = {}
end

-- prematurely stop a key input
function silenceKey(scancode)
	CONTROL_KEYS_DOWN[scancode] = nil
end

-- the Love2D input callback functions, they are called in main.lua
function __keypressed(key, scancode, isrepeat)
	KEY_PRESS(key,scancode,isrepeat)
end
function __mousepressed(x, y, button, istouch, presses)
	local m = "mouse" .. tostring(button)
	KEY_PRESS(m, m, false)
end
function __keyreleased(key, scancode)
	KEY_RELEASE(key,scancode,isrepeat)
end
function __mousereleased(x, y, button, istouch, presses)
	local m = "mouse" .. tostring(button)
	KEY_RELEASE(m, m, false)
end
function __wheelmoved(x,y)
	if y > 0 then
		KEY_UP("wheelup","wheelup")
	else
		KEY_UP("wheeldown","wheeldown")
	end
end


-- Query functions
-- QueryScancode and QueryKeybind return 3 values
-- first value is either nil,"down","held" or "up"
-- second value is time held in ticks or nil
-- third value is time held in seconds or nil
function queryScancode(scancode, level)
	local level = level or CTRL.GAME
	-- block query if disabled lock
	if not level() then
		return nil,nil,nil
	end

	local k = CONTROL_KEYS_DOWN[scancode]
	if k then
		return k[1], k[2]:Time(), k[3]:Time()
	end
end

function queryKeybind(setting, level)
	local level = level or CTRL.GAME
	local scancode1, scancode2 = keySetting( setting )
	if scancode1 or scancode2 then
		local status1, ticktime1, realtime1 = queryScancode(scancode1, level)
		local status2, ticktime2, realtime2 = queryScancode(scancode2, level)

		if status1 and not status2 then
			return status1, ticktime1, realtime1
		elseif status2 and not status1 then
			return status2, ticktime2, realtime2
		elseif status1 and status2 then

			-- if both keys for a keybind are pressed, we prioritise the one thats been held the longest
			-- and silence the newest one
			if ticktime1 < ticktime2 then
				silenceKey(scancode2)
				return status1, ticktime1, realtime1
			else
				silenceKey(scancode1)
				return status2, ticktime2, realtime2
			end

		else
			return nil, nil, nil
		end
	else 
		return nil,nil,nil
	end
end

function scancodeStatus(scancode, level)
	local level = level or CTRL.GAME
	return queryScancode(scancode, level)
end

function keybindStatus(setting, level)
	local level = level or CTRL.GAME
	return queryKeybind(scancode, level)
end

function scancodeIsDown(scancode, level)
	local level = level or CTRL.GAME
	local status = queryScancode(scancode, level)
	return status == "down"
end

function keybindIsDown(setting, level)
	local level = level or CTRL.GAME
	local status = queryKeybind(setting, level)
	return status == "down"
end

function scancodeIsHeld(scancode, level)
	local level = level or CTRL.GAME
	local status = queryScancode(scancode, level)
	return status == "held"
end

function keybindIsDown(setting, level)
	local level = level or CTRL.GAME
	local status = queryKeybind(setting, level)
	return status == "held"
end

function scancodeIsUp(scancode, level)
	local level = level or CTRL.GAME
	local status = queryScancode(scancode, level)
	return status == "up"
end

function keybindIsUp(setting, level)
	local level = level or CTRL.GAME
	local status = queryKeybind(setting, level)
	return status == "up"
end

function scancodeIsPressed(scancode, level)
	local level = level or CTRL.GAME
	local status = queryScancode(scancode, level)
	return status == "down" or status == "held"
end

function keybindIsPressed(setting, level)
	local level = level or CTRL.GAME
	local status = queryKeybind(setting, level)
	return status == "down" or status == "held"
end
