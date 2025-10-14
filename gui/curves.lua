--

local guirender   = require 'gui.guidraw'

local cubiccurve  = require 'cubiccurve'

local EditGUICurves = {
	null_texture = love.graphics.newCanvas(1,1),
}
EditGUICurves.__index = EditGUICurves

-- each entry in img_table is a table {name,image_data}
function EditGUICurves:new(wS,hS, curves_change_hook, histograms, action)
	local this = {
		x=0,
		y=0,
		w=256,
		h=256,

		sample_count = 256,

		curves_change_hook = curves_change_hook,

		active_channel = "value",
		drag_index   = nil,

		value = {x={0.0,1.0},y={0.0,1.0},samples={},get_sample=nil},
		red   = {x={0.0,1.0},y={0.0,1.0},samples={},get_sample=nil},
		green = {x={0.0,1.0},y={0.0,1.0},samples={},get_sample=nil},
		blue  = {x={0.0,1.0},y={0.0,1.0},samples={},get_sample=nil},

		__action = action,

		__start_mx=0,
		__start_my=0,

		hover = false,

		curve_samples = {}
	}

	_,this.value.get_sample = cubiccurve.generate(this.value.x, this.value.y, this.sample_count, this.value.samples, true)
	_,this.red.get_sample = cubiccurve.generate(this.red.x, this.red.y, this.sample_count, this.red.samples, true)
	_,this.green.get_sample = cubiccurve.generate(this.green.x, this.green.y, this.sample_count, this.green.samples, true)
	_,this.blue.get_sample = cubiccurve.generate(this.blue.x, this.blue.y, this.sample_count, this.blue.samples, true)

	function this:update()
		local status = scancodeIsUp("mouse1", CONTROL_LOCK.META)
		if status then
			self.drag_index = nil
		end

		if self.drag_index then
			local x,y = love.mouse.getPosition()
			if self.curves_change_hook then self:curves_change_hook() end

			x = (x - self.x)/self.w
			y = 1.0 - (y-self.y)/self.h
			local state = self:movePoint(self.active_channel, self.drag_index, x,y)

			if not state and #self[self.active_channel].x > 2 then
				self:removePoint(self.active_channel, self.drag_index)
				self.drag_index = nil
			end

			local c = self[self.active_channel]
			_,c.get_sample = cubiccurve.generate(c.x,c.y,self.sample_count,c.samples, true)
		end

		-- update positions for colour picker elements
		local Sx,Sy,Sw,Sh = self.x,self.y,self.w,self.h
	end

	function this:setActiveChannel(c)
		if c ~= "value" or c ~= "red" or c~="green" or c~="blue" then self.active_channel="value" end
	end

	function this:draw()
		local x,y,w,h = math.floor(self.x),math.floor(self.y),self.w,self.h

		love.graphics.reset()
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle("smooth")
		love.graphics.setColor(0.8,0.8,0.8,1)
		love.graphics.rectangle("fill",x-1,y-1,w+2,h+2)

		love.graphics.reset()

		love.graphics.setColor(0.21,0.21,0.21,1)
		love.graphics.rectangle("fill",x,y,w,h)
		love.graphics.setColor(0.8,0.8,0.8,0.8)

		love.graphics.line(x+w/4, y, x+w/4, y+h)
		love.graphics.line(x+w/2, y, x+w/2, y+h)
		love.graphics.line(x+3*w/4, y, x+3*w/4, y+h)
		love.graphics.line(x, y+h/4, x+w, y+h/4)
		love.graphics.line(x, y+h/2, x+w, y+h/2)
		love.graphics.line(x, y+3*h/4, x+w, y+3*h/4)

		love.graphics.setBlendMode("add")

		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle("smooth")
		local segment_w = 4
		local vy0=0,0
		local ry0=0,0
		local gy0=0,0
		local by0=0,0
		for i=0,w,segment_w do
			vy = math.max(0.0,math.min(1.0,self.value.get_sample(i/w)))
			ry = math.max(0.0,math.min(1.0,self.red.get_sample(i/w)))
			gy = math.max(0.0,math.min(1.0,self.green.get_sample(i/w)))
			by = math.max(0.0,math.min(1.0,self.blue.get_sample(i/w)))

			if i>0 then
				love.graphics.setColor(0.8,0.8,0.8,1)
				love.graphics.line(x+i-segment_w,y-vy0*self.h+self.h,x+i,y+-vy*self.h+self.h)
				love.graphics.setColor(1,0,0,1)
				love.graphics.line(x+i-segment_w,y-ry0*self.h+self.h,x+i,y+-ry*self.h+self.h)
				love.graphics.setColor(0,1,0,1)
				love.graphics.line(x+i-segment_w,y-gy0*self.h+self.h,x+i,y+-gy*self.h+self.h)
				love.graphics.setColor(0,0,1,1)
				love.graphics.line(x+i-segment_w,y-by0*self.h+self.h,x+i,y+-by*self.h+self.h)
			end

			vy0,ry0,gy0,by0=vy,ry,gy,by
		end

		love.graphics.setBlendMode("alpha")

		love.graphics.setColor(0.87,0.87,0.87,1)
		local X,Y = self[self.active_channel].x,self[self.active_channel].y
		for i=1,#self[self.active_channel].x do
			--love.graphics.rectangle("fill",x + X[i]*w-2, y + h - Y[i]*h-2, 4, 4)
			love.graphics.circle("line",x+X[i]*w, y+h - Y[i]*h,6,16)
		end

		love.graphics.reset()
	end

	-- returns index
	function this:testPointClick(channel, mx, my, range)
		if type(channel) == "string" then
			channel = self[channel] -- value,red,green,blue
		end
		local x = (mx-self.x)/self.w
		local y = 1.0-(my-self.y)/self.h
		range = range or 8
		for i,v in ipairs(channel.x) do
				local diffX = math.abs(x - v)
				local diffY = math.abs(y - channel.y[i])

				if diffX <= range/self.w and diffY <= range/self.h then
					return i
				end
		end
		return nil
	end

	function this:addPoint(channel, X,Y)
		if type(channel) == "string" then
			channel = self[channel] -- value,red,green,blue
		end

		local index = 1
		while index <= #channel.x do
			if channel.x[index] == X then return end
			if channel.x[index] > X then break end
			index = index + 1
		end

		table.insert(channel.x, index, X)
		table.insert(channel.y, index, Y)
		return index
	end

	function this:removePoint(channel, index)
		if type(channel) == "string" then
			channel = self[channel] -- value,red,green,blue
		end

		if #channel.x <= 2 then return end

		table.remove(channel.x, index)
		table.remove(channel.y, index)
	end

	-- returns false if out of range
	function this:movePoint(channel, index, newX, newY)
		if type(channel) == "string" then
			channel = self[channel] -- value,red,green,blue
		end

		if index-1 >= 1 and channel.x[index-1] >= newX then return false end
		if index+1 <= #channel.x and channel.x[index+1] <= newX then return false end

		channel.x[index]=math.max(0.0,math.min(1.0,newX))
		channel.y[index]=math.max(0.0,math.min(1.0,newY))
		return true
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

		if self.hover then
			local index = self:testPointClick(self.active_channel, mx, my, 20)
			if index then
				self.drag_index = index
				self.drag_point = true
			else
				local x = (mx-self.x)/self.w
				local y = 1.0-(my-self.y)/self.h
				self.drag_index = self:addPoint(self.active_channel, x, y)
				self.drag_point = true
			end
		end
	end

	function this.setX(self,x)
		self.x = x end
	function this.setY(self,y)
		self.y = y end
	function this.setW(self,w)
		self.w = math.floor(w * wS) end
	function this.setH(self,h)
		self.h = math.floor(h * hS) end

	setmetatable(this, EditGUICurves)
	return this
end

return EditGUICurves
