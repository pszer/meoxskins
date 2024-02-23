local guirender = require 'gui.guidraw'
local MapEditPopup = {
	__type = "mapeditpopup",
	lifetime = 1.5,
}
MapEditPopup.__index = MapEditPopup

function MapEditPopup:throw(str, lifetime, ...)
	local lifetime = lifetime or MapEditPopup.lifetime
	local args = {...}
	local str = string.format(str, unpack(args))
	local txt_obj = guirender:createDrawableText(str)

	local this = {
		__type  = "popup",
		txt_obj = txt_obj,
		bg      = guirender:createContextMenuBackground(txt_obj:getWidth()+4, txt_obj:getHeight()+4),
		creation_time = love.timer.getTime(),
		lifetime = lifetime,

		draw = function(self)
			local x,y = love.mouse.getPosition()
			local w,h = self.bg:getDimensions()
			y=y-h
			local ww,wh = love.graphics.getDimensions()

			if x+w > ww then
				x=ww-w end
			if y > wh then
				y=wh-h end

			love.graphics.draw(self.bg,x,y)
			love.graphics.draw(self.txt_obj,x+2,y+2)
		end,

		expire = function(self)
			return love.timer.getTime()-self.creation_time > self.lifetime
		end,

		release = function(self)
			self.bg:release()
			self.txt_obj:release()
		end
	}

	function this.setX(self,x)
		self.x=x end
	function this.setY(self,y)
		self.y=y end
	function this.setW(self,w)
		end
	function this.setH(self,h)
		end

	setmetatable(this, MapEditPopup)
	return this
end

return MapEditPopup
