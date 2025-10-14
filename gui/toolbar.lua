--
-- map edit toolbar item
--

require "prop"

local guirender = require 'gui.guidraw'
local contextmenu = require 'gui.context'

local MapEditToolbar = {
	buffer_info = {
		l  = 24,
		l_no_icon  = 4,
		r = 6,
		t = 5,
		b = 3,

		arrow_r = 20,
		arrow_t = 1,

		icon_l = 2,
		icon_t = 1,
	}
}
MapEditToolbar.__index = MapEditToolbar

--
-- prototype is a prop table prototype for the interal properties
-- each instance of this toolbar can have, these then can
-- be dynamically filled out on instance creation
--
--  
-- each argument after that is the definition for a menu in this toolbar
-- each option has the following format:
-- 1. {name, generate = function, disable = boolean, icon = string }
--
-- gen is a function(props) that returns a context menu definition and a
-- property table that this context menu should have
-- it is called when the menu is clicked
--
--
--
--
-- once a toolbar has been defined, instances can be created using
-- toolbar:new({key=value,...}, x, y, width_function, lock)
-- where width_function is a pure function that returns the maximum
-- width that the toolbar can have and lock is a control lock in input.lua
-- that this toolbar is meant to operate in
--

function MapEditToolbar:define(prototype, ...)
	local buffer_info = self.buffer_info
	local menus = { ... }

	local p = Props:prototype(prototype)
	local obj = {
		new = function(self, props, X, Y, w, h, lock)
			assert(X and Y)
			local this = {
				props  = p(props),
				__type = "toolbar",
				menus = {},
				x = Y,
				y = X,
				w = w,
				h = h,
				lock = lock,

				scroll_x = 0
			}

			function this.setX(self,x)
				self.x = x end
			function this.setY(self,y)
				self.y = y end
			function this.setW(self,w)
				self.w = w end
			function this.setH(self,h) -- height is fixed
				end

			function this.draw(self)
				local x,y = self.x,self.y
				local max_w,max_h = self.w, self.h

				love.graphics.setColor(24/290,41/290,74/290,0.9)
				love.graphics.rectangle("fill",x,y,max_w,max_h)
				love.graphics.setColor(1,1,1,1)
				--love.graphics.setScissor(x,y,max_w,max_h)

				for i,v in ipairs(self.menus) do
					local menu_x,menu_y = v.x,v.y
					local w,h = v.w,v.h

					local state = "normal"
					if v.disable then state = "disable" 
					elseif v.hover then state = "hover" 
					end

					guirender:drawGenericOption(x + menu_x, y + menu_y, v.w, v.h, v.bg, v.text, v.icon, false,
					 state, buffer_info)
				end

				love.graphics.setScissor()
			end

			function this.unfocus(self)
				for i,v in ipairs(self.menus) do
					v.hover = false
				end
				return
			end

			function this.updateHoverInfo(self)
				local mx,my = love.mouse.getPosition()
				local hovered = nil
				for i,v in ipairs(self.menus) do
					local x,y,w,h = v.x,v.y,v.w,v.h
					local x2,y2 = x+w,y+h
					if not v.disable and
					   x<=mx and mx<= x2 and
					   y<=my and my<= y2
					then
						v.hover = true
						hovered = v
					else
						v.hover = false
					end
				end
				return hovered
			end
			function this.getCurrentlyHoveredOption(self)
				for i,v in ipairs(self.menus) do
					if v.hover then
						return v
					end
				end
			end

			local x_acc = 0
			local function fill_out_menu(menu_def)
				local menu = {}

				local name = menu_def[1]
				menu.generate = menu_def.generate
				local icon = menu_def.icon
				if icon then
					menu.icon = guirender.icons[menu_def.icon] or nil
				end

				assert(name, "MapEditToolbar:define(): no name given for a menu option")
				assert(menu.generate, "MapEditToolbar:define(): no generator function given for a menu option")

				menu.text, menu.w, menu.h = guirender:drawableFormatString(name, this.props)

				if icon then
					menu.w = menu.w + buffer_info.l + buffer_info.r
				else
					menu.w = menu.w + buffer_info.l_no_icon + buffer_info.r
				end
				menu.h = menu.h + buffer_info.t + buffer_info.b

				menu.bg = guirender:createContextMenuBackground(menu.w,menu.h)
				menu.x = x_acc
				menu.y = 0
				x_acc = x_acc + menu.w+1

				menu.hover = false
				menu.disable = menu_def.disable

				menu.action = function(self)
					local context_menu_def, context_props = self.generate(self.props)
					--assert(context_menu_def, "MapEditToolbar: recieved no context menu definition in menu:action()")
					if not context_menu_def then return end
					local cx,cy = this.x + menu.x, this.y + menu.y
					return context_menu_def:new(context_props, cx, cy+self.h)
				end

				return menu
			end

			for i,v in ipairs(menus) do
				this.menus[i] = fill_out_menu(v)
				local mh = this.menus[i].h
				if mh > this.h then this.h = mh end

				local function action(self)
					local def,props = self:generate()
					if def then
						return def:new(props)
					end
				end
			end

			return this
		end}

		return obj
end

return MapEditToolbar
