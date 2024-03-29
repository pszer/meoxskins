--
-- gui scrollbar object
--

local guirender = require 'gui.guidraw'

local MapEditGUIScrollbar = {}
MapEditGUIScrollbar.__index = MapEditGUIScrollbar

require "input"

function MapEditGUIScrollbar:new(h)
	local this = {
		x=0,
		y=0,
		w=20,
		h=h,
		ratio = 0.0,
		drag=false,

		__start_mx=0,
		__start_my=0,
		__start_ratio = 0.0,

		hover=false
	}

	function this:update()
		local status = scancodeIsUp("mouse1", CONTROL_LOCK.META)
		if status then
			self.drag = false
		end

		if self.drag then
			local x,y = love.mouse.getPosition()
			local H = self.h-20
			local r = (y - self.__start_my) / H + self.__start_ratio
			if r < 0 then r = 0 end
			if r > 1 then r = 1 end
			self.ratio = r
		end
	end

	function this:updateHoverInfo()
		local x,y,w,h = self.x, self.y, self.w, self.h
		local mx,my = love.mouse.getPosition()
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			self.hover = true
			return self
		end
		self.hover = false
		return nil
	end

	function this:getCurrentlyHoveredOption()
		if self.hover then return self end
		return nil
	end

	function this:draw()
		guirender:drawScrollBar(self.x,self.y,self.h,self.ratio)
	end

	function this:action()
		self.drag = true

		self.__start_mx,self.__start_my = love.mouse.getPosition()
		local r = (self.__start_my-self.y-10)/(self.h-20)
		if r < 0 then r = 0 end
		if r > 1 then r = 1 end
		self.__start_ratio = r
	end

	function this.setX(self,x)
		self.x = x end
	function this.setY(self,y)
		self.y = y end
	function this.setW(self,w)
		end
	function this.setH(self,h) 
		self.h = h end

	setmetatable(this, MapEditGUIScrollbar)
	return this
end

return MapEditGUIScrollbar
