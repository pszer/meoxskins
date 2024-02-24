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

local lang         = require 'gui.guilang'

local utf8         = require "utf8"

require "inputhandler"
require "input"

local MapEditGUI = {

	context_menus = {},
	toolbars = {},

	main_panel = nil,

	curr_context_menu = nil,
	curr_popup = nil,
	
	main_toolbar = nil,

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

	context["select_undef_context"] = 
		contextmenu:define(
		{
		}
		,
		function(props) return
		 {lang["~bCopy"],
		  action=function(props)
		    end,
			disable = true,
		  icon = "mapedit/icon_copy.png"},

		 {lang["Paste"],
		  action=function(props)
		    end,
			disable = not mapedit:canPaste(),
		  icon = "mapedit/icon_dup.png"},

		 {lang["Undo"],
		  action=function(props)
		    mapedit:commitUndo() end,
			disable = not mapedit:canUndo(),
		  icon = nil},

		 {lang["Redo"],
		  action=function(props)
		    mapedit:commitRedo() end,
			disable = not mapedit:canRedo(),
		  icon = nil},

		 {lang["~b~(orange)Delete"],
		  icon = "mapedit/icon_del.png",
			disable = true},

		 {lang["~(lpurple)Group"], suboptions = function(props) 
	     return {}
			end, disable = true},

		 {lang["~(lgray)--Transform--"]},

		 {lang["Flip"], suboptions = function(props) 
		  return {} end,
		  disable = true},

		 {lang["Rotate"], suboptions = function(props)
		 	return {} end,
		  disable = true},

		 {lang["~bReset"],disable = true, icon = nil},

		 {lang["~(lgray)--Actions--"]}
		 end)

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
		win_min_h=100,
		win_max_h=100,
	}, about_win_layout)
	-- About window

	-- Picker window
	local picker_win_layout = guilayout:define(
		{id="hex_region",
		 split_type="+y",
		 split_pix=370,
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
		win_min_h=390,
		win_max_h=390,
	}, picker_win_layout)
	-- Picker window
	
	-- Wide/Slim skin mode window
	local skin_mode_win_layout = guilayout:define(
		{id="text_region",
		 split_type="+y",
		 split_pix=40,
		 sub=
		 	{id="wide_region",
			 split_type="+x",
			 split_pix=50,
			 sub={
			 	id="slim_region",
				split_type=nil
			 }
			}
		},
		{"text_region", region_pixoffset_f(0,4)},
		{"wide_region", region_pixoffset_f(8,0)},
		{"slim_region", region_pixoffset_f(8,0)}
	)
	local skin_mode_win = guiwindow:define({
		win_min_w=100,
		win_max_w=100,
		win_min_h=60,
		win_max_h=60,
		win_focus=true,
	}, skin_mode_win_layout)
	-- Wide/Slim skin mode window

	-- Visible parts window
	local visible_win_layout = guilayout:define(
		{id="visible_region",
		 split_type=slim,
		},
		{"visible_region", region_pixoffset_f(10,10)}
	)
	local visible_win = guiwindow:define({
		win_min_w=160,
		win_max_w=160,
		win_min_h=180,
		win_max_h=180,
	}, visible_win_layout)
	-- Visible parts window


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
	}, lang_win_layout)
	-- Change map name window
	local mapname_win_layout = guilayout:define(
		{id="region",
		 split_type=nil},
		{"region", region_ypixoffset_f(0.5,10)},
		{"region", region_ypixoffset_f(0.5,25)},
		{"region", region_ypixoffset_f(0.5,50)}
	)
	local mapname_win = guiwindow:define({
		win_min_w=200,
		win_max_w=200,
		win_min_h=75,
		win_max_h=75,
		win_focus=true,
	}, mapname_win_layout)


	context["help_context"] = 
		contextmenu:define(
		{
		}
		,
		function(props) return
		 {lang["Keybinds"],
		  action=function(props)
		    return end,
			disable = true},

		 {lang["Set Language"],
		  action=function(props)
		    return lang_win:new({},
				{
					guitextbox:new(lang["Set Language"],0,0,100,"center"),
					guibutton:new("English","mapedit/flag_en.png",0,0, function(self,win) lang:setLanguage("eng")
					                                                    guirender:loadFonts(lang:getFontInfo())
					                                                    MapEditGUI:define(mapedit) end,"middle","top"),
					guibutton:new("Polish","mapedit/flag_pl.png",0,0, function(self,win) lang:setLanguage("pl")
					                                                   guirender:loadFonts(lang:getFontInfo())
					                                                   MapEditGUI:define(mapedit) end,"middle","top"),
					guibutton:new("Japanese","mapedit/flag_jp.png",0,0, function(self,win) lang:setLanguage("jp")
					                                                     guirender:loadFonts(lang:getFontInfo())
					                                                     MapEditGUI:define(mapedit) end,"middle","top"),
				},
				0,0,100,115)
				end,
			disable = false},

		 {lang["~iAbout"],
		  action=function(props)
		    return about_win:new({},
				{
					guiimage:new("ic.png",0,0,80,120,function() self:displayPopup(lang["~b~(red)Do not click the kappa."]) end),
					guitextbox:new(lang["\nWelcome!\n\nMeoxSkins editor © 2024 \nMIT license (see LICENSE.md)"],0,0,300,"center"),
					guibutton:new(lang["~bClose."],nil,0,0, function(self,win) win:delete() end,"middle","bottom")}
					,256,256,256,256)
				end,
			disable = false}
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
			local filepath = dialog.save("Save as")
			if filepath then
				edit:saveToFile(filepath, true)
			end
		end},
		{lang["Open"],action=function()
			local edit = require 'edit'
			local dialog = require 'dialog'
			local filepath = dialog.open("Open")
			if filepath and filepath ~= "" then
			return skin_mode_win:new(
				{},
				{
					guitextbox:new(lang["Skin type?"],0,0,100,"center","left","top"),
					guibutton:new(lang["Wide"],nil,0,0,
						function(self,win)
							win:delete()
							edit:load(filepath,"wide")
							clearKeys()
						end,
						"left","middle"),
					guibutton:new(lang["Slim"],nil,0,0,
						function(self,win)
							win:delete()
							edit:load{skin_name=filepath,skin_mode="slim"}
							clearKeys()
						end,
						"left","middle"),
				},0,0
			)
			end
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
			split_type=nil,
		 }
		},

		{"toolbar_region", function(l) return l.x,l.y,l.w,l.h end},
		{"viewport_region", region_pixoffset_f(0,0)}
	)

	local w,h = love.graphics.getDimensions()
	self.main_panel = guiscreen:new(
		panel_layout:new(
		  0,0,w,h,{main_toolbar,
				}),
			function(o) self:handleTopLevelThrownObject(o) end,
			CONTROL_LOCK.EDIT_PANEL,
			CONTROL_LOCK.EDIT_WINDOW
	)

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

	self.colour_picker_win = colour_win:new({},
		{self.colour_picker,self.hex_input},20,20,20,30)
	self.main_panel:pushWindow(self.colour_picker_win)

	self.visible_win = visible_win:new({},
	{guivisible:new(function() local edit=require 'edit' return edit.active_mode end)}
	,20,20,340,30)
	self.main_panel:pushWindow(self.visible_win)

	--self.colour_picker:setX(10)
	--self.colour_picker:setY(30)
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
	                                   {"panel_select","window_move"})
	local panel_select_option = Hook:new(function ()
		local m = self.main_panel
		local gui_object = m:click()
		if gui_object then
			self:handleTopLevelThrownObject(obj)
		end
	end)
	self.panel_input:getEvent("panel_select", "down"):addHook(panel_select_option)

	self.win_input = InputHandler:new(CONTROL_LOCK.EDIT_WINDOW,
	                                 {"window_select","window_move"})
	local window_select_option = Hook:new(function ()
		local m = self.main_panel:clickOnWindow()
	end)
	self.win_input:getEvent("window_select", "down"):addHook(window_select_option)

	local window_move_m_start_x = 0
	local window_move_m_start_y = 0
	local window_move_start_x = 0
	local window_move_start_y = 0
	local window_move_flag = false
	local window_move_window = nil

	local window_move_start = Hook:new(function ()
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
	end)

	local window_move_finish = Hook:new(function ()
		window_move_flag = false
	end)

	self.win_input:getEvent("window_move", "down"):addHook(window_move_start)
	self.win_input:getEvent("window_move", "held"):addHook(window_move_action)
	self.win_input:getEvent("window_move", "up"):addHook(window_move_finish)

end

function MapEditGUI:handleTopLevelThrownObject(obj)
	local o_type = provtype(obj)
	if o_type == "mapeditcontextmenu" then
		self:loadContextMenu(obj)
	elseif o_type == "mapeditwindow" then
		self.main_panel:pushWindow(obj)
	end
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
	self:updateMainPanel()
	self:updatePopupMenu()
	self:updateContextMenu()
	self:poll()
end

function MapEditGUI:draw()
	self:drawMainPanel()
	self:drawPopup()
	self:drawContextMenu()
end

return MapEditGUI
