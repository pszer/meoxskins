require "assetloader"

local shadersend   = require "shadersend"
local cpml         = require "cpml"
local render       = require "render"

local gui         = require 'gui.gui'
local guirender   = require 'gui.guidraw'
local commands    = require 'gui.command'
local lang        = require 'gui.guilang'

local model = require 'model'
local skin = require 'skin'
local paint = require 'paint'

local paint = require 'paint'

local fileio = require 'fileio'

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

	file_dropped_hook = nil,

	active_layer = nil,
	active_mode  = "wide",

	working_filename = nil,

	command_stack = {},
	command_pointer = 0,
	command_stack_max = 128,
}
edit.__index = edit

function edit:load(args)
	local skin_name = args.skin_name
	local skin_mode = args.skin_mode or "wide" -- slim or wide parameter

	print("skin_mode",skin_mode)

	local texture
	if not skin_name then
		texture = love.graphics.newCanvas(64,64)
	else
		local data = fileio:dataFromFile(skin_name)
		texture = love.graphics.newImage(data)

		self.working_filename = file
	end

	skin:load(texture)
	self.active_mode = skin_mode
	self.active_layer = skin.layers[1]
	model:setupVisibility(skin_mode)

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

	coms["commit_paint"] = commands:define(
		{
		 {"layer", nil, nil, nil},
		 {"old_texture", nil, nil, nil},
		 {"new_texture", nil, nil, nil},
		},
		function(props) -- command function
			props.layer.texture = props.new_texture
			props.layer.preview = nil
		end, -- command function

		function(props) -- undo command function
			props.layer.texture = props.old_texture
			props.layer.preview = nil
		end) 

end

function edit:commitCommand(command_name, props)
	local command_table = self.commands
	local command_definition = command_table[command_name]
	assert(command_definition, string.format("No command %s defined", tostring(command_name)))
	local command = command_definition:new(props)
	assert(command)

	local pointer = self.command_pointer
	local command_history = self.command_stack
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
	if history_length > self.command_stack_max then
		for i=1,history_length-1 do
			command_history[i] = command_history[i+1]
		end
		command_history[history_length] = nil
		self.command_pointer = history_length
	else
		self.command_pointer = history_length
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
	local pointer = self.command_pointer
	local command_history = self.command_stack

	if pointer == 0 then return end
	local command = command_history[pointer]
	command:undo()
	self.command_pointer = self.command_pointer - 1
end

function edit:commitRedo()
	local pointer = self.command_pointer
	local command_history = self.command_stack
	local history_length = #command_history

	if pointer == history_length then return end
	local command = command_history[pointer+1]
	command:commit()
	self.command_pointer = self.command_pointer + 1
end

function edit:canUndo()
	return self.props.mapedit_command_pointer > 0
end
function edit:canRedo()
	return self.props.mapedit_command_pointer ~= #(self.props.mapedit_command_stack)
end

function edit:setActiveLayer(layer)
	self.active_layer = layer
end

function edit:getActiveLayer(layer)
	return self.active_layer
end

function edit:setupInputHandling()
	--
	-- VIEWPORT MODE INPUTS
	--
	self.viewport_input = InputHandler:new(CONTROL_LOCK.EDIT_VIEW,
	                    {"cam_zoom_out","cam_zoom_in","cam_rotate",
											 "edit_undo","edit_redo","edit_action","edit_colour_pick",
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
		if self.ctrl_modifier then self:commitRedo() end end)

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

	local paint_history = nil
	local paint_layer = nil
	local paint_target = nil
	local paint_action_start = Hook:new(function ()
		if not self.active_layer then return end
		if not self:pixelAtCursor()	then return end

		paint_history = {}

		local layer = self:getActiveLayer()
		paint_layer = layer
		paint_target = layer.open_preview()
	end)
	local paint_action_held = Hook:new(function ()
		if not paint_history then return end

		--local X,Y = self:pixelAtCursor()	
		--		local col = gui.colour_picker:getColour()
		--local target = skin.layers[1].texture
		--paint:drawPixel{target = target, pixel = {X,Y}, colour=col}
		local X,Y = self:pixelAtCursor()

		-- avoid painting over the same pixel twice
		if paint_history and paint_history[X] and paint_history[X][Y] then return end
		if not paint_history[X] then paint_history[X] = {} end
		paint_history[X][Y] = true

		local col = gui.colour_picker:getColour()
		paint:drawPixel{target = paint_target, pixel={X,Y}, colour=col}
	end)
	local paint_action_end = Hook:new(function ()
		if paint_layer then
			local old,new = paint_layer.commit_preview()

			self:commitCommand("commit_paint", {layer=paint_layer,old_texture=old,new_texture=new})
		end

		paint_history = nil
		paint_layer = nil
		paint_target = nil
	end)

	self.viewport_input:getEvent("edit_action","down"):addHook(paint_action_start)
	self.viewport_input:getEvent("edit_action","held"):addHook(paint_action_held)
	self.viewport_input:getEvent("edit_action","up"):addHook(paint_action_end)

	local colour_pick = Hook:new(function ()
		local pixels = self:pixelAtCursor(true)
		local colour = skin:pickColour(pixels)
		if colour then
			gui.colour_picker:setRGBColour(colour[1]*255,colour[2]*255,colour[3]*255)
		end
	end)
	self.viewport_input:getEvent("edit_colour_pick","down"):addHook(colour_pick)
end

function edit:pixelAtCursor(get_all_pixels)

	local unproject = cpml.mat4.unproject

	local cam = require 'camera'
	local viewproj = cam.proj_m * cam.rotview_m
	local vw,vh = love.window.getMode()
	local viewport_xywh = {0,0,vw,vh}

	local x,y = love.mouse.getPosition()
	local cursor_v = cpml.vec3.new(x,y,1.0)
	local cursor_v2 = cpml.vec3.new(x,y,0)
	local cam_pos = cpml.vec3.new(cam.pos)
	local unproject_v = unproject(cursor_v, viewproj, viewport_xywh)
	local unproject_v2 = unproject(cursor_v2, viewproj, viewport_xywh)
	local ray = {position=unproject_v2, direction=cpml.vec3.normalize(unproject_v - unproject_v2)}

	local min_dist = 1/0
	local min_pos = nil
	local A,B,C
	local A_uv,B_uv,C_uv
	local visible = model.visible

	local pixels = {}

	local function Barycentric(p, a, b, c)
		local u,v,w
		local Dot = cpml.vec3.dot

		v0 = b - a
		v1 = c - a
		v2 = p - a

		d00 = Dot(v0, v0)
		d01 = Dot(v0, v1)
		d11 = Dot(v1, v1)
		d20 = Dot(v2, v0)
		d21 = Dot(v2, v1)
		denom = d00 * d11 - d01 * d01
		v = (d11 * d20 - d01 * d21) / denom
		w = (d00 * d21 - d01 * d20) / denom
		u = 1.0 - v - w
		return u,v,w
	end

	for _,v in ipairs(model:getVisibleParts()) do
		local mesh = v.mesh
		local mat  = v.mat

		local start_vi,end_vi = 1,mesh:getVertexCount()

		for i=start_vi,end_vi-1,3 do
			local V1 = {mesh:getVertex(i+0)}
			local V2 = {mesh:getVertex(i+1)}
			local V3 = {mesh:getVertex(i+2)}

			local V1t = {V1[1],V1[2],V1[3],1.0}
			local V2t = {V2[1],V2[2],V2[3],1.0}
			local V3t = {V3[1],V3[2],V3[3],1.0}

			cpml.mat4.mul_vec4(V1t, mat, V1t)
			cpml.mat4.mul_vec4(V2t, mat, V2t)
			cpml.mat4.mul_vec4(V3t, mat, V3t)

			local __v1 = cpml.vec3.new()
			local __v2 = cpml.vec3.new()
			local __v3 = cpml.vec3.new()

			__v1.x,__v1.y,__v1.z = V1t[1],V1t[2],V1t[3]
			__v2.x,__v2.y,__v2.z = V2t[1],V2t[2],V2t[3]
			__v3.x,__v3.y,__v3.z = V3t[1],V3t[2],V3t[3]

			local ray_triangle = cpml.intersect.ray_triangle

			local pos,dist = ray_triangle(ray, {__v1,__v2,__v3}, false)

			if dist and get_all_pixels then
				A,B,C = __v1,__v2,__v3
				A_uv = {V1[4],V1[5]}
				B_uv = {V2[4],V2[5]}
				C_uv = {V3[4],V3[5]}

				local u,v,w = Barycentric(pos, A,B,C)

				local final_UV = {0,0}
				final_UV[1] = u*A_uv[1] +  v*B_uv[1] + w*C_uv[1]
				final_UV[2] = u*A_uv[2] +  v*B_uv[2] + w*C_uv[2]

				local X,Y = math.floor(final_UV[1]*64)+1, math.floor(final_UV[2]*64)+1
				table.insert(pixels, {X,Y,dist})
			elseif dist and dist < min_dist then
				min_dist = dist
				min_pos = pos
				A,B,C = __v1,__v2,__v3
				A_uv = {V1[4],V1[5]}
				B_uv = {V2[4],V2[5]}
				C_uv = {V3[4],V3[5]}
			end
		end
	end

	if min_pos and not get_all_pixels then
		local u,v,w = Barycentric(min_pos, A,B,C)

		local final_UV = {0,0}
		final_UV[1] = u*A_uv[1] +  v*B_uv[1] + w*C_uv[1]
		final_UV[2] = u*A_uv[2] +  v*B_uv[2] + w*C_uv[2]

		local X,Y = math.floor(final_UV[1]*64)+1, math.floor(final_UV[2]*64)+1

		--local col = gui.colour_picker:getColour()
		--local target = skin.layers[1].texture
		--paint:drawPixel{target = target, pixel = {X,Y}, colour=col}

		return X,Y
	elseif get_all_pixels then
		return pixels
	end

	return nil
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
	render:clear3DCanvas()
	render:viewportPass(render.shader3d)
	render:viewportPass(render.shader3dgrid)

	love.graphics.setCanvas()
	love.graphics.reset()
	love.graphics.draw(render.viewport3d)

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

function edit:saveToFile(filepath, only_visible)
	local raster = love.graphics.newCanvas(64,64)
	love.graphics.reset()
	love.graphics.setCanvas(raster)
	for i,v in ipairs(skin.layers) do
		local tex = v.texture
		local vis = v.visible

		if vis or (not vis and not only_visible) then
			love.graphics.draw(tex)
		end
	end

	love.graphics.reset()
	local image_data = raster:newImageData()
	local data = image_data:encode("png")
	fileio:writeToFile(data, filepath)
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
