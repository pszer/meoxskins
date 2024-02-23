--
-- button gui element
--
--

local guirender = require 'gui.guidraw'
require "assetloader"

local MapEditGUIImage = {
	__type = "mapeditimage",
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
MapEditGUIImage.__index = MapEditGUIImage

function MapEditGUIImage:new(img,x,y,w,h,action,align_x,align_y,bg_col)
	local this = {
		x=x,
		y=y,
		w=w,
		h=h,
		img = nil,
		action = action,
		hover = false,
		disable = false,
		bg_col = bg_col,

		align_x = align_x or "middle",
		align_y = align_y or "middle"
	}

	if img then
		if type(img)=="string" then
			local img_ = Loader:getTextureReference(img)
			assert(img_)
			this.img = img_
			if not w and not h then
				this.w,this.h = img_:getDimensions()
			end
		else
			this.img = img
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

	function this:setImage(image)
		if image then
			self.img = image
		end
	end

	function this:getCurrentlyHoveredOption()
		if self.hover then return self end
		return nil
	end

	function this:draw()
		love.graphics.origin()
		if self.bg_col then
			love.graphics.setColor(self.bg_col)
			love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
			love.graphics.setColor(1,1,1,1)
		end

		if self.img then
			local img = self.img
			local tw,th = img:getDimensions()
			local Sx,Sy = tw/(self.w),
										th/(self.h)
			local offsetx = 0
			local offsety = 0

			if Sy > Sx then
				Sx = Sy
				offsetx = self.w*0.5 - tw*(0.5/Sx)
			elseif Sx < Sy then
				Sy = Sx
				offsety = self.h*0.5 - tw*(0.5/Sy)
			end

			local x,y,w,h = self.x,self.y,self.w,self.h
			love.graphics.draw(img, x+offsetx, y+offsety, 0, 1/Sx,1/Sy)
		end
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

	setmetatable(this, MapEditGUIImage)
	return this
end

return MapEditGUIImage
