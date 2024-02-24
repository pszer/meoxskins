--
-- map edit gui window
--

require "prop"

local guirender = require 'gui.guidraw'

local MapEditGUIWindow = {
	__type = "mapeditwindow",

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
MapEditGUIWindow.__index = MapEditGUIWindow

--
-- layout holds gui objects as a parent and positions them
-- according to a specified layout.
--
--

local WindowProps = Props:prototype{
	{"win_min_w"    , "number", 10  , PropIntegerMin(10), "window maximum size (x direction)"},
	{"win_min_h"    , "number", 10  , PropIntegerMin(10), "window maximum size (x direction)"},
	{"win_max_w"    , "number", 5000  , PropIntegerMax(5000), "window maximum size (x direction)"},
	{"win_max_h"    , "number", 5000  , PropIntegerMax(5000), "window maximum size (x direction)"},
	{"win_focus"    , "boolean", false, nil, "flag to force-grab all inputs"},

	{"win_delete"   , "boolean", false, nil, "flag to delete window"}
}

function MapEditGUIWindow:define(default_props, layout_def)
	local obj = {
		new = function (self, props, elements, w,h,x,y)
			local this = {
				props = WindowProps(default_props),
				layout = nil,
				elements = {},

				x=0,
				y=0,
				w=w,
				h=h,

				hover = false,
			}

			for i,v in ipairs(elements) do
				this.elements[i] = elements[i]
			end
			for i,v in pairs(props) do
				print(i,v)
				this.props[i]=v
			end

			function this:setX(x)
				local w,h = self.w, self.h
				local winw,winh = love.graphics.getDimensions()
				if x < 0      then x = 0 end
				if x > winw-w then x = winw-w end
				self.x=x end
			function this:setY(y)
				local w,h = self.w, self.h
				local winw,winh = love.graphics.getDimensions()
				if y < 0      then y = 0 end
				if y > winh-h then y = winh-h end
				self.y=y end
			function this:setW(w)
				if w < self.props.win_min_w then w = self.props.win_min_w end
				if w > self.props.win_max_w then w = self.props.win_max_w end
				self.w=w
			end
			function this:setH(h)
				if h < self.props.win_min_h then h = self.props.win_min_h end
				if h > self.props.win_max_h then h = self.props.win_max_h end
				self.h=h
			end

			this:setW(w)
			this:setH(h)

			local winw,winh = love.graphics.getDimensions()
			this.x = x or winw*0.5 - this.w*0.5
			this.y = y or winh*0.5 - this.h*0.5
			this.layout = layout_def:new(this.x,this.y,this.w,this.h,this.elements)

			function this:update()
				if self.layout then
					self.layout:setX(self.x)
					self.layout:setY(self.y)
					self.layout:setW(self.w)
					self.layout:setH(self.h)
					self.layout:updateXywh()
				end
			end

			function this:delete()
				self.props.win_delete = true
				for i,v in ipairs(self.elements) do
					local del = v.delete
					if del then del(v) end
				end
			end

			function this.getCurrentlyHoveredOption(self)
				for i,v in ipairs(self.menus) do
					if v.hover then
						return v
					end
				end
				if self.hover then return self.hover end
			end

			function this:updateHoverInfo()
				local hover = nil
				if self.props.win_focus then
					self.hover = true
					hover = self
				else
					local x,y,w,h = self.x, self.y, self.w, self.h
					local mx,my = love.mouse.getPosition()
					if x<=mx and mx<=x+w and
						 y<=my and my<=y+h
					then
						self.hover = true
						hover = self
					else
						self.hover = false
					end
				end

				for i,v in ipairs(self.elements) do
					if v.updateHoverInfo then
						local h_info = v:updateHoverInfo()
						if h_info then
							hover = h_info
							self.hover = true
						end
					end
				end
				return hover
			end

			function this:getCurrentlyHoveredOption()
				local hover = nil
				for i,v in ipairs(self.elements) do
					if v.hover then
						if v.getCurrentlyHoveredOption then
							local h_info = v:getCurrentlyHoveredOption()
							hover = h_info
						end
					end
				end
				if hover then
					return hover
				end
				if self.hover then return self end
				return nil
			end

			function this:draw()
				local x,y,w,h = self.x,self.y,self.w,self.h
				guirender:drawOption(x,y,w,h, nil, nil, nil, nil, MapEditGUIWindow.buffer_info)
				for i,v in ipairs(self.elements) do
					v:draw()
				end
			end

			function this:action()

			end

			function this:click()
				for i,v in ipairs(self.elements) do
					if v.getCurrentlyHoveredOption then
						h_info = v:getCurrentlyHoveredOption()
						if h_info then
							if h_info.action then
								local e = h_info:action(self)
								return e
							end
						end
					end
				end
			end

			setmetatable(this, MapEditGUIWindow)
			return this
		end}
	return obj
end

return MapEditGUIWindow
