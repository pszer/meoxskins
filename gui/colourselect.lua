--

require "assetloader"

local guirender   = require 'gui.guidraw'

local EditGUIColorSelect = {
	pad = 12,

	null_texture = love.graphics.newCanvas(1,1),

	colourpicker_shader = love.graphics.newShader("colourpicker.glsl","colourpicker.glsl"),
	colourhue_shader = love.graphics.newShader("colourpicker_hue.glsl","colourpicker_hue.glsl"),
	colouractive_shader = love.graphics.newShader("colourpicker_colour.glsl","colourpicker_colour.glsl"),
	colouralpha_shader = love.graphics.newShader("colourpicker_alpha.glsl","colourpicker_alpha.glsl"),
}
EditGUIColorSelect.__index = EditGUIColorSelect

local function hslToRgb(h, s, l)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l
  else
    function hue2rgb(p, q, t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function rgbToHsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local maxVal = math.max(r, g, b)
  local minVal = math.min(r, g, b)

  local h, s, l = 0, 0, (maxVal + minVal) / 2

  if maxVal ~= minVal then
    local d = maxVal - minVal
    s = l > 0.5 and d / (2 - maxVal - minVal) or d / (maxVal + minVal)

    if maxVal == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif maxVal == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end

    h = h / 6
  end

  return h, s, l
end

-- each entry in img_table is a table {name,image_data}
function EditGUIColorSelect:new(colour_change_hook, action)
	local this = {
		x=0,
		y=0,
		w=0,
		h=0,

		colour_x = 0,
		colour_y = 0,
		colour_w = 0,
		colour_h = 0,

		hue_x = 0,
		hue_y = 0,
		hue_w = 20,
		hue_h = 0,

		alpha_x = 0,
		alpha_y = 0,
		alpha_w = 20,
		alpha_h = 0,

		active_x = 0,
		active_y = 0,
		active_w = 0,
		active_h = 0,

		colour_change_hook = colour_change_hook,

		hovered_selection = nil,
		__action = action,

		curr_col = {1,1,1,1},

		curr_sat = 0.5,
		curr_lum = 0.5,
		curr_hue = 0.5,
		curr_alpha = 1.0,

		__start_mx=0,
		__start_my=0,
		__start_ratio = 0.0,

		drag_colour = false,
		drag_hue    = false,
		drag_alpha  = false,

		hover_hue    = false,
		hover_alpha  = false,
		hover_colour = false,

		hover = false
	}

	function this:update()
		local status = scancodeIsUp("mouse1", CONTROL_LOCK.META)
		if status then
			self.drag_colour = false
			self.drag_hue = false
			self.drag_alpha = false
		end

		if self.drag_hue then
			local x,y = love.mouse.getPosition()
			local H = self.hue_h
			local r = (y - self.__start_my) / H + self.__start_ratio
			if r < 0 then r = 0 end
			if r > 1 then r = 1 end
			--self.ratio = r
			self.curr_hue = r
			if self.colour_change_hook then self:colour_change_hook() end
		end

		if self.drag_alpha then
			local x,y = love.mouse.getPosition()
			local H = self.alpha_h
			local r = (y - self.__start_my) / H + self.__start_ratio
			if r < 0 then r = 0 end
			if r > 1 then r = 1 end
			self.curr_alpha = 1.0-r
			if self.colour_change_hook then self:colour_change_hook() end
		end

		if self.drag_colour then
			local x,y = love.mouse.getPosition()
			local sat = (x-self.colour_x) / self.colour_w
			local lum = 1.0 - (y-self.colour_y) / self.colour_h
			if sat < 0.0 then sat = 0.0 end
			if lum < 0.0 then lum = 0.0 end
			if sat > 1.0 then sat = 1.0 end
			if lum > 1.0 then lum = 1.0 end
			self.curr_sat = sat
			self.curr_lum = lum
			if self.colour_change_hook then self:colour_change_hook() end
		end

		-- update positions for colour picker elements
		local Sx,Sy,Sw,Sh = self.x,self.y,self.w,self.h

		self.colour_x = self.pad + self.x
		self.colour_y = self.pad + self.y
		self.colour_w = Sw - 4 * (self.pad) - self.hue_w - self.alpha_w
		self.colour_h = Sh - 2 * (self.pad)

		self.active_x = self.colour_x + self.colour_w + self.pad
		self.active_y = self.pad + Sy
		self.active_w = self.hue_w + self.alpha_w + self.pad
		self.active_h = self.active_w

		self.hue_x = self.colour_x + self.colour_w + self.pad
		self.hue_y = self.active_y + self.active_h + self.pad
		self.hue_w = self.hue_w
		self.hue_h = Sh - self.active_h - 3 * self.pad

		self.alpha_x = self.colour_x + self.colour_w + self.hue_w + 2*self.pad
		self.alpha_y = self.active_y + self.active_h + self.pad
		self.alpha_w = self.alpha_w
		self.alpha_h = Sh - self.active_h - 3 * self.pad
		
		this:updateColour()
	end

	function this:draw()
		local x,y,w,h = self.x,self.y,self.w,self.h

		guirender:drawInset(self.colour_x, self.colour_y, self.colour_w, self.colour_h)
		guirender:drawInset(self.hue_x, self.hue_y, self.hue_w, self.hue_h)
		guirender:drawInset(self.alpha_x, self.alpha_y, self.alpha_w, self.alpha_h)
		guirender:drawInset(self.active_x, self.active_y, self.active_w, self.active_h)

		love.graphics.reset()
		love.graphics.setShader(self.colourpicker_shader)
		self.colourpicker_shader:send("hue",self.curr_hue*360.0)
		love.graphics.draw(self.null_texture, self.colour_x, self.colour_y, 0, self.colour_w, self.colour_h)

		love.graphics.setShader(self.colourhue_shader)
		love.graphics.draw(self.null_texture, self.hue_x, self.hue_y, 0, self.hue_w, self.hue_h)

		love.graphics.setShader(self.colouractive_shader)
		self.colouractive_shader:send("colour", self.curr_col)
		love.graphics.draw(self.null_texture, self.active_x+self.active_w/2, self.active_y, 0, self.active_w/2, self.active_h)
		local C = {self.curr_col[1],self.curr_col[2],self.curr_col[3],1.0}
		self.colouractive_shader:send("colour", C)
		love.graphics.draw(self.null_texture, self.active_x, self.active_y, 0, self.active_w/2, self.active_h)

		love.graphics.setShader(self.colouralpha_shader)
		self.colouralpha_shader:send("hue", self.curr_hue*360.0)
		self.colouralpha_shader:send("sat", self.curr_sat)
		self.colouralpha_shader:send("lum", self.curr_lum)
		love.graphics.draw(self.null_texture, self.alpha_x, self.alpha_y, 0, self.alpha_w, self.alpha_h)

		love.graphics.setShader()

		love.graphics.draw(guirender.__bar, self.hue_x-3, self.hue_y + self.hue_h*self.curr_hue-2)
		love.graphics.draw(guirender.__bar, self.alpha_x-3, self.alpha_y + self.alpha_h*(1.0-self.curr_alpha)-2)

		local X = self.colour_x + self.colour_w * self.curr_sat
		local Y = self.colour_y + self.colour_h * (1.0-self.curr_lum)
		love.graphics.setLineStyle("rough")
		love.graphics.setColor(0,0,0,0.8)
		love.graphics.setLineWidth(0.5)
		love.graphics.line(self.colour_x, Y, self.colour_x+self.colour_w, Y)
		love.graphics.line(X, self.colour_y, X, self.colour_y+self.colour_h)
		love.graphics.setLineWidth(0.5)
		love.graphics.setColor(0,0,0,0.8)
		love.graphics.line(self.colour_x, Y-2, self.colour_x+self.colour_w, Y-2)
		love.graphics.line(X-2, self.colour_y, X-2, self.colour_y+self.colour_h)
		love.graphics.setLineWidth(1.0)
		love.graphics.setColor(1,1,1,1)
		love.graphics.line(self.colour_x, Y-1, self.colour_x+self.colour_w, Y-1)
		love.graphics.line(X-1, self.colour_y, X-1, self.colour_y+self.colour_h)
		love.graphics.reset()
	end

	function this:updateHoverInfo()
		self:update()

		local mx,my = love.mouse.getPosition()

		local function test_rect(x,y, X,Y,W,H)
			return x >= X and x<= X+W and
			       y >= Y and y<= Y+H
		end

		local x,y,w,h = self.x, self.y, self.w, self.h
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			self.hover = true
		else
			self.hover = false
			return nil
		end

		self.hover_colour = false
		self.hover_hue = false
		self.hover_alpha = false
		if test_rect(mx,my, self.colour_x, self.colour_y, self.colour_w, self.colour_h) then
			self.hover_colour = true
		elseif test_rect(mx,my, self.hue_x, self.hue_y, self.hue_w, self.hue_h) then
			self.hover_hue = true
		elseif test_rect(mx,my, self.alpha_x, self.alpha_y, self.alpha_w, self.alpha_h) then
			self.hover_alpha = true
		end

		if self.hover then return self end
	end

	function this:getCurrentlyHoveredOption()
		if self.hover then return self end
		return nil
	end

	function this:click()
		local mx,my = love.mouse.getPosition()
	end

	function this:action()
		local mx,my = love.mouse.getPosition()

		if self.__action then
			self.__action(self)
		end

		if self.hover_hue then
			self.__start_mx,self.__start_my = love.mouse.getPosition()
			local r = (self.__start_my-self.hue_y)/(self.hue_h)
			if r < 0 then r = 0 end
			if r > 1 then r = 1 end
			self.__start_ratio = r
			self.drag_hue = true
		end

		if self.hover_alpha then
			self.__start_mx,self.__start_my = love.mouse.getPosition()
			local r = (self.__start_my-self.alpha_y)/(self.alpha_h)
			if r < 0 then r = 0 end
			if r > 1 then r = 1 end
			self.__start_ratio = r
			self.drag_alpha = true
		end

		if self.hover_colour then
			self.drag_colour = true
		end
	end

	function this.setX(self,x)
		self.x = x end
	function this.setY(self,y)
		self.y = y end
	function this.setW(self,w)
		self.w = w end
	function this.setH(self,h)
		self.h = h end

	function this:getColour()
		return self.curr_col
	end
	function this:setRGBColour(r,g,b)
		local h,s,l = rgbToHsl(r,g,b)
		self.curr_hue = h
		self.curr_sat = s
		self.curr_lum = l
		this:updateColour()
	end

	function this:updateColour()
		local R,G,B = hslToRgb(self.curr_hue, self.curr_sat, self.curr_lum)
		self.curr_col[1] = R/255
		self.curr_col[2] = G/255
		self.curr_col[3] = B/255
		self.curr_col[4] = self.curr_alpha
	end

	setmetatable(this, EditGUIColorSelect)
	return this
end

return EditGUIColorSelect
