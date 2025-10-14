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

local fileio = require 'fileio'

local filter = require 'filter'
local fw = require 'filterworker'
local filter_worker = fw

local histogram  = require 'histogram'
local cubiccurve = require 'cubiccurve'

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

	mirror_mode = false,

	curr_context_menu = nil,
	curr_popup = nil,

	file_dropped_hook = nil,

	active_layer = nil,
	active_mode  = "wide",

	working_filename = nil,

	command_stack = {},
	command_pointer = 0,
	command_stack_max = 128,

	autosave_timer = 0,
	autosave_disable = false,

	render_grid = true,

	lock_edit = false,

	alpha_lock_override = false,

	bg_col = {78/255, 138/255, 126/255}
}
edit.__index = edit

function edit:init()
	SET_ACTIVE_KEYBINDS(EDIT_KEY_SETTINGS)
	CONTROL_LOCK.EDIT_VIEW.open()

	self:loadConfig()

	self:setupInputHandling()
	self:defineCommands()
	gui:init(self)
end

function edit:checkAutosaveRecover()
	local state = self:checkSessionFile()
	if state ~= "exit" then
		local autosave = require "cfg.autosave"
		local test_file = love.filesystem.newFile(autosave.autosave_file)
		if not test_file then test_file:close() return end

		self.active_mode = state
		if not (self.active_mode=="wide" or self.active_mode=="slim") then
			self.active_mode = "wide" end

		local guilayout       = require 'gui.layout'
		local guiwindow       = require 'gui.window'
		local guitextbox      = require 'gui.textelement'
		local guibutton       = require 'gui.button'
		local region_offset_f = function(_x,_y) return function(l) return l.x+l.w*_x, l.y+l.h*_y, l.w, l.h end end

		local recover_win = guiwindow:define({
			 win_min_w=330,
			 win_max_w=330,
			 win_min_h=50,
 			 win_max_h=50,
	 		 win_focus=true,
			},
			guilayout:define(
				{id="region",
				 split_type=nil},
				{"region", region_offset_f(0.5,0.10)},
				{"region", region_offset_f(0.4,0.5)},
				{"region", region_offset_f(0.6,0.5)}
			)
		)

		edit.autosave_disable = true
		local win =
			recover_win:new({},{
				guitextbox:new(lang["Recover autosaved project?"],0,0,330,"left","middle"),
				guibutton:new(lang["~(green)~bYes"],nil,0,0,
					function(self,win)
						edit.autosave_disable = false
						edit:recoverAutosave()
						win:delete()
					end,
					"middle","top"),
				guibutton:new(lang["No"],nil,0,0,
					function(self,win)
						edit.autosave_disable = false
						win:delete()
					end,
					"middle","top")}
			,0,0,150,50)
		win:centre(0.5,0.5)
		gui:handleTopLevelThrownObject(win)
	end
end

function edit:load(args)
	local skin_name = args.skin_name
	local skin_mode = args.skin_mode or "wide" -- slim or wide parameter
	local skin_data = args.skin_data

	local texture
	if not skin_name then
		texture = skin_data or love.graphics.newCanvas(64,64)
	else
		local data = fileio:dataFromFile(skin_name)
		texture = love.graphics.newImage(data)
		self.working_filename = file

		local w,h = texture:getDimensions()

		if h ~= 64 or w%64 ~= 0 then
			errstr = ""
			if h ~= 64 then errstr = lang["Height is not 64"] end
			if w%64 ~= 0 then
				if errstr ~= "" then errstr = errstr .. ", " end
				errstr = errstr .. lang["Width not a multiple of 64"]
			end
			gui:displayPopup(lang["Unable to load file."] .. " " .. errstr,5.0)	
			texture = love.graphics.newCanvas(64,64)
			self.working_filename = file .. ".png"
		end
	end

	--skin:load(texture)
	skin:loadProject(texture)
	self.active_mode = skin_mode
	self.active_layer = skin.layers[1]
	model:setupVisibility(skin_mode)

	self:init()
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

function edit:swapSkinMode()
	if self.active_mode == "slim" then
		self.active_mode = "wide"
	else
		self.active_mode = "slim"
	end
end

function edit:defineCommands()
	coms = self.commands

	coms["swap_mode"] = commands:define(
		{
		},
		function(props) -- command function
			self:swapSkinMode()
			model:setupVisibility(self.active_mode)
		end, -- command function

		function(props) -- undo command function
			self:swapSkinMode()
			model:setupVisibility(self.active_mode)
		end)

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

		--[[
	coms["commit_pose"] = commands:define(
		{
		 {"old_pose", nil, nil, nil},
		 {"new_pose", nil, nil, nil}, -- { ["limb"] = {rot=rot,pos=pos,mat=mat} , ... }
		},
		function(props) -- command function
			local model_mats = model.model_mats
			for limb,v in pairs(model_mats) do
				props.old_pose[limb] = {rot=v.rot,pos=v.pos,mat=v.mat}
			end
		end, -- command function

		function(props) -- undo command function
		end)]]--

	coms["merge_layer"] = commands:define(
		{
		 {"base_layer", nil, nil, nil},
		 {"top_layer" , nil, nil, nil},
		 {"top_layer_index", nil, nil, nil},
		 {"old_texture", nil, nil, nil},
		 {"new_texture", nil, nil, nil},
		},
		function(props) -- command function
			if not props.old_texture then
				props.old_texture = props.base_layer.texture end
			if not props.new_texture then
				props.new_texture = props.top_layer.merge_result(props.base_layer) end

			props.base_layer.texture = props.new_texture
			props.base_layer.preview = nil
			skin:removeLayer(props.top_layer)
		end, -- command function

		function(props) -- undo command function
			props.base_layer.texture = props.old_texture
			props.base_layer.preview = nil
			skin:insertLayer(props.top_layer, props.top_layer_index)
		end)

	coms["add_layer"] = commands:define(
		{
		 {"layer", nil, nil, nil},
		},
		function(props) -- command function
			skin:insertLayer(props.layer)
			edit.active_layer = props.layer
		end, -- command function

		function(props) -- undo command function
			skin:removeLayer(props.layer)
			edit.active_layer = nil
		end) 

	coms["delete_layer"] = commands:define(
		{
		 {"layer", nil, nil, nil},
		 {"index", nil, nil, nil},
		},
		function(props) -- command function
			props.layer,props.index = skin:removeLayer(props.layer)
			edit.active_layer = nil
		end, -- command function

		function(props) -- undo command function
			skin:insertLayer(props.layer, props.index)
			edit.active_layer = props.layer
		end)

	coms["swap_layers"] = commands:define(
		{
			{"index1", nil, nil, nil},
			{"index2", nil, nil, nil},
		},
		function(props)
			skin:swapLayers(props.index1,props.index2)
		end,
		function(props)
			skin:swapLayers(props.index1,props.index2)
		end
	)

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
		self.command_pointer = history_length-1
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
	if self.lock_edit then gui:displayPopup(lang["Can't do this right now"], 2.5) return end

	local pointer = self.command_pointer
	local command_history = self.command_stack

	if pointer == 0 then return end
	local command = command_history[pointer]
	command:undo()
	self.command_pointer = self.command_pointer - 1
end

function edit:commitRedo()
	if self.lock_edit then gui:displayPopup(lang["Can't do this right now"], 2.5) return end

	local pointer = self.command_pointer
	local command_history = self.command_stack
	local history_length = #command_history

	if pointer == history_length then return end
	local command = command_history[pointer+1]
	command:commit()
	self.command_pointer = self.command_pointer + 1
end

function edit:canUndo()
	return self.command_pointer > 0
end
function edit:canRedo()
	return self.command_pointer ~= #(self.command_stack)
end

function edit:setActiveLayer(layer)
	self.active_layer = layer
end

function edit:getActiveLayer(layer)
	return self.active_layer
end

function edit:mergeLayerDown(layer)
	if self.lock_edit then gui:displayPopup(lang["Can't do this right now"], 2.5) return end

	layer = layer or self:getActiveLayer()
	if not layer then return end

	local base_i, top_i
	for i,l in ipairs(skin.layers) do
		if l==layer then base_i=i break end
	end

	if not base_i then return end
	top_i = base_i+1
	if not skin.layers[top_i] then return end

	self:commitCommand("merge_layer", {base_layer=skin.layers[base_i], top_layer=skin.layers[top_i], top_layer_index=top_i})
end

function edit:setupInputHandling()
	--
	-- VIEWPORT MODE INPUTS
	--
	self.viewport_input = InputHandler:new(CONTROL_LOCK.EDIT_VIEW,
	                    {"cam_zoom_out","cam_zoom_in","cam_rotate",
											 "edit_undo","edit_redo","edit_action","edit_colour_pick","edit_colour_fill",
											 "edit_erase","edit_mirror","edit_grid","edit_alpha_override","edit_hide_overlay",
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

	local hideoverlaytoggle = false
	local hide_overylay_hook = Hook:new(function ()
		model:hideOverlayShortcut(not hideoverlaytoggle)
		hideoverlaytoggle = not hideoverlaytoggle
	end)
	self.viewport_input:getEvent("edit_hide_overlay","down"):addHook(hide_overylay_hook)

	local paint_history = nil
	local paint_layer = nil
	local paint_target = nil
	local paint_action_start = Hook:new(function ()
		if self.lock_edit or filter_worker:is_active() then gui:displayPopup(lang["Can't do this right now"], 2.5) return end
		if filter_worker:is_active() then return end

		if erase_history then return end
		if not self.active_layer then return end
		if not self.active_layer.visible then return end
		if not self:pixelAtCursor()	then return end

		paint_history = {}

		local layer = self:getActiveLayer()
		paint_layer = layer
		paint_target = layer.open_preview()
	end)
	local paint_action_held = Hook:new(function ()
		if not paint_history then return end

		local X,Y = self:pixelAtCursor()

		if X then
			-- avoid painting over the same pixel twice
			if paint_history and paint_history[X] and paint_history[X][Y] and not self.alpha_lock_override then return end
			if not paint_history[X] then paint_history[X] = {} end
			paint_history[X][Y] = true

			local col = gui.colour_picker:getColour()
			local alpha_lock = self.active_layer.alpha_lock
			if self.alpha_lock_override then alpha_lock = false end
			paint:drawPixel{target = paint_target, pixel={X,Y}, colour=col, mirror=self.mirror_mode, alphalock = alpha_lock}
		end
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

	local override_alpha = Hook:new(function ()
		self.alpha_lock_override = true
	end)
	local override_alpha_off = Hook:new(function ()
		self.alpha_lock_override = false
	end)
	self.viewport_input:getEvent("edit_alpha_override","down"):addHook(override_alpha)
	self.viewport_input:getEvent("edit_alpha_override","held"):addHook(override_alpha)
	self.viewport_input:getEvent("edit_alpha_override","up"):addHook(override_alpha_off)

	local erase_history = nil
	local erase_layer = nil
	local erase_target = nil
	local erase_action_start = Hook:new(function ()
		if paint_history then return end
		if not self.active_layer then return end
		if not self.active_layer.visible then return end
		if not self:pixelAtCursor()	then return end

		erase_history = {}

		local layer = self:getActiveLayer()
		erase_layer = layer
		erase_target = layer.open_preview()
	end)
	local erase_action_held = Hook:new(function ()
		if not erase_history then return end
		local X,Y = self:pixelAtCursor()

		if X then
			-- avoid eraseing over the same pixel twice
			if erase_history and erase_history[X] and erase_history[X][Y] then return end
			if not erase_history[X] then erase_history[X] = {} end
			erase_history[X][Y] = true

			paint:erasePixel{target = erase_target, pixel={X,Y}, mirror=self.mirror_mode}
		end
	end)
	local erase_action_end = Hook:new(function ()
		if erase_layer then
			local old,new = erase_layer.commit_preview()

			self:commitCommand("commit_paint", {layer=erase_layer,old_texture=old,new_texture=new,mirror=self.mirror_mode})
		end

		erase_history = nil
		erase_layer = nil
		erase_target = nil
	end)

	self.viewport_input:getEvent("edit_erase","down"):addHook(erase_action_start)
	self.viewport_input:getEvent("edit_erase","held"):addHook(erase_action_held)
	self.viewport_input:getEvent("edit_erase","up"):addHook(erase_action_end)

	local paint_fill = Hook:new(function ()
		local layer = self:getActiveLayer()
		if not self.active_layer then return end
		if not self.active_layer.visible then return end
		local x,y,dist,mesh,index = self:pixelAtCursor()

		if not mesh then return end

		local target = layer.open_preview()
		local col = gui.colour_picker:getColour()
		paint:fillFace{target=target,colour=col,index=index,mesh=mesh}
		local old,new = layer.commit_preview()
		self:commitCommand("commit_paint", {layer=layer,old_texture=old,new_texture=new})
	end)
	self.viewport_input:getEvent("edit_colour_fill","down"):addHook(paint_fill)

	local colour_pick = Hook:new(function ()
		local pixels = self:pixelAtCursor(true)
		local colour = skin:pickColour(pixels)
		if colour then
			gui.colour_picker:setRGBColour(colour[1]*255,colour[2]*255,colour[3]*255)
		end
	end)
	self.viewport_input:getEvent("edit_colour_pick","down"):addHook(colour_pick)

	local mirror_action = Hook:new(function () self.mirror_mode = not self.mirror_mode end)
	self.viewport_input:getEvent("edit_mirror","down"):addHook(mirror_action)

	local grid_toggle = Hook:new(function ()
		self.render_grid = not self.render_grid
	end)
	self.viewport_input:getEvent("edit_grid","down"):addHook(grid_toggle)
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
	local min_mesh = nil
	local min_index = nil
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
				table.insert(pixels, {X,Y,dist,mesh,i})
			elseif dist and dist < min_dist then
				min_dist = dist
				min_pos = pos
				min_mesh = mesh
				min_index = i
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

		return X,Y,min_dist,min_mesh,min_index
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

function edit:update_filter_worker()
	if fw.active_worker then
		fw.active_worker:preview()
		self:lockEdit()
	end

	if not fw:is_commit() then return end

	local layer, oldt, newt = fw.active_worker:state()
	self:commitCommand("commit_paint", {layer=layer,old_texture=oldt,new_texture=newt})
	fw:add_to_history()
	fw:discard()
	self:unlockEdit()
end

function edit:autosave(dt)
	local autosave = require 'cfg.autosave'

	if self.autosave_disable then
		self.autosave_timer = 0
		return
	end

	self.autosave_timer = self.autosave_timer + dt
	if self.autosave_timer > autosave.interval then
		local autosave_file = love.filesystem.newFile(autosave.autosave_file, "w")
		self:saveProjectToFile(autosave_file)
		autosave_file:close()

		self:updateSessionFile(self.active_mode or "wide")

		self.autosave_timer=0
	end
end

function edit:checkSessionFile()
	local autosave = require 'cfg.autosave'
	local crash_file = love.filesystem.newFile(autosave.session_file, "r")

	if not crash_file then
		self:updateSessionFile(self.active_mode or "wide")
		return self.active_mode or "wide"
	end	

	local data = crash_file:read()
	crash_file:close()
	return data
end

function edit:updateSessionFile(state)
	local autosave = require 'cfg.autosave'
	local crash_file = love.filesystem.newFile(autosave.session_file, "w")
	crash_file:write(state)
	crash_file:close()
end

function edit:recoverAutosave()
	local autosave = require 'cfg.autosave'
	edit:load{skin_data=love.graphics.newImage(autosave.autosave_file)}
end

function edit:getPreviewStatus()
	return filter_worker.preview_on
end
function edit:setPreviewStatus(s)
	filter_worker:set_preview_state(s)
end

function edit:lockEdit()
	self.lock_edit = true
end
function edit:unlockEdit()
	self.lock_edit = false
end

function edit:setBackgroundColour(r,g,b)
	self.bg_col[1] = r
	self.bg_col[2] = g
	self.bg_col[3] = b
end

function edit:update(dt)
	gui:update(dt)
	self.viewport_input:poll()
	self:update_filter_worker()
	self:autosave(dt)
end

function edit:draw()
	render:clear3DCanvas(self.bg_col[1], self.bg_col[2], self.bg_col[3])
	render:viewportPass(render.shader3d)
	if edit.render_grid then
		render:viewportPass(render.shader3dgrid, false, true)
	end

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
	if type(filepath) == "string" then
		fileio:writeToFile(data, filepath)
	else
		filepath:write(data)
	end
end

function edit:saveProjectToFile(filepath)
	local layer_count = #skin.layers
	local raster = love.graphics.newCanvas(64*layer_count,64)
	love.graphics.reset()
	love.graphics.setCanvas(raster)
	for i,v in ipairs(skin.layers) do
		local tex = v.texture
		love.graphics.draw(tex, (i-1)*64)
	end

	love.graphics.reset()
	local image_data = raster:newImageData()
	local data = image_data:encode("png")
	if type(filepath) == "string" then
		fileio:writeToFile(data, filepath)
	else
		filepath:write(data)
	end
end

function edit:toggleGrid()
	self.render_grid = not self.render_grid
end

function edit:viewport_mousemoved(x,y,dx,dy)
end

function edit:transform_mousemoved(x,y,dx,dy)
end

function edit:resize(w,h)
	gui:exitContextMenu()
	gui:update()
	gui:resize()
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

function edit:quit()
	self:updateSessionFile("exit")
end

return edit
