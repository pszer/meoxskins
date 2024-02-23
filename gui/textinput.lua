--
-- text input gui element
--

local guirender = require 'gui.guidraw'
local utf8 = require("utf8")

local MapEditGUITextInput
MapEditGUITextInput = {
	__type = "mapedittextinput",
	__maketextinputhook = nil,
	__deltextinputhook  = nil,

	buffer_info = {
		l = 4,
		r = 6,
		t = 5,
		b = 3,
	},
	sel_col={255/255,161/255,66/255,1.0},
	unsel_col={1,1,1,0.2},

	identity_validator = function(str)
		return str
	end,
	identity_format_func = function(str)
		return str
	end,

	int_validator = function(str)
		local extract = string.match(str,"^[-+]?%d+$")
		if not extract then return nil end
		local num = tonumber(extract)
		return num
	end,
	int_format_func = function(str)
		local result = nil
		local d = string.sub(str,utf8.offset(str,2) or 1,-1)
		local s = string.sub(str,1,(utf8.offset(str,2) or 1)-1)
		if not string.match(s,"[-+%d]") then
			result = string.format("~(red)%s~r",s)
		else
			result = s or ""
		end
		local red = false
		for char in string.gmatch(d,utf8.charpattern) do
			if not string.match(char,"%d") then
				if not red then
					result = result .. "~(red)" .. char
				else
					result = result .. char
				end
				red = true
			else
				result = result .. char
			end
		end
		return result
	end,

	float_validator = function(str)
		local extract = string.match(str,"^[-+]?%d+%.?%d-$")
		if not extract then return nil end
		local num = tonumber(extract)
		return num
	end,
	float_format_func = function(str)
		local result = nil
		local d = string.sub(str,utf8.offset(str,2) or 1,-1)
		local s = string.sub(str,1,(utf8.offset(str,2) or 1)-1)
		if not string.match(s,"[-+%d]") then
			result = string.format("~(red)%s~r",s)
		else
			result = s or ""
		end
		local red = false
		local point_count=0
		for char in string.gmatch(d,utf8.charpattern) do
			if not string.match(char,"[%d%.]") then
				if not red then
					result = result .. "~(red)"
				end
				result = result .. char
				red = true
			elseif char == "." then
				point_count=point_count+1
				if point_count==2 then
					if not red then
						result = result .. "~(red)"
					end
					red = true
				end
				result = result .. char
			else
				result = result .. char
			end
		end
		return result
	end,

	hexcol_validator = function(str)
		for p,c in utf8.codes(str) do
			if p==1 then
				local e = string.match(c,"[%x#]")
				if not e then return nil end
			else
				local e = string.match(c,"[%x]")
				if not e then return nil end
			end
		end

		local extract = string.match(str,"%x+")
		if not extract then return nil end

		local e_str_len = utf8.len(extract)
		if e_str_len ~= 6 then return nil end
		
		local Rs,Gs,Bs = string.sub(extract,1,2), string.sub(extract,3,4), string.sub(extract,5,6)
		local r,g,b = tonumber(Rs,16), tonumber(Gs,16), tonumber(Bs,16)
		return {r,g,b}
	end,

	hexcol_format_func = function(str)
		local result = ""
		local count = 0
		for p,c in utf8.codes(str) do
			if p==1 then
				local e = string.match(c,"[%x#]")
				if not e then
					result = result .. "~(red)" .. c
				else
					if c ~= "#" then count = count+1 end
				end
			else
				local e = string.match(c,"[%x]")
				if not e or count > 6 then
					result = result .. "~(red)" .. c
				end
				count = count + 1
			end
		end

		return result
	end,

	rational_validator = function(str)
		local div_pos = nil
		for p,c in utf8.codes(str) do
			local char=utf8.char(c)
			if char=="/" then
				div_pos=p
				break
			end
		end

		if not div_pos then
			local extract = string.match(str,"^[-+]?%d+%.?%d-$")
			if not extract then return nil end
			local num = tonumber(extract)
			return num
		end

		local str_len = utf8.len(str)
		local a,b = string.sub(str,1,div_pos-1),
		            string.sub(str,div_pos+1,-1)
		if not a or a=="" then return nil end

		local extract_a = string.match(a,"^[-+]?%d+%.?%d-$")
		if not extract_a then return nil end

		local num, denom = tonumber(extract_a), nil
		if not num then return nil end

		local extract_b = string.match(b,"^[-+]?%d+%.?%d-$")
		if not extract_b then
			if b=="" then denom=1.0
			         else return nil end
		else
			denom = tonumber(extract_b)
			if not denom then return nil end
			if denom==0.0 or denom==-0.0 then return nil end
		end
		return num/denom
	end,
	rational_format_func = function(str)
		local div_pos = nil
		for p,c in utf8.codes(str) do
			local char=utf8.char(c)
			if char=="/" then
				div_pos=p
				break
			end
		end

		if not div_pos then
			return MapEditGUITextInput.float_format_func(str)
		end

		local result = ""

		local a,b = string.sub(str,1,div_pos-1),
		            string.sub(str,div_pos+1,-1)
		if not (not a or a=="") then
			result = MapEditGUITextInput.float_format_func(a)
		end
		result = result .. "~r/"
		if not (not b or b=="") then
			local B = tonumber(b)
			if B and B==0.0 then
				result = result .. "~(red)" .. b
			else
				result = result .. MapEditGUITextInput.float_format_func(b)
			end
		else
			result = result .. "~(lblue)1.0"
		end

		return result
	end,

	string_table_validator = function(str,table,access)
		local access = access or function(x) return x end
		return function(str)
			for i,v in ipairs(table) do
				local s = access(v)
				if str == s then return str end
			end
			return nil
		end
	end,
	string_table_format_func = function(str,table,access)
		local access = access or function(x) return x end
		return function(str)
			for i,v in ipairs(table) do
				local s = access(v)
				if str == s then return str end
			end
			return "~(red)"..str
		end
	end,
}
MapEditGUITextInput.__index = MapEditGUITextInput

function MapEditGUITextInput:setup(make,del)
	self.__maketextinputhook=make
	self.__deltextinputhook=del
end

function MapEditGUITextInput:new(init_str,x,y,w,h,validator,format_func,align_x,align_y,input_hook)
	assert(type(init_str)=="string")

	assert(self.__maketextinputhook and self.__deltextinputhook,
		"MapEditGUITextInput:new(): text input hook make/delete function not set yet, please use MapEditGUITextInput:setup()")

	local this = {
		x=x,
		y=y,
		w=w or 16,
		h=h or 250,
		text = nil,

		hover=false,
		capture=false,
		validator = validator,

		align_x=align_x or "middle",
		align_y=align_y or "middle",

		cursor_pos = 0,
		cursor_x = 0
	}

	this.text = guirender:createDynamicTextObject(init_str,this.w,format_func)

	function this:draw()
		local draw_cursor = false
		love.graphics.setScissor(self.x,self.y,self.w,self.h)
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
		if self.__maketextinputhook()==self.__hook then
			draw_cursor = true
			love.graphics.setColor(self.sel_col)
		else
			love.graphics.setColor(self.unsel_col)
		end
		love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
		love.graphics.setColor(1,1,1,1)
		local bx,by = self.buffer_info.l, self.buffer_info.r
		self.text:draw(self.x+bx,self.y+by,0,1,1)

		if draw_cursor then
			local time = love.timer.getTime()
			if math.fmod(time,1.33) < 1.11 then
				love.graphics.rectangle("fill",self.buffer_info.l+self.x-1+self.cursor_x,self.y+self.h-4,8,2)
			end
		end

		love.graphics.setScissor()
	end

	function this:shiftCursor(dir)
		local dir = dir
		if dir then
			local str_len = self.text:strlen()
			self.cursor_pos = self.cursor_pos + dir
			if self.cursor_pos < 1 then self.cursor_pos = 1 end
			if self.cursor_pos > str_len+1 then self.cursor_pos = str_len+1 end
		end
		self.cursor_x = self.text:getcharpos(self.cursor_pos)
	end

	function this:textinput(t)
		if t=="\b" then
			self:shiftCursor(-1)
			self.text:popchar(self.cursor_pos)
		elseif t=="\tleft" then
			self:shiftCursor(-1)
		elseif t=="\tright" then
			self:shiftCursor( 1)
		elseif t=="\thome" then
			self:shiftCursor(-1/0)
		elseif t=="\tend" then
			self:shiftCursor( 1/0)
		else
			self.text:insert(t, self.cursor_pos)
			local chars = utf8.len(t)
			self:shiftCursor(chars)
		end
		if input_hook then input_hook(self) end
	end

	function this:setText(t)
		self.text:set(t)
		self:shiftCursor(0)
	end

	--self.__maketextinputhook(self,this.textinput)
	function this:delete()
		self.__deltextinputhook(self)
	end

	function this:updateHoverInfo()
		if scancodeIsDown("return", CTRL.META) then
			self:removeHook()
		end

		local x,y,w,h = self.x, self.y, self.w, self.h
		local mx,my = love.mouse.getPosition()
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			self.hover = true
			return self
		end
		self.hover = false
		self.capture = false
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

	this.__hook  = function(t) this:textinput(t) end
	function this:action()
		self.__maketextinputhook(this.__hook)
		self:shiftCursor(1/0)
	end

	function this:removeHook()
		self.__deltextinputhook(this.__hook)
	end

	function this:getText()
		return self.text.string
	end
	function this:get()
		local val = self.validator(self.text.string)
		return val
	end
	function this:inputValid()
		local val = self.validator(self.text.string)
		return val ~= nil
	end

	setmetatable(this, MapEditGUITextInput)
	return this
end

return MapEditGUITextInput
