--
-- basic text element gui element
--

local guirender = require 'gui.guidraw'

local MapEditGUITextElement = {
	__type = "mapedittextelement"
}
MapEditGUITextElement.__index = MapEditGUITextElement

function MapEditGUITextElement:new(str,x,y,limit,align,align_x,align_y,format,static)
	assert(str and type(str)=="string")

	local this = {
		x=x,
		y=y,
		w=w,
		h=h,
		limit = limit or 500,
		align = align or "left",
		align_x = align_x or "left",
		align_y = align_y or "top",
		static = static or false,
		text = nil
	}

	-- synonyms
	if this.align == "centre" then this.align="center" end
	if this.align == "middle" then this.align="center" end

	--this.text = guirender:createDrawableText(str)
	if not format then
		this.text = guirender:createDrawableTextLimited(str, this.limit, this.align)
	else
		this.text = guirender:createDrawableText(str)
	end
	this.w,this.h = this.text:getDimensions()

	function this:draw()
		love.graphics.draw(self.text, self.x, self.y)
	end

	function this:updateHoverInfo()
		if self.static then return end

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

	function this.setX(self,x)
		if self.align_x=="middle" then
			self.x = x - self.w*0.5
		elseif self.align_x=="left" then
			self.x = x
		elseif self.align_x=="right" then
			self.x = x - self.w
		else
			self.x = x
		end
		end
	function this.setY(self,y)
		if self.align_y=="middle" then
			self.y = y - self.h*0.5
		elseif self.align_y=="top" then
			self.y = y
		elseif self.align_y=="bottom" then
			self.y = y - self.h
		else
			self.y = y
		end
		end
	function this.setW(self,w)
		end
	function this.setH(self,h) 
		end

	setmetatable(this, MapEditGUITextElement)
	return this
end

return MapEditGUITextElement
