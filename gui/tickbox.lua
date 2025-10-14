--
-- tickbox gui element
--
--

local guirender = require 'gui.guidraw'

local MapEditTickbox = {
	__type = "mapedittickbox",
	buffer_info = {
		l  = 19,
		r = 8,
		t = 5,
		b = 3,
	}
}
MapEditTickbox.__index = MapEditTickbox

function MapEditTickbox:new(str,x,y,appearance,action,start,disable)
	assert((str or icon))

	local this = {
		x=x,
		y=y,
		w=0,
		h=0,
		appearance = appearance or "tick",
		text = str or "",
		action = action,
		hover = false,
		disable = disable,
		state = start,
		toggle = toggle
	}

	if this.appearance ~= "tick" then
		this.appearance = "dot"
	end

	local toggleable_action = nil
	if action then
		toggleable_action = function(self,win)
			if not self.disable then
				self.state = not self.state
			end
			return action(self,win)
		end
	else
		toggleable_action = function(self,win)
			self.state = not self.state
		end
	end
	this.action = toggleable_action

	if this.text ~= "" then
		this.text = guirender:createDrawableText(str)
	end

	local text_drawable = this.text
	local buffer_info = MapEditTickbox.buffer_info
	local w,h = text_drawable:getDimensions()
	w = w + buffer_info.l
	h = h + buffer_info.t + buffer_info.b
	this.w = w
	this.h = h

	if this.appearance == "dot" then this.h = this.h+1 end

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
		local graphic = "__"
		if self.appearance == "tick" then
			graphic = graphic .. "tick_"
		else graphic = graphic .. "sel_"
		end
		if self.state then
			graphic = graphic .. "on"
		else graphic = graphic .. "off"
		end
		if self.disable then
			graphic = graphic .. "_d"
		end

		graphic = guirender[graphic]

		love.graphics.reset()
		local h_pad = 2
		if self.appearance == "dot" then h_pad = h_pad + 1 end
		if self.disable then
			love.graphics.setColor(0.8,0.8,0.8,0.8)
			love.graphics.draw(self.text,self.x + buffer_info.l,self.y+h_pad)
			love.graphics.setColor(1,1,1,1)
		else
			love.graphics.draw(self.text,self.x + buffer_info.l,self.y+h_pad)
		end

		love.graphics.draw(graphic,self.x,self.y)
		if self.hover and not self.disable then
			love.graphics.setBlendMode("add")
			love.graphics.setColor(1,1,1,0.3)
			love.graphics.draw(graphic,self.x,self.y)
			love.graphics.setBlendMode("alpha")
		end
	end

	function this.setX(self,x)
		self.x = x
	end
	function this.setY(self,y)
		self.y = y
	end
	function this.setW(self,w)
		end
	function this.setH(self,h) 
		end

	setmetatable(this, MapEditTickbox)
	return this
end

return MapEditTickbox
