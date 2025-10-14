--
-- button gui element
--
--

local guirender = require 'gui.guidraw'
local cursor = require 'gui.cursor'

local MapEditGUIButton = {
	__type = "mapeditbutton",
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
	},
	buffer_info_empty = {
		l  = 4,
		r = 0,
		t = 5,
		b = 3,

		arrow_r = 20,
		arrow_t = 1,

		icon_l = 0,
		icon_t = 1,
	}
}
MapEditGUIButton.__index = MapEditGUIButton

function MapEditGUIButton:new(str,icon,x,y,action,align_x,align_y,toggle,start_held, force_w, force_h, text_align)
	assert((str or icon))

	local this = {
		x=x,
		y=y,
		w=0,
		h=0,
		text = str or "",
		bg = nil,
		icon = guirender.icons[icon] or nil,
		action = action,
		hover = false,
		disable = false,
		align_x = align_x or "middle",
		align_y = align_y or "middle",
		held = start_held,
		toggle = toggle,

		draw_mode="default"
	}

	if toggle then
		local toggleable_action = nil
		if action then
			toggleable_action = function(self,win)
				self.held = not self.held
				return action(self,win)
			end
		else
			toggleable_action = function(self,win)
				self.held = not self.held
			end
		end
		this.action = toggleable_action
	end

	function this:generateText(txt)
		self.text = txt or self.text
		if self.text ~= "" then
			self.text = guirender:createDrawableText(self.text)
		else
			self.text = nil
		end

		local text_drawable = self.text
		local icon = self.icon
		local buffer_info = MapEditGUIButton.buffer_info
		local w,h = 0,11
		if text_drawable then w,h = text_drawable:getDimensions() end
		if icon then
			w = w + buffer_info.l + buffer_info.r
		else
			w = w + buffer_info.l_no_icon + buffer_info.r
		end
		h = h + buffer_info.t + buffer_info.b
		self.w = w
		self.h = h

		if force_w then self.w = force_w end
		if force_h then self.h = force_h end

		self.bg = guirender:createContextMenuBackground(self.w,self.h)
	end

	function this:updateHoverInfo()
		local x,y,w,h = self.x, self.y, self.w, self.h
		local mx,my = love.mouse.getPosition()
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			cursor.hand()
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
		local state = "normal"

		if (self.hover and not self.disable) or (self.toggle and self.held) then
			state="hover"
		elseif self.disable then
			state="disable"
		else
			state="normal"
		end
		if self.text then
			guirender:drawGenericOption(self.x,self.y,self.w,self.h, self.bg,self.text,self.icon,nil,state,MapEditGUIButton.buffer_info, text_align)
		else
			if self.draw_mode=="default" then
				guirender:drawGenericOption(self.x,self.y,self.w,self.h, self.bg,self.text,self.icon,nil,state,MapEditGUIButton.buffer_info_empty, text_align)
			else
				guirender:drawCloseButton(self.x,self.y,self.w,self.h, self.text,self.icon,nil,state,MapEditGUIButton.buffer_info_empty)
			end
		end
	end

	function this.setX(self,x)
		if self.align_x == "middle" then
			self.x = x - self.w*0.5
		elseif self.align_x == "left" then
			self.x = x
		else
			self.x = x - self.w
		end
	end
	function this.setY(self,y)
		if self.align_y == "middle" then
			self.y = y - self.h*0.5
		elseif self.align_y == "top" then
			self.y = y
		else
			self.y = y - self.h
		end
	end
	function this.setW(self,w)
		end
	function this.setH(self,h) 
		end

	setmetatable(this, MapEditGUIButton)
	this:generateText()
	return this
end

return MapEditGUIButton
