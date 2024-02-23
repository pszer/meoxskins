require "assetloader"

local shadersend   = require "shadersend"
local cpml         = require "cpml"

local gui         = require 'gui.gui'
local guirender   = require 'gui.guidraw'
local commands    = require 'gui.command'
local lang        = require 'gui.guilang'

local edit = {

	mode = "viewport",

	view_rotate_mode = false,
	grabbed_mouse_x = 0,
	grabbed_mouse_y = 0,

	-- table of command definitions
	commands = {},

	super_modifier = false,
	ctrl_modifier  = false,
	alt_modifier   = false,

	curr_context_menu = nil,
	curr_popup = nil,

	file_dropped_hook = nil
}
edit.__index = edit

function edit:load(args)
	SET_ACTIVE_KEYBINDS(EDIT_KEY_SETTINGS)
	CONTROL_LOCK.EDIT_VIEW.open()

	self:loadConfig()

	self:setupInputHandling()
	self:defineCommands()
	gui:init(self)
end

function edit:quit()
	self:saveConfig()
end

function edit:loadConfig(conf_fpath)
	local fpath = conf_fpath or "editcfg.lua"

	local file = love.filesystem.newFile(fpath)
	if not file then return end

	local conf_str = file:read()
	local status, conf = pcall(function() return loadstring(conf_str)() end)
	if status and conf then
		local lang_setting = conf.lang_setting
		lang:setLanguage(lang_setting)
	end
	file:close()
end

function edit:saveConfig(conf_fpath)
	local fpath = conf_fpath or "editcfg.lua"

	local file = love.filesystem.newFile(fpath)
	if not file then return end

	local status, err = file:open("w")
	if not status then
		print(err)
		return
	end

	local conf_table = {
		lang_setting = lang.__curr_lang
	}
	local serialise = require 'serialise'
	local str = "return "..serialise(conf_table)
	file:write(str)
	file:close()
end

function edit:defineCommands()
	coms = self.commands

	coms["invertible_select"] = commands:define(
		{
		 {"select_objects", "table", nil, PropDefaultTable{}},
		},
		function(props) -- command function
			self.selection_changed = true
			local mapedit = self
			local active_selection = mapedit.active_selection
			local skip = {}

			-- first we inverse the selection if already selected
			for i,v in ipairs(props.select_objects) do
				for j,u in ipairs(active_selection) do
					if v[2] == u[2] then
						skip[i] = true
						table.remove(active_selection, j)
						self:highlightObject(v,0.0)
						break
					end
				end
			end

			for i,v in ipairs(props.select_objects) do
				if not skip[i] then
					local unique = true
					for j,u in ipairs(active_selection) do
						if v[2] == u[2] then
							unique = false
							break
						end
					end

					if unique then
						table.insert(active_selection, v)
						self:highlightObject(v,1.0)
					end
				end
			end
		end, -- command function

		function(props) -- undo command function
			self.selection_changed = true
			local mapedit = self
			local active_selection = mapedit.active_selection
			local skip = {}

			-- invert any previous invert selections
			for i,v in ipairs(props.select_objects) do
				local unique = true
				for j,u in ipairs(active_selection) do
					if v == u then
						unique = false
						break
					end
				end

				if unique then
					skip[i] = true
					table.insert(active_selection, v)
					self:highlightObject(v,1.0)
				end
			end

			for i,v in ipairs(props.select_objects) do
				if not skip[i] then
					for j,u in ipairs(active_selection) do
						if v == u then
							table.remove(active_selection, j)
							self:highlightObject(v,0.0)
							break
						end
					end
				end
			end -- undo command function
		end) 

end

function edit:commitCommand(command_name, props)
	local command_table = self.commands
	local command_definition = command_table[command_name]
	assert(command_definition, string.format("No command %s defined", tostring(command_name)))
	local command = command_definition:new(props)
	assert(command)

	local pointer = self.props.mapedit_command_pointer
	local command_history = self.props.mapedit_command_stack
	local history_length = #command_history
	-- if the command pointer isn'at the top of the stack (i.e. there have been undo operations)
	-- we prune any commands after it
	local pruned=false
	for i=pointer+1,history_length do
		pruned=true
		command_history[i] = nil
	end
	if pruned then collectgarbage("step",5000) end

	table.insert(command_history, command)

	-- add the new command to the stack, shifting it down if maximum limit of
	-- remembered commands is reached
	history_length = #command_history
	if history_length > self.props.mapedit_command_stack_max then
		for i=1,history_length-1 do
			command_history[i] = command_history[i+1]
		end
		command_history[history_length] = nil
		self.props.mapedit_command_pointer = history_length
	else
		self.props.mapedit_command_pointer = history_length
	end

	command:commit()
end

function edit:pushCommand(command)
	local pointer = self.props.mapedit_command_pointer
	local command_history = self.props.mapedit_command_stack
	local history_length = #command_history
	-- if the command pointer isn'at the top of the stack (i.e. there have been undo operations)
	-- we prune any commands after it
	local pruned=false
	for i=pointer+1,history_length do
		pruned=true
		command_history[i] = nil
	end
	if pruned then collectgarbage("step",5000) end

	table.insert(command_history, command)

	-- add the new command to the stack, shifting it down if maximum limit of
	-- remembered commands is reached
	history_length = #command_history
	if history_length > self.props.mapedit_command_stack_max then
		for i=1,history_length-1 do
			command_history[i] = command_history[i+1]
		end
		command_history[history_length] = nil
		self.props.mapedit_command_pointer = history_length
	else
		self.props.mapedit_command_pointer = history_length
	end

	command:commit()
end

function edit:commitComposedCommand(...)
	local com_args = {...}
	local coms = {}

	local command_table = self.commands
	for i,v in ipairs(com_args) do
		local command_definition = command_table[v[1]]
		assert(command_definition, string.format("No command %s defined", tostring(v[1])))
		local command = command_definition:new(v[2])
		coms[i] = command
	end

	local composed = commands:compose(coms)
	self:pushCommand(composed)
end

function edit:commitUndo()
	local pointer = self.props.mapedit_command_pointer
	local command_history = self.props.mapedit_command_stack

	if pointer == 0 then return end
	local command = command_history[pointer]
	command:undo()
	self.props.mapedit_command_pointer = self.props.mapedit_command_pointer - 1
end

function edit:commitRedo()
	local pointer = self.props.mapedit_command_pointer
	local command_history = self.props.mapedit_command_stack
	local history_length = #command_history

	if pointer == history_length then return end
	local command = command_history[pointer+1]
	command:commit()
	self.props.mapedit_command_pointer = self.props.mapedit_command_pointer + 1
end

function edit:canUndo()
	return self.props.mapedit_command_pointer > 0
end
function edit:canRedo()
	return self.props.mapedit_command_pointer ~= #(self.props.mapedit_command_stack)
end

function edit:setupInputHandling()
	--
	-- CONTEXT MENU MODE INPUTS
	--
	--[[self.cxtm_input = InputHandler:new(CONTROL_LOCK.MAPEDIT_CONTEXT,
	                                   {"cxtm_select","cxtm_scroll_up","cxtm_scroll_down"})

	local cxtm_select_option = Hook:new(function ()
		local cxtm = gui.curr_context_menu
		if not cxtm then
			gui:exitContextMenu()
			return end
		local hovered_opt = cxtm:getCurrentlyHoveredOption()
		if not hovered_opt then
			gui:exitContextMenu()
			return end
		local action = hovered_opt.action
		if action then action() end
		gui:exitContextMenu()
	end)
	self.cxtm_input:getEvent("cxtm_select", "down"):addHook(cxtm_select_option)
	--]]

	--
	-- VIEWPORT MODE INPUTS
	--
	self.viewport_input = InputHandler:new(CONTROL_LOCK.EDIT_VIEW,
	                    {"cam_zoom_out","cam_zoom_in","cam_rotate",
											 "edit_undo","edit_redo","edit_action",
										   {"ctrl",CONTROL_LOCK.META},{"alt",CONTROL_LOCK.META},{"super",CONTROL_LOCK.META}})

	-- hooks for camera rotation
	local viewport_rotate_start = Hook:new(function ()
		self.view_rotate_mode = true
		self:captureMouse()
		self.viewport_input:lockInverse{"cam_rotate"}
		CONTROL_LOCK.EDIT_VIEW.elevate()
	end)
	local viewport_rotate_finish = Hook:new(function ()
		self.view_rotate_mode = false
		self:releaseMouse()
		self.viewport_input:unlockAll()
		CONTROL_LOCK.EDIT_VIEW.open()
	end)
	local viewport_zoom_in = Hook:new(function ()
		print("hey")
		local cam = require 'camera'
		cam.pos[1] = cam.pos[1] * 0.95
		cam.pos[2] = cam.pos[2] * 0.95
		cam.pos[3] = cam.pos[3] * 0.95
		end)
	local viewport_zoom_out = Hook:new(function ()
		local cam = require 'camera'
		cam.pos[1] = cam.pos[1] * 1.05
		cam.pos[2] = cam.pos[2] * 1.05
		cam.pos[3] = cam.pos[3] * 1.05
		end)

	self.viewport_input:getEvent("cam_rotate","down"):addHook(viewport_rotate_start)
	self.viewport_input:getEvent("cam_rotate","up"):addHook(viewport_rotate_finish)
	self.viewport_input:getEvent("cam_zoom_in","up"):addHook(viewport_zoom_in)
	self.viewport_input:getEvent("cam_zoom_out","up"):addHook(viewport_zoom_out)

	local additive_select_obj = nil

	local viewport_undo = Hook:new(function ()
		if self.ctrl_modifier then self:commitUndo() end end)
	local viewport_redo = Hook:new(function ()
		if self.ctrl_modifer then self:commitRedo() end end)

	local enable_super_hook = Hook:new(function () self.super_modifier = true end)
	local disable_super_hook = Hook:new(function () self.super_modifier = false end)

	local enable_ctrl_hook = Hook:new(function () self.ctrl_modifier = true end)
	local disable_ctrl_hook = Hook:new(function () self.ctrl_modifier = false end)

	local enable_alt_hook = Hook:new(function () self.alt_modifier = true end)
	local disable_alt_hook = Hook:new(function () self.alt_modifier = false end)

	self.viewport_input:getEvent("edit_undo","down"):addHook(viewport_undo)
	self.viewport_input:getEvent("edit_redo","down"):addHook(viewport_redo)
	self.viewport_input:getEvent("super", "down"):addHook(enable_super_hook)
	self.viewport_input:getEvent("super", "up"):addHook(disable_super_hook)
	self.viewport_input:getEvent("ctrl", "down"):addHook(enable_ctrl_hook)
	self.viewport_input:getEvent("ctrl", "up"):addHook(disable_ctrl_hook)
	self.viewport_input:getEvent("alt", "down"):addHook(enable_alt_hook)
	self.viewport_input:getEvent("alt", "up"):addHook(disable_alt_hook)
end

local grabbed_mouse_x=0
local grabbed_mouse_y=0
function edit:captureMouse()
	love.mouse.setRelativeMode( true )
	grabbed_mouse_x = love.mouse.getX()
	grabbed_mouse_y = love.mouse.getY()
end
function edit:releaseMouse()
	love.mouse.setRelativeMode( false )
	love.mouse.setX(grabbed_mouse_x)
	love.mouse.setY(grabbed_mouse_y)
end

function edit:getCurrentMode()
	return self.props.mapedit_mode
end

function edit:openSelectionContextMenu()
	local cxtm_name, props = self:getSelectionContextMenu()
	if cxtm_name then
		gui:openContextMenu(cxtm_name, props)
	end
end

local _mdx,_mdy = 0,0
require "angle"
function edit:rotateCamMode(mdx,mdy)
	if not self.view_rotate_mode then return end

	-- get new camera direction
	local cam = require 'camera'
	local dir = cam.pos
	local scale = 0.05
	local cos,sin = math.cos, math.sin
	local angle = atan3(dir[1], dir[3])

	local newdir = {}
	newdir[1] = dir[1] - (cos(angle)*mdx)*scale
	newdir[2] = dir[2] - mdy*scale
	newdir[3] = dir[3] - (-sin(angle)*mdx)*scale

	local length = math.sqrt(dir[1]*dir[1] + dir[2]*dir[2] + dir[3]*dir[3]) 

	local length2 = math.sqrt(newdir[1]*newdir[1] + newdir[2]*newdir[2] + newdir[3]*newdir[3]) 

	cam:setPos(length*newdir[1]/length2,length*newdir[2]/length2,length*newdir[3]/length2)
end

function edit:update(dt)
	gui:update(dt)
	self.viewport_input:poll()
end

function edit:draw()
	love.graphics.reset()
	love.graphics.origin()
	love.graphics.setShader()
	love.graphics.setColor(1,1,1,1)
	love.graphics.setMeshCullMode("none")
	love.graphics.setDepthMode()
	love.graphics.setBlendMode("alpha")
	gui:draw()
end

local __tempdir = {}
local lastx, lasty=0,0
function edit:mousemoved(x,y, dx,dy)
	if self.view_rotate_mode then
		self:rotateCamMode(dx or 0,dy or 0)
	end
end

function edit:viewport_mousemoved(x,y,dx,dy)
end

function edit:transform_mousemoved(x,y,dx,dy)
end

function edit:resize(w,h)
	gui:exitContextMenu()
end

function edit:setFileDropHook(hook_func)
	self.file_dropped_hook = hook_func
end

function edit:filedropped(file)
	local hook = self.file_dropped_hook
	if hook then
		hook(file)
	end
end

function edit:keypressed(key,scancode,isrepeat)
	gui:keypressed(key,scancode,isrepeat)
end

function edit:textinput(t)
	gui:textinput(t)
end

return edit
