local guirender       = require 'gui.guidraw'
local contextmenu     = require 'gui.context'
local toolbar         = require 'gui.toolbar'
local popup           = require 'gui.popup'
local guilayout       = require 'gui.layout'
local guiscreen       = require 'gui.screen'
local guiwindow       = require 'gui.window'
local guitextbox      = require 'gui.textelement'
local guibutton       = require 'gui.button'
local guiimage        = require 'gui.image'
local guiscrollb      = require 'gui.scrollbar'
local guiimggrid      = require 'gui.gridselection'
local guitextinput    = require 'gui.textinput'
local guicolourpicker = require 'gui.colourselect'
local guivisible      = require 'gui.visible'
local guilayers       = require 'gui.layers'
local guitickbox      = require 'gui.tickbox'
local cursor       = require 'gui.cursor'

local lang         = require 'gui.guilang'

local utf8         = require "utf8"

require "inputhandler"
require "input"

local MapEditGUI = {

	context_menus = {},
	toolbars = {},

	main_panel = nil,
	main_toolbar = nil,
	control_tooltip = nil,

	curr_context_menu = nil,
	curr_popup = nil,

	cxtm_input = nil,

	textinput_hook = nil,

	colour_picker = nil,

}
MapEditGUI.__index = MapEditGUI

function MapEditGUI:init(mapedit)
	guirender:initAssets()
	self:setupInputHandling()
	self:define(mapedit)
end

function MapEditGUI:define(mapedit)
	local context = self.context_menus
	local toolbars = self.toolbars

	local region_default_f = function(l) return l.x, l.y, l.w, l.h end
	local region_middle_f = function(l) return l.x+l.w*0.5, l.y+l.h*0.5, l.w, l.h end
	local region_offset_f = function(_x,_y) return function(l) return l.x+l.w*_x, l.y+l.h*_y, l.w, l.h end end
	local region_pixoffset_f = function(_x,_y) return function(l) return l.x+_x, l.y+_y, l.w, l.h end end
	local region_ypixoffset_f = function(_x,_y) return function(l) return l.x+l.w*_x, l.y+_y, l.w, l.h end end

	guitextinput:setup(function(i,t) return self:setTextInputHook(i,t)  end,
	                   function( i ) return self:removeTextInputHook(i) end)

	-- About window
	local about_win_layout = guilayout:define(
		{id="image_region",
		 split_type="+x",
		 split_pix=80,
		 sub=
			{id="region",
			 split_type="+y",
			 split_pix=90,
			 sub = {
				id="button_region",
				split_type=nil
			 }
			}
		},
		{"image_region", region_middle_f},
		{"region", region_pixoffset_f(-50,0)},
		{"button_region", region_middle_f}
	)
	local about_win = guiwindow:define({
		win_min_w=300,
		win_max_w=300,
		win_min_h=110,
		win_max_h=110,
		win_titlebar=true,
		win_title=lang["About"],
		win_icon="icon_about.png",
		win_show_close=false,
	}, about_win_layout)
	-- About window

	-- Picker window
	local picker_win_layout = guilayout:define(
		{id="hex_region",
		 split_type="+y",
		 split_pix=280,
		 sub=
			{id="picker_region",
		 	split_type=nil,
			},
		},
		{"hex_region", region_default_f},
		{"picker_region", region_pixoffset_f(8,4)}
	)
	local colour_win = guiwindow:define({
		win_min_w=300,
		win_max_w=300,
		win_min_h=300,
		win_max_h=300,
		win_titlebar=true,
		win_title=lang["Colour Picker"],
		win_icon="icon_hue.png",
		win_show_close=false,
		win_close=function() end
	}, picker_win_layout)
	-- Picker window
	--
	-- Curves filter window
	local curves_layout = guilayout:define(
		{id="tools_region",
		 split_type="+y",
		 split_pix=20,
		 sub=
			{id="curves_region",
			 split_type="+y",
			 split_pix=394,
			 sub=
				{id="buttons_region",
				split_type=nil,
				},
			}
		},
		{"curves_region", region_pixoffset_f(10,10)},
		{"buttons_region", region_offset_f(0.97,0.00)},
		{"buttons_region", region_offset_f(0.63,0.00)},
		{"buttons_region", region_offset_f(0.03,0.06)},
		{"buttons_region", region_offset_f(0.35,0.40)},
		{"tools_region", region_offset_f(0.07,0.40)},
		{"tools_region", region_offset_f(0.30,0.40)},
		{"tools_region", region_offset_f(0.54,0.40)},
		{"tools_region", region_offset_f(0.78,0.40)}
	)
	local curves_win = guiwindow:define({
		win_min_w=384+10,
		win_max_w=384+10,
		win_min_h=439,
		win_max_h=439,
		win_focus=false,
		win_titlebar=true,
		win_title=lang["Curves"],
		win_icon="icon_curves.png"
	}, curves_layout)
	-- Curves filter window
	--
	-- Pose window
	local pose_window_layout = guilayout:define(
		{id="box_region",
		 split_type="+x",
		 split_pix=102,
		 sub=
			{id="text_region",
			split_type="+y",
			split_pix=25,
			sub=
				{id="rot_region",
				 split_type=nil},
			}
		},
		{"rot_region", region_offset_f(0.1366+0.0000,0.000)},
		{"rot_region", region_offset_f(0.1366+0.3333,0.000)},
		{"rot_region", region_offset_f(0.1366+0.6666,0.000)},
		{"box_region", region_offset_f(0.06,0.05+0/6.0)},
		{"box_region", region_offset_f(0.06,0.05+1/6.0)},
		{"box_region", region_offset_f(0.06,0.05+2/6.0)},
		{"box_region", region_offset_f(0.06,0.05+3/6.0)},
		{"box_region", region_offset_f(0.06,0.05+4/6.0)},
		{"box_region", region_offset_f(0.6,0.05+5/6.0)},
		{"text_region",region_offset_f(0.1366+0.0000,0.300)},
		{"text_region",region_offset_f(0.1166+0.3333,0.300)},
		{"text_region",region_offset_f(0.1166+0.6666,0.300)}
	)
	local pose_win = guiwindow:define({
		win_min_w=262,
		win_max_w=262,
		win_min_h=220,
		win_max_h=220,
		win_titlebar=true,
		win_title=lang["Pose"],
		win_show_close=true
		--win_icon="icon_pose.png"
	}, pose_window_layout)
	-- Pose window
	
	-- Wide/Slim skin mode window
	local skin_mode_win_layout = guilayout:define(
		{id="text_region",
		 split_type="+y",
		 split_pix=40,
		 sub=
		 	{id="wide_region",
			 split_type="+x",
			 split_pix=75,
			 sub={
			 	id="slim_region",
				split_type=nil
			 }
			}
		},
		{"text_region", region_pixoffset_f(0,4)},
		{"wide_region", region_pixoffset_f(32.5,0)},
		{"slim_region", region_pixoffset_f(32.5,0)}
	)
	local skin_mode_win = guiwindow:define({
		win_min_w=150,
		win_max_w=150,
		win_min_h=60,
		win_max_h=60,
		win_focus=true,
	}, skin_mode_win_layout)
	-- Wide/Slim skin mode window

	-- Visible parts window
	local visible_win_layout = guilayout:define(
		{id="visible_region",
		 split_type=nil,
		},
		{"visible_region", region_pixoffset_f(10,10)}
	)
	local visible_win = guiwindow:define({
		win_min_w=160,
		win_max_w=160,
		win_min_h=180,
		win_max_h=180,
		win_titlebar=true,
		win_title=lang["Visible parts"],
		win_close=function() end,
		win_icon="icon_vis.png",
		win_show_close=false
	}, visible_win_layout)
	-- Visible parts window
	
	-- Layers window
	local layers_win_layout = guilayout:define(
		{id="layers_region",
		 split_type=nil,
		},
		{"layers_region", region_default_f}
	)
	local layers_win = guiwindow:define({
		win_min_w=280,
		win_max_w=280,
		win_min_h=350,
		win_max_h=350,
	}, layers_win_layout)
	-- Layers window

	-- Language window
	local lang_win_layout = guilayout:define(
		{id="region",
		 split_type=nil},
		{"region", region_ypixoffset_f(0.0,10)},
		{"region", region_ypixoffset_f(0.5,35)},
		{"region", region_ypixoffset_f(0.5,60)},
		{"region", region_ypixoffset_f(0.5,85)}
	)
	local lang_win = guiwindow:define({
		win_min_w=100,
		win_max_w=100,
		win_min_h=115,
		win_max_h=115,
		win_focus=true,
		win_titlebar=true,
		win_title=lang["Language"],
		win_show_close=true
	}, lang_win_layout)

	-- Key settings

	-- Rename layer window
	local rename_layer_layout = guilayout:define(
		{id="region",
		 split_type=nil},
		{"region", region_offset_f(0.5,0.10)},
		{"region", region_offset_f(0.5,0.56)},
		{"region", region_offset_f(0.37,0.75)},
		{"region", region_offset_f(0.63,0.75)}
	)
	local rename_layer_win = guiwindow:define({
		win_min_w=240,
		win_max_w=240,
		win_min_h=80,
		win_max_h=80,
		win_focus=true,
		win_titlebar=true,
		win_show_close=true,
	}, rename_layer_layout)

	local hsl_adjust_layout = guilayout:define(
		{id="panel",
		 split_type="-x",
		 split_pix=85,
		 sub =
		{id="text",
		 split_type="+y",
	 	 split_pix="25",
	 	 sub = {
		  id="bars",
			split_type="+y",
			split_pix="256",
			sub = {
		   id="input",
			 split_type=nil
			}
		 }}},
		{"text", region_offset_f(0.00000-0.025,0.2)},
		{"text", region_offset_f(0.33333-0.025,0.2)},
		{"text", region_offset_f(0.66666-0.025,0.2)},
		{"bars", region_offset_f(-0.1666+0.3333-0.04,0)},
		{"bars", region_offset_f(-0.1666+0.6666-0.04,0)},
		{"bars", region_offset_f(-0.1666+1.0000-0.04,0)},
		{"input", region_offset_f(0.00000+0.05,0.2)},
		{"input", region_offset_f(0.33333+0.05,0.2)},
		{"input", region_offset_f(0.66666+0.05,0.2)},

		{"panel", region_pixoffset_f(2,14)},
		{"panel", region_pixoffset_f(2,39)},
		{"panel", region_pixoffset_f(2,94)},
		{"panel", region_pixoffset_f(2,115)}
	)
	local hsl_adjust_win = guiwindow:define({
		win_min_w=220,
		win_max_w=220,
		win_min_h=316,
		win_max_h=316,
		win_focus=false,
		win_titlebar=true,
		win_title=lang["Adjust HSL"],
		win_icon="icon_hue.png",
		win_show_close = true
	}, hsl_adjust_layout)

	local contrast_adjust_layout = guilayout:define(
		{id="panel",
		 split_type="-x",
		 split_pix=85,
		 sub =
		{id="text",
		 split_type="+y",
	 	 split_pix="25",
	 	 sub = {
		  id="bars",
			split_type="+y",
			split_pix="256",
			sub = {
		   id="input",
			 split_type=nil
			}
		 }}},
		{"text", region_offset_f(0.0-0.04,0.2)},
		{"text", region_offset_f(0.5-0.04,0.2)},
		{"bars", region_offset_f(-0.25+0.5-0.04,0)},
		{"bars", region_offset_f(-0.25+1.0-0.04,0)},
		{"input", region_offset_f(0.0+0.08,0.2)},
		{"input", region_offset_f(0.5+0.08,0.2)},

		{"panel", region_pixoffset_f(4,14)},
		{"panel", region_pixoffset_f(4,39)},
		{"panel", region_pixoffset_f(4,94)}
	)
	local contrast_adjust_win = guiwindow:define({
		win_min_w=175,
		win_max_w=175,
		win_min_h=316,
		win_max_h=316,
		win_focus=false,
		win_titlebar=true,
		win_title=lang["Contrast/Brightness"],
		win_show_close = true
	}, contrast_adjust_layout)

	context["help_context"] = 
		contextmenu:define(
		{
		}
		,
		function(props) return
		 {lang["Set Language"],
		  action=function(props)
		    local win = lang_win:new({},
				{
					guitextbox:new(lang["Set Language"],0,0,100,"center"),
					guibutton:new("English","flag_en.png",0,0, function(self,win) lang:setLanguage("eng")
					                                                    guirender:loadFonts(lang:getFontInfo())
					                                                    MapEditGUI:define(mapedit) end,"middle","top"),
					guibutton:new("Polish","flag_pl.png",0,0, function(self,win) lang:setLanguage("pl")
					                                                   guirender:loadFonts(lang:getFontInfo())
					                                                   MapEditGUI:define(mapedit) end,"middle","top"),
					guibutton:new("Japanese","flag_jp.png",0,0, function(self,win) lang:setLanguage("jp")
					                                                     guirender:loadFonts(lang:getFontInfo())
					                                                     MapEditGUI:define(mapedit) end,"middle","top"),
				},
				0,0,100,115)
				win:centre(0.3,0.5)
				return win
				end,
			disable = false},

		 {lang["~iAbout"],
		  action=function(props)
		    local win = about_win:new({win_show_close=false},
				{
					guiimage:new("ic.png",0,0,80,120,function() self:displayPopup(lang["~b~(red)Do not click the kappa."]) end),
					guitextbox:new(lang["\nWelcome!\n\nMeoxSkins editor © 2025 \nMIT license (see LICENSE.md)"],0,0,300,"center"),
					guibutton:new(lang["~bClose."],nil,0,0, function(self,win) win:delete() end,"middle","bottom")}
					,256,256,256,256)
				win:centre()
				return win
				end,
			disable = false}
		 end)

	context["layers_context"] = 
		contextmenu:define(
		{
		}
		,
		function(props) 
			local edit = require 'edit'
			local skin = require 'skin'
			local active_layer = edit:getActiveLayer()
			local disable = active_layer==nil
		return
		 {lang["Undo"],
		  action=function(props)
		    edit:commitUndo() end,
			disable = not edit:canUndo(),
		  icon = nil},
		 {lang["Redo"],
		  action=function(props)
		    edit:commitRedo() end,
			disable = not edit:canRedo(),
		  icon = nil},

		 {lang["~(green)New layer"],
		  action=function(props)
				local layer = skin:createEmptyLayer()
				edit:commitCommand("add_layer",{layer=layer})
		    return end,
			disable = false},
		 {lang["~bDelete layer"],
	 	  icon="icon_del.png",
		  action=function(props)
				edit:commitCommand("delete_layer",{layer=edit.active_layer})
		    return end,
			disable = disable},
		 {lang["Merge layer down"],
		  action=function(props)
				if not active_layer then return end
				local index = skin:getLayerIndex(active_layer)
				local base_layer = skin.layers[index-1]
				if base_layer then
					edit:mergeLayerDown(base_layer)
				end
		    return end,
			disable = disable},
		 {lang["Move layer down"],
		  action=function(props)
				if not active_layer then return end
				local index = skin:getLayerIndex(active_layer)
				if index<=1 then return end
				if skin:getLayerCount() < 2 then return end
				edit:commitCommand("swap_layers",{index1=index,index2=index-1})
		    return end,
			disable = disable},
		 {lang["Move layer up"],
		  action=function(props)
				if not active_layer then return end
				local count = skin:getLayerCount()
				if count < 2 then return end
				local index = skin:getLayerIndex(active_layer)
				if index>=count then return end
				edit:commitCommand("swap_layers",{index1=index,index2=index+1})
		    return end,
			disable = disable},
		{" --- "},
		 {lang["Rename layer"],
		  action=function(props)
				if not active_layer then return end

				local initial_name = active_layer.name 
				local function test_unique(str, start)
					local skin = require 'skin'
					for i,v in ipairs(skin.layers) do
						if v.name == str and str ~= start then
							return false
						end
					end
					return true
				end

				local input = 
						guitextinput:new("",0,0,220,20,
							function(str) return str end,
							function(str) if not test_unique(str, initial_name) or #str >= 21 then return "~(lred)"..str else return str end end,
							"middle","bottom")
		    return rename_layer_win:new({},
					{
						guitextbox:new(lang["Rename ~b\""] .. tostring(active_layer.name) .. "\"",0,0,300,"left","middle","top",true),
						input,

						guibutton:new(lang["~b~(green)Confirm"],nil,0,0,
							function(self,win)
								if not test_unique(input:getText()) or #input:getText() >= 21 then
									if #input:getText() >= 21 then
										MapEditGUI:displayPopup(lang["Name is too long"], 2.0)
									else
										MapEditGUI:displayPopup(lang["Name already exists"], 2.0)
									end
								else
									active_layer.rename(input:get())
									win:delete()
								end
							end,
							"middle","middle"),
						guibutton:new(lang["Cancel"],nil,0,0,
							function(self,win)
								win:delete()
							end,
							"middle","middle")
					},
					200,80,500,400
				)
			end,
			disable = disable},
		{" --- "},
		 {lang["Change background colour"],
		  action=function(props)
				local picker = self.colour_picker
				local r,g,b = picker:getRGB()
				edit:setBackgroundColour(r,g,b)
		    return end,
			disable = disable,tooltip=lang["Changes background to the currently picked colour."]},
		 {lang["Toggle grid"],
		  action=function(props)
				edit:toggleGrid()
		    return end,
			disable = disable,tooltip=lang["Enable or disable the grid overlay."]}
		 end)

	context["skins_context"] = 
		contextmenu:define(
		{}
		,
		function(props) 
			local edit = require 'edit'
			local skin = require 'skin'
			local model = require 'model'
		return
		 {lang["Slim/Wide mode"],
		  action=function(props)
				edit:commitCommand("swap_mode",{})
		    return end,
			disable = disable,tooltip=lang["Change skin to have wide or slim arms."]},
		 {lang["Pose"],
		  action=function(props)
				--edit:commitCommand("swap_mode",{})
			
				local mat   = require 'mat4'
				local model = require 'model'
				local limb  = "head"
				local rx_bar, ry_bar, rz_bar

				local range = 3.14 * 0.88
				local function updatePose()
					local null = 1.0
					--if limb~="head" then null = 0.0 end
					model:setPose(limb, mat.rot{ (rx_bar.ratio-0.5)*range,  (ry_bar.ratio-0.5)*range*null, (rz_bar.ratio-0.5)*range,})
				end

				local function getXYZrot(m)
					local xr,yr,zr

					xr = math.asin(-m[10])
					yr = math.atan(m[9],m[11])
					zr = math.atan(m[2],m[6])

					return xr,yr,zr
				end

				rx_bar =
					guiscrollb:new(200, 0.5,
						function(scrlb)
							updatePose()
						end, 0.95)
				ry_bar =
					guiscrollb:new(200, 0.5,
						function(scrlb)
							updatePose()
						end, 0.95)
				rz_bar =
					guiscrollb:new(200, 0.5,
						function(scrlb)
							updatePose()
						end, 0.95)

				local function updateBars(new_limb)
					if new_limb == "arm_r" then new_limb = "arm_slim_r" end
					if new_limb == "arm_l" then new_limb = "arm_slim_l" end
					local xr,yr,zr = getXYZrot(model.model_mats[new_limb].rot)
					rx_bar.ratio = 0.5 + xr/range
					ry_bar.ratio = 0.5 + yr/range
					rz_bar.ratio = 0.5 + zr/range
				end
				updateBars("head")

				local head_tick,arm_r_tick,arm_l_tick,leg_r_tick,leg_l_tick
				head_tick = guitickbox:new("Head",0,0,"dot",function(self)
					updateBars("head")
					limb = "head"
					head_tick.state = true
					arm_r_tick.state = false
					arm_l_tick.state = false
					leg_r_tick.state = false
					leg_l_tick.state = false
				end, true)
				arm_l_tick = guitickbox:new("Left arm",0,0,"dot",function(self)
					updateBars("arm_l")
					limb = "arm_l"
					head_tick.state = false
					arm_r_tick.state = false
					arm_l_tick.state = true
					leg_r_tick.state = false
					leg_l_tick.state = false
				end, false)
				arm_r_tick = guitickbox:new("Right arm",0,0,"dot",function(self)
					updateBars("arm_r")
					limb = "arm_r"
					head_tick.state = false
					arm_r_tick.state = true
					arm_l_tick.state = false
					leg_r_tick.state = false
					leg_l_tick.state = false
				end, false)
				leg_r_tick = guitickbox:new("Right leg",0,0,"dot",function(self)
					updateBars("leg_r")
					limb = "leg_r"
					head_tick.state = false
					arm_r_tick.state = false
					arm_l_tick.state = false
					leg_r_tick.state = true
					leg_l_tick.state = false
				end, false)
				leg_l_tick = guitickbox:new("Left leg",0,0,"dot",function(self)
					updateBars("leg_l")
					limb = "leg_l"
					head_tick.state = false
					arm_r_tick.state = false
					arm_l_tick.state = false
					leg_r_tick.state = false
					leg_l_tick.state = true
				end, false)


				--
				return pose_win:new({win_show_close=true},
					{
						ry_bar, rx_bar, rz_bar,

						head_tick, arm_r_tick, arm_l_tick, leg_r_tick, leg_l_tick,

						guibutton:new(lang["Reset"], nil, 0,0,
							function(self)
								rx_bar.ratio=0.5
								ry_bar.ratio=0.5
								rz_bar.ratio=0.5
								updatePose()
							end, "middle"),

						guitextbox:new(lang["Yaw"],0,0,53,"middle","left","top",true),
						guitextbox:new(lang["Pitch"],0,0,53,"middle","left","top",true),
						guitextbox:new(lang["Roll"],0,0,53,"middle","left","top",true),
					},300,300,300,300)
		    end,
			disable = disable,tooltip=lang["Change pose of limbs."]}
		 end)

	context["filters_context"] = 
		contextmenu:define(
		{
		}
		,
		function(props) 
			local edit = require 'edit'
			local skin = require 'skin'
			local active_layer = edit:getActiveLayer()
			local filter_worker = require 'filterworker'
			local disable = active_layer==nil or filter_worker.active_worker
		return
		 {lang["Recent filters"],
	 	  disable = #filter_worker.history < 1 or not edit:getActiveLayer(),
		  suboptions = function(props) 
				local history = {}
				function trunc(n)
					if n >= 0 then
						return math.floor(n * 1000) / 1000
					else
						return math.ceil(n * 1000) / 1000
					end
				end
				for i,v in ipairs(filter_worker.history) do
					if i==9 then break end
					local string = ""
					for i,v in pairs(v.params) do
						if string ~= "" then string = string .. ", " end
						local ss = v
						if type(ss)=="number" then ss=trunc(ss) end
						ss = tostring(ss)
						string = string .. i .. "=" .. ss
					end
					table.insert(history, #history+1,
					{
						lang[v.filter.name],
						disable = disable,
						action = function(props)
							filter_worker:new(v.filter,active_layer,v.params,true)
							filter_worker:set_commit(true)
						end,
						tooltip = string
					})
				end
				return history
		 end},
		 {lang["Adjust HSL"],
		  action=function(props)
				if not active_layer then return end
				local filters = require 'filters'
				local fw = require 'filterworker'
				local params = {hueShift=0.0,satScale=1.0,lumScale=1.0,lumCurvedRemap=0.0}
				local worker = fw:new(filters.get("hsl_adjust"), active_layer, {hueShift=0.0,satScale=1.0,lumScale=1.0,lumCurvedRemap=0.0})
				worker:update_args(params)

				local function remaptoggle(to)
					if not to then params.lumCurvedRemap = 0.0 else params.lumCurvedRemap = 1.0 end	
					worker:update_args(params)
				end
				local function trunc(n)
					if n >= 0 then
						return math.floor(n * 100) / 100
					else
						return math.ceil(n * 100) / 100
					end
				end

				local hue_in, sat_in, lum_in
				local hue_bar, sat_bar, lum_bar
				hue_bar, sat_bar, lum_bar =
					guiscrollb:new(256, 0.5,
						function(scrlb)
							params.hueShift = (scrlb.ratio*360.0) + (360.0*1.5)
							local h = params.hueShift % 360.0
							if h > 180 then h = h - 360 end
							hue_in:setText(tostring(math.floor(h)))
							worker:update_args(params)
						end),
					guiscrollb:new(256, 0.5, function(scrlb)
							params.satScale = (scrlb.ratio-0.5)*-2.0 + 1.0
							sat_in:setText(tostring(trunc(params.satScale)))
							worker:update_args(params)
						end),
					guiscrollb:new(256, 0.5, function(scrlb)
							params.lumScale = (scrlb.ratio-0.5)*-2.0 + 1.0
							if params.lumScale > 1.0 then
								params.lumScale = 2.1*(params.lumScale - 1.0) + 1.0
							end
							lum_in:setText(tostring(trunc(params.lumScale)))
							worker:update_args(params)
						end)
				hue_in, sat_in, lum_in =
					guitextinput:new("0",0,0,40,20,guitextinput.float_validator,
						function (str)
							return guitextinput.float_format_func(str) .. "~r°"
						end,"left","top",
						function(self)
							if self:inputValid() then
								local H = self:get()
								params.hueShift = H
								hue_bar:setRatio(H/360.0+0.5)
								worker:update_args(params)
							end
						end),
					guitextinput:new("1.0",0,0,40,20,guitextinput.float_validator,guitextinput.float_format_func,"left","top",
						function(self)
							if self:inputValid() then
								local S = self:get()
								params.satScale = S
								sat_bar:setRatio((1.0-S)*0.5+0.5)
								worker:update_args(params)
							end
						end
				),
					guitextinput:new("1.0",0,0,40,20,guitextinput.float_validator,guitextinput.float_format_func,"left","top",
						function(self)
							if self:inputValid() then
								local L = self:get()
								params.lumScale = L
								if L <= 1.0 then
									lum_bar:setRatio((1.0-L)*0.5+0.5)
								else
									lum_bar:setRatio(((1.0-L)*0.5)/2.1+0.5)
								end
								worker:update_args(params)
							end
						end
				)

		    return hsl_adjust_win:new({win_close=function(win) edit:unlockEdit() fw:discard() win:delete() end},
				{
					guitextbox:new(lang["Hue"],0,0,66,"center"),
					guitextbox:new(lang["Sat"],0,0,66,"center"),
					guitextbox:new(lang["Lum"],0,0,66,"center"),
					hue_bar,
					sat_bar,
					lum_bar,
					hue_in,
					sat_in,
					lum_in,
					guibutton:new(lang["~b~(green)Confirm"],nil,0,0,function(self,win) fw:set_commit(true) win:delete() end,"left","top",false),
					guibutton:new(lang["Cancel"],nil,0,0,function(self,win) edit:unlockEdit() fw:discard() win:delete() end,"left","top",false),
					guitickbox:new(lang["~(lpurple)Gamma"],0,0,"tick",function(self,win) remaptoggle(self.state) end, false, false),
					guitickbox:new(lang["Preview"],0,0,"tick",function(self,win) edit:setPreviewStatus(self.state) end, edit:getPreviewStatus(), false),
				},
				0,0,300,330)
			end,
			disable = disable},
		 {lang["Contrast/Brightness"],
		  action=function(props)
				if not active_layer then return end
				local filters = require 'filters'
				local fw = require 'filterworker'
				local params = {lumBrightness=0.0,lumContrast=1.0}
				local worker = fw:new(filters.get("contrast"), active_layer, {})
				worker:update_args(params)

				local function trunc(n)
					if n >= 0 then
						return math.floor(n * 100) / 100
					else
						return math.ceil(n * 100) / 100
					end
				end

				local lum_in, contrast_in
				local lum_bar, contrast_bar
				lum_bar, contrast_bar =
					guiscrollb:new(256, 0.5, function(scrlb)
							params.lumBrightness = (scrlb.ratio-0.5)*-2.0
							lum_in:setText(tostring(trunc(params.lumBrightness)))
							worker:update_args(params)
						end),
					guiscrollb:new(256, 0.5, function(scrlb)
							params.lumContrast = (scrlb.ratio-0.5)*-2.0 + 1.0
							contrast_in:setText(tostring(trunc(params.lumContrast)))
							worker:update_args(params)
						end)
				lum_in, contrast_in =
					guitextinput:new("0.0",0,0,40,20,guitextinput.float_validator,guitextinput.float_format_func,"left","top",
						function(self)
							if self:inputValid() then
								local B = self:get()
								params.lumBrightness = B
								lum_bar:setRatio(0.5 - (B*0.5))
								worker:update_args(params)
							end
						end
				),
					guitextinput:new("1.0",0,0,40,20,guitextinput.float_validator,guitextinput.float_format_func,"left","top",
						function(self)
							if self:inputValid() then
								local C = self:get()
								params.lumContrast = C
								contrast_bar:setRatio((1.0-C)*0.5+0.5)
								worker:update_args(params)
							end
						end
				)

		    return contrast_adjust_win:new({win_close=function(win) edit:unlockEdit() fw:discard() win:delete() end},
				{
					guitextbox:new(lang["Lum"],0,0,66,"center"),
					guitextbox:new(lang["Con"],0,0,66,"center"),
					lum_bar,
					contrast_bar,
					lum_in,
					contrast_in,
					guibutton:new(lang["~b~(green)Confirm"],nil,0,0,function(self,win) fw:set_commit(true) win:delete() end,"left","top",false),
					guibutton:new(lang["Cancel"],nil,0,0,function(self,win) edit:unlockEdit() fw:discard() win:delete() end,"left","top",false),
					guitickbox:new(lang["Preview"],0,0,"tick",function(self,win) edit:setPreviewStatus(self.state) end, edit:getPreviewStatus(), false),
				},
				0,0,300,330)
			end,
			disable = disable},
		 {lang["Curves"],
		  action=function(props)
				if not active_layer then return end
				local filters = require 'filters'
				local fw = require 'filterworker'
				local params = {}
				local worker = fw:new(filters.get("curves"), active_layer, {})

				local function trunc(n)
					if n >= 0 then
						return math.floor(n * 100) / 100
					else
						return math.ceil(n * 100) / 100
					end
				end

				local histogram = require 'histogram'
				vs,vp,vi = histogram.retrieve(active_layer.texture, "value")
				rs,rp,ri = histogram.retrieve(active_layer.texture, "red")
				gs,gp,gi = histogram.retrieve(active_layer.texture, "green")
				bs,bp,bi = histogram.retrieve(active_layer.texture, "blue")
				local histograms = {
					value = { sorted = vs, percentile = vp, interval = vi },
					red   = { sorted = rs, percentile = rp, interval = ri },
					green = { sorted = gs, percentile = gp, interval = gi },
					blue  = { sorted = bs, percentile = bp, interval = bi },
				}

				local guicurves = require 'gui.curves'
				local curve = guicurves:new(0.95,0.95,
					function() 
						worker:update_args(params)
						fw.active_worker._update_preview=true
					end,
					histograms)

				local valuetick,redtick,bluetick,greentick
				valuetick = guitickbox:new(lang["Value"],0,0,"dot",
					function(self,win)
						if not self.state then self.state = true return end
						redtick.state,greentick.state,bluetick.state = false,false,false
						curve.active_channel = "value"
					end, true, false)
				redtick = guitickbox:new(lang["Red"],0,0,"dot",
					function(self,win)
						if not self.state then self.state = true return end
						valuetick.state,greentick.state,bluetick.state = false,false,false
						curve.active_channel = "red"
					end, false, false)
				greentick = guitickbox:new(lang["Green"],0,0,"dot",
					function(self,win)
						if not self.state then self.state = true return end
						valuetick.state,redtick.state,bluetick.state = false,false,false
						curve.active_channel = "green"
					end, false, false)
				bluetick = guitickbox:new(lang["Blue"],0,0,"dot",
					function(self,win)
						if not self.state then self.state = true return end
						valuetick.state,redtick.state,greentick.state = false,false,false
						curve.active_channel = "blue"
					end, false, false)

				params.valueCurve = curve.value.samples
				params.redCurve   = curve.red.samples
				params.greenCurve = curve.green.samples
				params.blueCurve  = curve.blue.samples
				worker:update_args(params)

		    local curves = curves_win:new({win_close=function(win) edit:unlockEdit() fw:discard() win:delete() end},
				{
					curve,
					guibutton:new(lang["~b~(green)Confirm"],nil,0,0,function(self,win) fw:set_commit(true) win:delete() end,"right","top",false),
					guibutton:new(lang["Cancel"],nil,0,0,function(self,win) edit:unlockEdit() fw:discard() win:delete() end,"left","top",false),
					guitickbox:new(lang["Preview"],0,0,"tick",function(self,win) edit:setPreviewStatus(self.state) end, edit:getPreviewStatus(), false),
					guibutton:new(lang["Reset"],0,0,"tick",function(self,win) curve:resetCurve() end, edit:getPreviewStatus(), false),
					valuetick,redtick,greentick,bluetick
				},
				0,0,300,330)

				curves:centre(0.2,0.5)
				return curves
			end,
			disable = disable},
		{" --- "},
		 {lang["Invert (HSL)"],
		  action=function(props)
				if not active_layer then return end
				local filters = require 'filters'
				local fw = require 'filterworker'
				fw:new(filters.get("invert_hsl"), active_layer, {})
				fw:set_commit(true)
		    return end,
			disable = disable}
		 end)

	context["main_file_context"] =
		contextmenu:define(
		{
		 -- props
		},
		function(props) return
		{lang["Save"],action=function()
			local edit = require 'edit'
			local dialog = require 'dialog'
			local dirmem = require 'dirmem'
			local filepath = dialog.save("Save as", dirmem.get("save"), ".png Skin File", {"*.png", "*.PNG"})
			if filepath then
				edit:saveToFile(filepath, true)
				dirmem.memo("save", filepath)
				dirmem.init("open", filepath)
			end
		end},
		{lang["Save as Project"],action=function()
			local edit = require 'edit'
			local dialog = require 'dialog'
			local dirmem = require 'dirmem'
			local filepath = dialog.save("Save as", dirmem.get("save"), ".png Skin File", {"*.png", "*.PNG"})
			if filepath then
				edit:saveProjectToFile(filepath, true)
				dirmem.memo("save", filepath)
				dirmem.init("open", filepath)
			end
		end},
		{lang["Open"],action=function()
			local edit = require 'edit'
			local dialog = require 'dialog'
			local dirmem = require 'dirmem'
			local filepath = dialog.open("Open", dirmem.get("open"), ".png Skin File", {"*.png", "*.PNG"})
			if filepath and filepath ~= "" then
				dirmem.memo("open",filepath)
				dirmem.init("save",filepath)
				return skin_mode_win:new(
					{},
					{
						guitextbox:new(lang["Skin type?"],0,0,150,"center","left","top"),
						guibutton:new(lang["Wide"],nil,0,0,
							function(self,win)
								win:delete()
								edit:load{skin_name=filepath,skin_mode="wide"}
								clearKeys()
							end,
							"middle","middle"),
						guibutton:new(lang["Slim"],nil,0,0,
							function(self,win)
								win:delete()
								edit:load{skin_name=filepath,skin_mode="slim"}
								clearKeys()
							end,
							"middle","middle"),
					},0,0
				)
			end
		end},
		{" --- "},
		{lang["Key settings"],action=function()
			local bindings = require 'bindings'
			local edit = require 'edit'

			local function get(b,k)
				return bindings.getReadableTxt(EDIT_KEY_SETTINGS[k][b])
			end

			local opts = {
				{"Erase Pixel", "edit_erase"},
				{"Fill Face", "edit_colour_fill"},
				{"Pick Pixel Colour", "edit_colour_pick"},
				{"Toggle Mirror", "edit_mirror"},
				{"Toggle Grid", "edit_grid"},
				{"Ignore Alpha Lock", "edit_alpha_override"},
				{"Hide/Show Overlay", "edit_hide_overlay"},
				{"Head", "edit_hide_head"},
				{"L Arm", "edit_hide_arm_l"},
				{"R Arm", "edit_hide_arm_r",},
				{"L Leg", "edit_hide_leg_l"},
				{"R Leg", "edit_hide_leg_r"},
				{"Torso", "edit_hide_torso"}
			}

			local opts_N = #opts
			local layout_entries = {}
			for i,v in ipairs(opts) do
				table.insert(layout_entries, {"text_region", region_offset_f(0.05, (i-1)/(opts_N+1)+0.02)})
			end
			for i,v in ipairs(opts) do
				table.insert(layout_entries, {"bind1", region_offset_f(0.05, (i-1)/(opts_N+1)+0.02)})
			end
			for i,v in ipairs(opts) do
				table.insert(layout_entries, {"bind2", region_offset_f(0.05, (i-1)/(opts_N+1)+0.02)})
			end
			table.insert(layout_entries,
				{"bind1", region_offset_f(0.05, opts_N/(opts_N+1)+0.02)})

			local key_settings_layout = guilayout:define(
				{id="text_region",
				 split_type="+x",
				 split_ratio=0.3333,
				 sub=
				{id="bind1",
				 split_type="+x",
				 split_ratio=0.5,
				 sub=
				{id="bind2",
				}}},
				unpack(layout_entries)
			)
			local key_settings_win = guiwindow:define({
				win_min_w=430,
				win_max_w=430,
				win_min_h=410,
				win_max_h=410,
				win_focus=false,
				win_titlebar=true,
				win_icon="icon_key.png",
				win_title=lang["Key settings"],
				win_show_close=true
			}, key_settings_layout)

			local elements = {}
			for i,v in ipairs(opts) do
				table.insert(elements,
					guitextbox:new(lang[v[1]], 0,0, 200, "left", "left","top",false,true))
			end
			for i,v in ipairs(opts) do
				table.insert(elements,
					guibutton:new(bindings.getReadableTxt0(get(1,v[2])),nil,0,0,
						function(self) edit:listenForKeyChange(v[2],1,function() self:generateText(
							bindings.getReadableTxt0(EDIT_KEY_SETTINGS[v[2]][1])) end)
						end,"left","top",nil,false,100,20,"middle"))
			end
			for i,v in ipairs(opts) do
				table.insert(elements,
					guibutton:new(bindings.getReadableTxt0(get(2,v[2])),nil,0,0,
						function(self) edit:listenForKeyChange(v[2],2,function() self:generateText(
							bindings.getReadableTxt0(EDIT_KEY_SETTINGS[v[2]][2])) end)
						end,"left","top",nil,false,100,20,"middle"))
			end

			table.insert(elements,
					guibutton:new(lang["Reset"],nil,0,0,
						function(self) resetKeySettings() MapEditGUI:updateKeybindTooltip() end,"left","top",nil,false,100,20,"middle"))

			local win = key_settings_win:new(
				{win_show_close=true},
				elements
				,300,300,300,300
			)
			win:centre()

			return win
		end},
		{" --- "},
		{lang["~iQuit"],action=function()love.event.quit()end}
		end
		)

	toolbars["main_toolbar"] =
		toolbar:define(
		{

		},

		{lang["File"],
		 generate =
		   function(props)
			   return context["main_file_context"], {}
		   end
		},
		{lang["Edit"],
		 generate =
		   function(props)
			   return context["layers_context"], {}
		   end
		},
		{lang["Filters"],
		 generate =
		   function(props)
			   return context["filters_context"], {}
		   end
		},
		{lang["Skin"],
		 generate =
		   function(props)
			   return context["skins_context"], {}
		   end
		},
		{lang["Help"],
		 generate =
		   function(props)
				 return context["help_context"], {}
		   end
		}
		)

	local main_toolbar = toolbars["main_toolbar"]:new({},0,0,1000,10)

	local panel_layout = guilayout:define(
		{id="toolbar_region",
		 split_type="+y",
		 split_pix=20,
		 sub = {
			id="viewport_region",
			split_type="-x",
			split_pix=300,
			sub = {
				id="layers_region",
				split_type=nil
			}
		 }
		},

		{"toolbar_region", function(l) return l.x,l.y,l.w,l.h end},
		{"viewport_region", region_pixoffset_f(0,0)},
		{"layers_region", region_default_f},
		{"layers_region", region_offset_f(0.005,0.99)}
	)

	local skin = require 'skin'
	local edit = require 'edit'
	local layers_picker = 
		guilayers:new(
			function() return skin.layers end,
			function() return edit.active_layer end,
			function(a) edit.active_layer = a end
		)

	local bindings = require 'bindings'
	self.control_tooltip = guitextbox:new(bindings.controlTooltip(),0,0,500,"left","left","bottom",true)

	local w,h = love.graphics.getDimensions()
	self.main_panel = guiscreen:new(
		panel_layout:new(
		  0,0,w,h,{main_toolbar,layers_picker,nil,self.control_tooltip}),
			function(o) self:handleTopLevelThrownObject(o) end,
			CONTROL_LOCK.EDIT_PANEL,
			CONTROL_LOCK.EDIT_WINDOW
	)
	self.main_panel:addElement(self.control_tooltip)

	self.colour_picker = guicolourpicker:new(
		function(picker)
			local H,S,L = picker.curr_hue, picker.curr_sat, picker.curr_lum

			local function hslToRgb(h, s, l)
				local r, g, b

				if s == 0 then
					r, g, b = l, l, l
				else
					function hue2rgb(p, q, t)
						if t < 0 then t = t + 1 end
						if t > 1 then t = t - 1 end
						if t < 1/6 then return p + (q - p) * 6 * t end
						if t < 1/2 then return q end
						if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
						return p
					end

					local q = l < 0.5 and l * (1 + s) or l + s - l * s
					local p = 2 * l - q

					r = hue2rgb(p, q, h + 1/3)
					g = hue2rgb(p, q, h)
					b = hue2rgb(p, q, h - 1/3)
				end

				return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
			end

			local R,G,B = hslToRgb(H,S,L)
			R = math.floor(R)
			G = math.floor(G)
			B = math.floor(B)
			R = string.format("%x", R)
			G = string.format("%x", G)
			B = string.format("%x", B)

			self.hex_input.text:set("#"..R..G..B)
		end
	)
	self.hex_input = guitextinput:new(
		"#AACCDD",0,0,280,20,guitextinput.hexcol_validator,guitextbox.hexcol_format_func,"left",nil,
		function(tinput)
			local R = tinput:get()
			if R then
				self.colour_picker:setRGBColour(R[1],R[2],R[3])
			else
			end
		end
	)
	self.colour_picker:colour_change_hook()

	self.colour_picker_win = colour_win:new({win_show_close=false},
		{self.colour_picker,self.hex_input},20,20,12,50)
	self.main_panel:pushWindow(self.colour_picker_win)

	self.visible_win = visible_win:new({win_show_close=false},
	{guivisible:new(
		function() local edit=require 'edit' return edit.active_mode end,
		function() local edit=require 'edit' return edit.mirror_mode end
	)}
	,20,20,80,380)
	self.main_panel:pushWindow(self.visible_win)


	self.main_panel:update()
	self.main_panel:resize()
	layers_picker:update()
end

--
-- context menu functions
--

function MapEditGUI:openContextMenu(context_name, props)
	local context_table = self.context_menus
	local context_def = context_table[context_name]
	assert(context_def, string.format("No context menu %s defined", context_name))

	local context = context_def:new(props)
	assert(context)

	CONTROL_LOCK.EDIT_CONTEXT.elevate()
	self.curr_context_menu = context
	return context
end

function MapEditGUI:loadContextMenu(cxtm)
	if not cxtm then return end
	CONTROL_LOCK.EDIT_CONTEXT.open()
	self.curr_context_menu = cxtm
	return cxtm
end

function MapEditGUI:exitContextMenu()
	if self.curr_context_menu then
		--self.curr_context_menu:release()
		self.curr_context_menu = nil
	end
	CONTROL_LOCK.EDIT_CONTEXT.queueClose()
end

function MapEditGUI:drawContextMenu()
	local cxtm = self.curr_context_menu
	if not cxtm then return end
	cxtm:draw()
end
function MapEditGUI:updateContextMenu()
	if not self.curr_context_menu then
		self.context_menu_hovered = false
		return
	end
	local x,y = love.mouse.getX(), love.mouse.getY()
	self.context_menu_hovered = self.curr_context_menu:updateHoverInfo(x,y)
end

--
-- context menu functions
--

--
-- popup menu functions
--
function MapEditGUI:displayPopup(str, ...)
	self.curr_popup = popup:throw(str, ...)
end
function MapEditGUI:drawPopup()
	local p = self.curr_popup
	if not p then return end
	p:draw()
end
function MapEditGUI:updatePopupMenu()
	if not self.curr_popup then return end
	local p = self.curr_popup
	if p:expire() then
		p:release()
		self.curr_popup = nil
	end
end
--
-- popup menu functions
--

--
-- main screen panel functions
--
function MapEditGUI:updateMainPanel()
	self.main_panel:update()
end
function MapEditGUI:drawMainPanel()
	self.main_panel:draw()
end
--
--
--

	local window_move_m_start_x = 0
	local window_move_m_start_y = 0
	local window_move_start_x = 0
	local window_move_start_y = 0
	local window_move_flag = false
	local window_move_window = nil
function MapEditGUI:setupInputHandling()
	self.cxtm_input = InputHandler:new(CONTROL_LOCK.EDIT_CONTEXT,
	                                   {"cxtm_select","cxtm_scroll_up","cxtm_scroll_down"})

	local cxtm_select_option = Hook:new(function ()
		local cxtm = self.curr_context_menu
		if not cxtm then
			self:exitContextMenu()
			return
		end
		local hovered_opt = cxtm:getCurrentlyHoveredOption()
		if not hovered_opt then
			self:exitContextMenu()
			return
		end
		local action = hovered_opt.action
		if action then
			local gui_object = action()
			if gui_object then
				self:handleTopLevelThrownObject(gui_object)
			end
		end
		self:exitContextMenu()
	end)
	self.cxtm_input:getEvent("cxtm_select", "down"):addHook(cxtm_select_option)

	self.panel_input = InputHandler:new(CONTROL_LOCK.EDIT_PANEL,
	                                   {"panel_select","window_move","window_move_bar"})
	local panel_select_option = Hook:new(function ()
		local m = self.main_panel
		local gui_object = m:click()
		if gui_object then
			self:handleTopLevelThrownObject(obj)
		end
	end)
	self.panel_input:getEvent("panel_select", "down"):addHook(panel_select_option)

	self.win_input = InputHandler:new(CONTROL_LOCK.EDIT_WINDOW,
	                                 {"window_select","window_move","window_move_bar"})
	local window_select_option = Hook:new(function ()
		local m = self.main_panel:clickOnWindow()
	end)
	self.win_input:getEvent("window_select", "down"):addHook(window_select_option)

	local window_move_start = Hook:new(function ()
		if window_move_flag then return end
		local win = self.main_panel:getCurrentlyHoveredWindow()
		if not win then return end
		window_move_flag = true
		window_move_m_start_x, window_move_m_start_y = love.mouse.getPosition()
		window_move_window = win
		window_move_start_x, window_move_start_y = win.x, win.y
	end)

	local window_move_action = Hook:new(function ()
		if not window_move_flag then return end
		local win = window_move_window
		if not win then return end
		local x,y = love.mouse.getPosition()
		local dx,dy = x-window_move_m_start_x, y-window_move_m_start_y
		win:setX(window_move_start_x + dx)
		win:setY(window_move_start_y + dy)
		win:update()
		win:updateHoverInfo()
	end)

	local window_move_finish = Hook:new(function ()
		window_move_flag = false
	end)

	self.win_input:getEvent("window_move", "down"):addHook(window_move_start)
	self.win_input:getEvent("window_move", "held"):addHook(window_move_action)
	self.win_input:getEvent("window_move", "up"):addHook(window_move_finish)

	local window_bar_move_start = Hook:new(function ()
		if window_move_flag then return end
		local win = self.main_panel:getCurrentlyHoveredWindow()
		if not win or not win.hover_titlebar then return end
		window_move_flag = true
		window_move_m_start_x, window_move_m_start_y = love.mouse.getPosition()
		window_move_window = win
		window_move_start_x, window_move_start_y = win.x, win.y
	end)

	self.win_input:getEvent("window_move_bar", "down"):addHook(window_bar_move_start)
	self.win_input:getEvent("window_move_bar", "held"):addHook(window_move_action)
	self.win_input:getEvent("window_move_bar", "up"):addHook(window_move_finish)

end

function MapEditGUI:handleWindowMovement()
	if not window_move_flag then return end
	local win = window_move_window
	if not win then return end
	local x,y = love.mouse.getPosition()
	local dx,dy = x-window_move_m_start_x, y-window_move_m_start_y
	win:setX(window_move_start_x + dx)
	win:setY(window_move_start_y + dy)
	win:update()
end

function MapEditGUI:handleTopLevelThrownObject(obj)
	local o_type = provtype(obj)
	if o_type == "mapeditcontextmenu" then
		self:loadContextMenu(obj)
	elseif o_type == "mapeditwindow" then
		self.main_panel:pushWindow(obj)
	end
end

function MapEditGUI:updateKeybindTooltip(str)
	local bindings = require 'bindings'
	str = str or bindings.controlTooltip()
	self.control_tooltip:generateText(str)
end

function MapEditGUI:poll()
	self.cxtm_input:poll()
	self.panel_input:poll()
	self.win_input:poll()
end

function MapEditGUI:setTextInputHook(t) 
	if not t then return self.textinput_hook end
	love.keyboard.setKeyRepeat(true)
	self.textinput_hook = t
	return t
end
function MapEditGUI:removeTextInputHook(i)
	if self.textinput_hook == i then
		love.keyboard.setKeyRepeat(false)
		self.textinput_hook = nil
	end
end
function MapEditGUI:textinput(t)
	local hook = self.textinput_hook
	if hook then hook(t) end
end
function MapEditGUI:keypressed(key,scancode,isrepeat)
	if scancode=="backspace" then
		self:textinput("\b")
	elseif scancode=="home" then
		self:textinput("\thome")
	elseif scancode=="end" then
		self:textinput("\tend")
	elseif scancode=="right" then
		self:textinput("\tright")
	elseif scancode=="left" then
		self:textinput("\tleft")
	elseif scancode=="v" then
		local ctrl = scancodeIsPressed("lctrl", CONTROL_LOCK.META) or
		             scancodeIsPressed("rctrl", CONTROL_LOCK.META)
		if ctrl then
			local clipboard = love.system.getClipboardText()
			if clipboard and clipboard ~= "" then
				self:textinput(clipboard)
			end
		end
	end
end

function MapEditGUI:update(dt)
	self:handleWindowMovement()
	self:updateMainPanel()
	self:updatePopupMenu()
	self:updateContextMenu()
	self:poll()

	if self.curr_context_menu then
		cursor.arrow()
	end
end

function MapEditGUI:resize()
	self.main_panel:update()
	self.main_panel:resize()
	--layers_picker:update()
end

function MapEditGUI:draw()
	self:drawMainPanel()
	self:drawPopup()
	self:drawContextMenu()
end

return MapEditGUI
