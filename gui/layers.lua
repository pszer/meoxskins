--
-- grid selection gui object, used for selecting textures,models etc. from a list
--

local guiscrollb  = require 'gui.scrollbar'
local guirender   = require 'gui.guidraw'
local cursor      = require 'gui.cursor'

local EditGUILayers = {
	layer_w = 280,
	layer_h = 66
}
EditGUILayers.__index = EditGUILayers

-- each entry in img_table is a table {name,image_data}
function EditGUILayers:new(get_layers, get_active, set_active)
	local this = {
		x=0,
		y=0,
		w=0,
		h=0,

		table = get_layers,
		grid_w = 100,
		grid_h = 1,
		grid_h_offset = 0,
		curr_selection = nil,
		hovered_selection = nil,
		__action = action,

		scrollbar = guiscrollb:new(66),
		scroll_r = 0.0,

		hover = false
	}

	local grid_pix_w = EditGUILayers.layer_w
	local grid_pix_h = EditGUILayers.layer_h

	function this:update()
		self.scroll_r = self.scrollbar.ratio

		local count = #self.table()
		self.grid_h = #self.table()

		if self.grid_h * grid_pix_h <= self.h then
			self.grid_h_offset = 0
		else
			local diff = self.h - (self.grid_h * grid_pix_h)
			self.grid_h_offset = -diff * self.scroll_r
		end

		local scrlb = self.scrollbar
		scrlb:setX(self.x + self.w)
		scrlb:setY(self.y)
		scrlb:setH(self.h)

		self.scrollbar:update()
		self:generateText()
		self:updateText()
	end

	function this:generateText()
		for i,v in ipairs(self.table()) do
			if not v.__text then
				local str = v.name
				if str and str ~= "" then
					v.__last_name = str
					local draw_text = guirender:createDrawableText(str)
					v.__text = draw_text
				end
			end
		end
	end

	function this:updateText()
		for i,v in ipairs(self.table()) do
			local str = v.name
			if str and str ~= v.__last_name then
				v.__last_name = str
				local draw_text = guirender:createDrawableText(str)
				v.__text = draw_text
			end
		end
	end

	function this:draw()
		self.scrollbar:draw()

		local x,y,w,h = self.x,self.y,self.w,self.h
		love.graphics.setScissor(x,y,w,h)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",x,y,w,h)

		local h_offset = math.floor(self.grid_h_offset)
		local t = self.table()
		local count = #t

		local txt,txt_x,txt_y = nil,nil,nil

		for I=0,count-1 do
			local X,Y = 0,
			            I

			local _x,_y = X*grid_pix_w + x,
			              Y*grid_pix_h - h_offset + y

			local bg_col = nil
			local border_col = nil
			if get_active() == t[count-I] then
				bg_col = {0.3,0.3,0.3,1}
				border_col = {255/255,157/255,0/255,1}
			else
				bg_col = {0.0,0.0,0.0,1}
				border_col = {0.2,0.2,0.2,1}
			end
			guirender:drawTile(_x+1,_y,grid_pix_w-2,grid_pix_h-1, bg_col,border_col)

			local layer = t[count-I]
			local img = layer.texture
			if img then
				love.graphics.draw(img, _x+2, _y+1)
			end
			if layer.__text then
				-- defer drawing the text to the end, so it isn't drawn over
				-- by other things
				local tw,th = t[count-I].__text:getDimensions()

				txt,txt_x,txt_y = t[count-I].__text,_x+80,_y+26

				if txt then
					local tw,th = txt:getDimensions()
					if txt_x < 0 then txt_x = 0 end
					love.graphics.draw(txt, txt_x, txt_y)
				end
			end

			local visible = t[count-I].visible
			if visible then
				love.graphics.draw(guirender.__visible, _x+grid_pix_w-54,_y)
			else
				love.graphics.draw(guirender.__invisible, _x+grid_pix_w-54,_y)
			end

			local edit = require 'edit' 
			local override = edit.alpha_lock_override
			local alpha_lock = t[count-I].alpha_lock
			if override then
				love.graphics.draw(guirender.__alphalock_override, _x+grid_pix_w-80,_y-1)
			elseif alpha_lock then
				love.graphics.draw(guirender.__alphalock, _x+grid_pix_w-80,_y-1)
			else
				love.graphics.draw(guirender.__alphalock_off, _x+grid_pix_w-80,_y-1)
			end
		end

		love.graphics.setScissor()
	end

	function this:updateHoverInfo()
		local scrlb = self.scrollbar
		scrlb:setX(self.x + self.w)
		scrlb:setY(self.y)
		scrlb:setH(self.h)

		local scrlb_w,scrlb_h = scrlb.w,scrlb.h
		local mx,my = love.mouse.getPosition()

		local hover = scrlb:updateHoverInfo()
		if hover then
			self.hover = true
			self.hovered_selection = nil
			return scrlb
		end

		local x,y,w,h = self.x, self.y, self.w, self.h
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			self.hover = true

			local mdx,mdy = mx-self.x,my-self.y+self.grid_h_offset
			local Y = math.floor(mdy/self.layer_h)
			local I = #self.table() - Y

			local hover_selection = self.table()[I]
			if hover_selection then
				self.hovered_selection = hover_selection

				local X = self.x
				local h_offset = self.grid_h_offset
				local _x,_y = X,
											Y*grid_pix_h - h_offset + y
				if mx >= _x+grid_pix_w-42+12 and mx <= _x+grid_pix_w-22+12 and
				   my >= _y+17 and my <= _y+41 then
					 cursor.hand()
					 self.hovered_visible_icon = true
				else
					self.hovered_visible_icon = false
				end
				if mx >= _x+grid_pix_w-42+12-26 and mx <= _x+grid_pix_w-22+12-26 and
				   my >= _y+17 and my <= _y+41 then
					 cursor.hand()
					 self.hovered_alphalock_icon = true
				else
					self.hovered_alphalock_icon = false
				end
			else
				self.hovered_visible_icon = false
				self.hovered_selection = nil
			end

			return self
		end
		self.hover = false
		self.hovered_selection = nil
		return nil
	end

	function this:getCurrentlyHoveredOption()
		if self.scrollbar.hover then return self.scrollbar end
		if self.hover then return self end
		return nil
	end

	function this:click()
		local mx,my = love.mouse.getPosition()
	end

	-- gets the currently selected option in the grid
	-- makes sure that the selected option still exists
	-- inside the list of possible options
	function this:getGridSelectedObject()
		for i,v in ipairs(self.table()) do
			if v==self.curr_selection then
				return self.curr_selection
			end
		end
		-- the current selection no longer exists in the grid
		self.curr_selection = nil
	end

	function this:action()
		local mx,my = love.mouse.getPosition()
		if self.scrollbar.hover then
			self.scrollbar:action()
			return
		elseif self.hover and self.hovered_selection then
			if not (self.hovered_visible_icon or self.hovered_alphalock_icon) then
				set_active(self.hovered_selection)
			else
				if self.hovered_visible_icon then
					self.hovered_selection.visible = not self.hovered_selection.visible
				else
					self.hovered_selection.alpha_lock = not self.hovered_selection.alpha_lock
				end
			end
		end

		if self.__action then
			self.__action(self)
		end
	end

	function this.setX(self,x)
		self.x = x end
	function this.setY(self,y)
		self.y = y end
	function this.setW(self,w)
		self.w = w-20
		grid_pix_w = w-20
		--w = math.floor(w/grid_pix_w)*grid_pix_w
		--if w == 0 then w = grid_pix_w end
		end
	function this.setH(self,h)
		self.scrollbar.h = h
		self.h = h end

	setmetatable(this, EditGUILayers)
	return this
end

return EditGUILayers
