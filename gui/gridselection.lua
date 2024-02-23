--
-- grid selection gui object, used for selecting textures,models etc. from a list
--

local guiscrollb  = require 'gui.scrollbar'
local guirender   = require 'gui.guidraw'

local MapEditGUIGridSelection = {
	grid_w = 32,
	grid_h = 32
}
MapEditGUIGridSelection.__index = MapEditGUIGridSelection

-- each entry in img_table is a table {name,image_data}
function MapEditGUIGridSelection:new(img_table, action)
	local this = {
		x=0,
		y=0,
		w=0,
		h=0,

		table = img_table,
		grid_w = 1,
		grid_h = 1,
		grid_h_offset = 0,
		curr_selection = nil,
		hovered_selection = nil,
		__action = action,

		scrollbar = guiscrollb:new(100),
		scroll_r = 0.0,

		hover = false
	}

	local grid_pix_w = MapEditGUIGridSelection.grid_w
	local grid_pix_h = MapEditGUIGridSelection.grid_h

	function this:update()
		self.scroll_r = self.scrollbar.ratio

		local count = #self.table
		if count==0 then
			self.grid_w = 0
			self.grid_h = 0
		else
			self.grid_w = math.min(count, math.floor(self.w / grid_pix_w))
			self.grid_h = math.ceil(count/self.grid_w)
		end

		if self.grid_h * grid_pix_h <= self.h then
			self.grid_h_offset = 0
		else
			local diff = self.h - (self.grid_h * grid_pix_h)
			self.grid_h_offset = -diff * self.scroll_r
		end

		self.scrollbar:update()
		self:generateText()
	end

	function this:generateText()
		for i,v in ipairs(self.table) do
			if not v.__text then
				local str = v[1]
				if str and str ~= "" then
					local draw_text = guirender:createDrawableText(str)
					v.__text = draw_text
				end
			end
		end
	end

	function this:draw()
		self.scrollbar:draw()

		local x,y,w,h = self.x,self.y,self.w,self.h
		love.graphics.setScissor(x,y,w,h)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",x,y,w,h)

		local h_offset = self.grid_h_offset
		local t = self.table
		local count = #t

		local txt,txt_x,txt_y = nil,nil,nil

		for I=0,count-1 do
			local X,Y = I % self.grid_w,
			            math.floor(I / self.grid_w)
			local i = I+1

			local _x,_y = X*grid_pix_w + x,
			              Y*grid_pix_h - h_offset + y

			local bg_col = nil
			local border_col = nil
			if self.curr_selection == t[i] then
				bg_col = {0.3,0.3,0.3,1}
				border_col = {255/255,157/255,0/255,1}
			else
				bg_col = {0.0,0.0,0.0,1}
				border_col = {0.2,0.2,0.2,1}
			end
			guirender:drawTile(_x,_y,grid_pix_w-1,grid_pix_h-1, bg_col,border_col)

			local img = t[i]
			if img[2] then
				local img_w,img_h = img[2]:getDimensions()
				--[[local Sx,Sy = 1/(img_w/(grid_pix_w-3)),
				              1/(img_h/(grid_pix_h-3))

				if Sy < Sx then
					love.graphics.draw(img[2], _x+1 + (grid_pix_w*(1.0-Sy))*0.5, _y+1, 0, Sy,Sy)
				elseif Sx < Sy then
					love.graphics.draw(img[2], _x+1, _y+1 + (grid_pix_h*(1.0-Sx))*0.5, 0, Sx,Sx)
				else
					love.graphics.draw(img[2], _x+1, _y+1, 0, Sx,Sy)
				end--]]

				local tw,th = img_w,img_h
				local Sx,Sy = tw/(grid_pix_w-3),
											th/(grid_pix_h-3)
				local offsetx = 0
				local offsety = 0

				if Sy > Sx then
					Sx = Sy
					offsetx = (grid_pix_w-3)*0.5 - tw*(0.5/Sx)
				elseif Sx < Sy then
					Sy = Sx
					offsety = (grid_pix_h-3)*0.5 - tw*(0.5/Sy)
				end

				love.graphics.draw(img[2], _x+offsetx+1, _y+offsety+1, 0, 1/Sx,1/Sy)

			end
			if t[i].__text and t[i] == self.hovered_selection then
				-- defer drawing the text to the end, so it isn't drawn over
				-- by other things
				local tw,th = t[i].__text:getDimensions()

				txt,txt_x,txt_y = t[i].__text,_x+grid_pix_w*0.5-tw*0.5,_y+grid_pix_h*0.5-th*0.5
			end
		end

		love.graphics.setScissor()

		if txt then
			local tw,th = txt:getDimensions()
			if txt_x < 0 then txt_x = 0 end
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("fill", txt_x, txt_y, tw, th)
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(txt, txt_x, txt_y)
		end

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
			local X,Y = math.floor(mdx/grid_pix_w),
									math.floor(mdy/grid_pix_h)
			local gw,gh = self.grid_w, self.grid_h
			local I = Y*gw + X + 1

			local hover_selection = self.table[I]
			if hover_selection then
				self.hovered_selection = hover_selection
			else
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
		for i,v in ipairs(self.table) do
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
			self.curr_selection = self.hovered_selection
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
		w = math.floor(w/grid_pix_w)*grid_pix_w
		if w == 0 then w = grid_pix_w end
		self.w = w
		end
	function this.setH(self,h)
		self.scrollbar.h = h
		self.h = h end

	setmetatable(this, MapEditGUIGridSelection)
	return this
end

return MapEditGUIGridSelection
