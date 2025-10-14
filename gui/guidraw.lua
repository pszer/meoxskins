--
-- gui rendering functions used by mapedit.lua
--

require "string"
require "bit"
require "math"

require "assetloader"

local lang = require 'gui.guilang'
local utf8 = require("utf8")

local MapEditGUIRender = {
	font        = nil,
	font_bold   = nil,
	font_ibold   = nil,
	font_italic = nil,
	__font_fname        = "AnonymousPro-Regular.ttf",
	__font_bold_fname   = "AnonymousPro-Bold.ttf",
	__font_italic_fname = "AnonymousPro-Italic.ttf",
	__font_ibold_fname  = "AnonymousPro-BoldItalic.ttf",

	cxtm_bg_col = {0.094,0.161,0.290},
	x_bg_col = {0.62,0.27,0.117},
	__cxtm_bb = nil, -- bottom border for a context menu box
	__cxtm_tt = nil, -- top border for a context menu box
	__cxtm_rr = nil, -- right border for a context menu box
	__cxtm_ll = nil, -- left border
	__cxtm_tr = nil, -- top right corner
	__cxtm_tl = nil, -- top left corner
	__cxtm_br = nil, -- bottom right corner
	__cxtm_bl = nil, -- bottom left

	__scrlb_tt = nil,
	__scrlb_mm = nil,
	__scrlb_bb = nil,
	__scrlb_b  = nil,

	__bar = nil,
	__visible = nil,
	__invisible = nil,
	__alphalock = nil,
	__alphalock_off = nil,

	__sel_on   = nil,
	__sel_off  = nil,
	__tick_on  = nil,
	__tick_off = nil,

	icons = {},

	grayscale = love.graphics.newShader(
	[[
	 uniform float interp;
   	 vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
   	 {
        vec4 texcolor = Texel(tex, texture_coords) * color;
		float lum = dot(texcolor.xyz, vec3(0.299, 0.587, 0.114));
        return vec4(lum,lum,lum,texcolor.a) * (1.0-interp) + texcolor * interp;
    }
	]],
	[[
	 vec4 position( mat4 transform_projection, vec4 vertex_position )
	    {
   	     return transform_projection * vertex_position;
   	 }
	]]),

	cube_mesh = nil,
	cube_solid_mesh = nil,
	checkerboard_tex = nil
}
MapEditGUIRender.__index = MapEditGUIRender

function MapEditGUIRender:getFonts(l)
	local l = l or "eng"
	local fonts = lang:getFontInfo(l)

	local font = Loader:getTTFReference(fonts.regular.fname)
	font = love.graphics.newFont(font, fonts.regular.size, fonts.regular.hinting)

	local font_bold = Loader:getTTFReference(fonts.bold.fname)
	font_bold = love.graphics.newFont(font_bold, fonts.bold.size, fonts.bold.hinting)

	local font_italic = Loader:getTTFReference(fonts.italic.fname)
	font_italic = love.graphics.newFont(font_italic, fonts.italic.size, fonts.italic.hinting)

	local font_ibold = Loader:getTTFReference(fonts.ibold.fname)
	font_ibold = love.graphics.newFont(font_ibold, fonts.ibold.size, fonts.ibold.hinting)

	return font, font_bold, font_italic, font_ibold
end

function MapEditGUIRender:loadFonts(fonts)

	self.font = Loader:getTTFReference(fonts.regular.fname)
	self.font = love.graphics.newFont(self.font, fonts.regular.size, fonts.regular.hinting)
	assert(self.font)

	self.font_bold = Loader:getTTFReference(fonts.bold.fname)
	self.font_bold = love.graphics.newFont(self.font_bold, fonts.bold.size, fonts.bold.hinting)
	assert(self.font_bold)

	self.font_italic = Loader:getTTFReference(fonts.italic.fname)
	self.font_italic = love.graphics.newFont(self.font_italic, fonts.italic.size, fonts.italic.hinting)
	assert(self.font_italic)

	self.font_ibold = Loader:getTTFReference(fonts.ibold.fname)
	self.font_ibold = love.graphics.newFont(self.font_ibold, fonts.ibold.size, fonts.ibold.hinting)
	assert(self.font_ibold)

end

function MapEditGUIRender:initAssets()
	self:loadFonts(lang:getFontInfo())

	self.__cxtm_bb = Loader:getTextureReference("cxtm_bb.png")
	self.__cxtm_tt = Loader:getTextureReference("cxtm_tt.png")
	self.__cxtm_ll = Loader:getTextureReference("cxtm_ll.png")
	self.__cxtm_rr = Loader:getTextureReference("cxtm_rr.png")
	self.__cxtm_br = Loader:getTextureReference("cxtm_br.png")
	self.__cxtm_bl = Loader:getTextureReference("cxtm_bl.png")
	self.__cxtm_tr = Loader:getTextureReference("cxtm_tr.png")
	self.__cxtm_tl = Loader:getTextureReference("cxtm_tl.png")

	self.__x_bb = Loader:getTextureReference("x_bb.png")
	self.__x_tt = Loader:getTextureReference("x_tt.png")
	self.__x_ll = Loader:getTextureReference("x_ll.png")
	self.__x_rr = Loader:getTextureReference("x_rr.png")
	self.__x_br = Loader:getTextureReference("x_br.png")
	self.__x_bl = Loader:getTextureReference("x_bl.png")
	self.__x_tr = Loader:getTextureReference("x_tr.png")
	self.__x_tl = Loader:getTextureReference("x_tl.png")

	self.__scrlb_tt = Loader:getTextureReference("scrlb_tt.png")
	self.__scrlb_mm = Loader:getTextureReference("scrlb_mm.png")
	self.__scrlb_bb = Loader:getTextureReference("scrlb_bb.png")
	self.__scrlb_b = Loader:getTextureReference("scrlb_b.png")

	self.__bar = Loader:getTextureReference("bar.png")

	self.__visible = Loader:getTextureReference("visible.png")
	self.__invisible = Loader:getTextureReference("invisible.png")
	self.__alphalock = Loader:getTextureReference("alphalock.png")
	self.__alphalock_off = Loader:getTextureReference("alphalock_off.png")
	self.__alphalock_override = Loader:getTextureReference("alphalock_override.png")

	self.head = Loader:getTextureReference("s_head.png")
	self.head_o = Loader:getTextureReference("s_heado.png")
	self.torso = Loader:getTextureReference("s_torso.png")
	self.torso_o = Loader:getTextureReference("s_torsoo.png")
	self.rightleg = Loader:getTextureReference("s_rightleg.png")
	self.rightleg_o = Loader:getTextureReference("s_rightlego.png")
	self.leftleg = Loader:getTextureReference("s_leftleg.png")
	self.leftleg_o = Loader:getTextureReference("s_leftlego.png")
	self.rightarm = Loader:getTextureReference("s_rightarm.png")
	self.rightarm_o = Loader:getTextureReference("s_rightarmo.png")
	self.leftarm = Loader:getTextureReference("s_leftarm.png")
	self.leftarm_o = Loader:getTextureReference("s_leftarmo.png")
	self.mirror = Loader:getTextureReference("s_mirror.png")

	self.__tick_on = Loader:getTextureReference("tick_on.png")
	self.__tick_off = Loader:getTextureReference("tick_off.png")
	self.__sel_on = Loader:getTextureReference("sel_on.png")
	self.__sel_off = Loader:getTextureReference("sel_off.png")
	self.__tick_on_d = Loader:getTextureReference("tick_on_d.png")
	self.__tick_off_d = Loader:getTextureReference("tick_off_d.png")
	self.__sel_on_d = Loader:getTextureReference("sel_on_d.png")
	self.__sel_off_d = Loader:getTextureReference("sel_off_d.png")

	self.checkerboard_tex = Loader:getTextureReference("checkerboard.png")
	self.checkerboard_tex:setWrap("repeat","repeat")

	self.grayscale:send("interp",0.1)

	local icon_list = {
		"icon_del.png",
		"icon_dup.png",
		"icon_copy.png",
		"icon_sub.png",
		"icon_close.png",
		"icon_hue.png",
		"icon_about.png",
		"icon_vis.png",

		"icon_curves.png",

		"flag_en.png",
		"flag_pl.png",
		"flag_jp.png",
	}
	for i,v in ipairs(icon_list) do
		self.icons[v] = Loader:getTextureReference(v)
	end

	local layout = {
			{"VertexPosition", "float", 3},
			{"VertexNormal", "float", 3},
	}
	local vertices2 = {
        -- Top
        {0, 0, 1,0,0,1}, {1, 0, 1,0,0,1},
        {1, 1, 1,0,0,1}, {0, 1, 1,0,0,1},
        -- Bottom
        {1, 0, 0,0,0,-1}, {0, 0, 0,0,0,-1},
        {0, 1, 0,0,0,-1}, {1, 1, 0,0,0,-1},
        -- Front
        {0, 0, 0,0,-1,0}, {1, 0, 0,0,-1,0},
        {1, 0, 1,0,-1,0}, {0, 0, 1,0,-1,0},
        -- Back
        {1, 1, 0,0,1,0}, {0, 1, 0,0,1,0},
        {0, 1, 1,0,1,0}, {1, 1, 1,0,1,0},
        -- Right
        {1, 0, 0,1,0,0}, {1, 1, 0,1,0,0},
        {1, 1, 1,1,0,0}, {1, 0, 1,1,0,0},
        -- Left
        {0, 1, 0,-1,0,0}, {0, 0, 0,-1,0,0},
        {0, 0, 1,-1,0,0}, {0, 1, 1,-1,0,0},
	}

	local indices2 = {
			1, 2, 3, 3, 4, 1,
			5, 6, 7, 7, 8, 5,
			9, 10, 11, 11, 12, 9,
			13, 14, 15, 15, 16, 13,
			17, 18, 19, 19, 20, 17,
			21, 22, 23, 23, 24, 21,
	}
	self.cube_solid_mesh = love.graphics.newMesh(layout,vertices2,"triangles","static")
	self.cube_solid_mesh:setVertexMap(indices2)
	self.cube_solid_mesh:setTexture(self.checkerboard_tex)

	local vertices = {
		{0,0,0}, {1,0,0}, {0,1,0}, {0,0,1},
		{1,1,0}, {1,0,1}, {0,1,1}, {1,1,1}
	}
	local indices = {
		1,2,1,
		1,3,1,
		1,4,1,
		8,7,8,
		8,6,8,
		8,5,8,
		3,7,3,
		4,7,4,
		2,5,2,
		2,6,2,
		4,6,4,
		3,5,3
	}

	self.cube_mesh = love.graphics.newMesh(layout,vertices,"triangles","static")
	self.cube_mesh:setVertexMap(indices)
end

--
-- ~N ~n newline
--
-- ~B ~b toggles bold text on/off
-- ~I ~i toggles italic tex on/off
-- (upper and lowercase are equivalent)
--
-- ~(0xFFFFFF) switches to hexadecimal RGB coloured text, can be the name of a
-- predefined colour like ~(red), ~(white), ~(blue) etc. Default colour is white.
--
-- ~R ~r reset to default
--
-- example, the word "example" will be drawn in bold and the substring "sent" in
-- the word sentence will be red
-- This is an ~Bexample~B ~(0xFF0000)sent~(0xFFFFFF)ence
--
-- if you want to use a tilde character as part of the text, escape it using double tilde ~~
--
function MapEditGUIRender:createDrawableText(string, font, font_bold, font_italic, font_ibold, canvas)
	assert_type(string, "string")
	local font = font or self.font
	local font_bold = font_bold or self.font_bold
	local font_italic = font_italic or self.font_italic
	local font_ibold = font_ibold or self.font_ibold
	assert(font and font_bold and font_italic)

	-- gets the position of a non-escaped tilde character
	-- with an optional start index i
	--
	-- this string.find pattern cannot find tildes at the beginning of the string
	-- quick and dirty fix is to simply add a junk character at the beginning of the string
	function get_tilde_pos(str, i)
		local a,b = string.find(' '..str,"[^~]~[^~]", i)
		if not (a and b) then return nil end
		return b-2
	end

	local substrs = {}

	local i = 1
	local j = 1

	local curr_type = "regular" -- "bold", "italic"
	local curr_col  = 0xFFFFFF
	local new_line  = false

	local nilstr = ""

	local col_table = {
		["white"]   = 0xFFFFFF,
		["gray"]    = 0x808080,
		["grey"]    = 0x808080,
		["lgray"]   = 0xBBBBBB,
		["lgrey"]   = 0xBBBBBB,
		["black"]   = 0x000000,

		["red"]     = 0xFF0000,
		["green"]   = 0x00FF00,
		["indigo"]  = 0x0000FF,

		["yellow"]  = 0xFFFF00,
		["magenta"] = 0xFF00FF,
		["cyan"]    = 0x00FFFF,

		["orange"]  = 0xFF8000,
		["pink"]    = 0xFF0080,
		["purple"]  = 0x8000FF,
		["blue"]    = 0x0080FF,
		["emerald"] = 0x00FF80,
		["vert"]    = 0x80FF00,

		["lyellow"] = 0xFFFF80,
		["lgreen"]  = 0x80FF80,
		["lblue"]   = 0x8080FF,
		["lred"]    = 0xFF8080,
		["lpurple"] = 0xbb78ff,
		["lpink"]   = 0xff5ec1,
	}

	while true do
		local t_pos = get_tilde_pos(string, j)
		if not t_pos then i=j break end

		i = j
		j = t_pos
		if i < j then
			local substr = string.sub(string, i,j-1)
			table.insert(substrs, {substr,curr_type,curr_col,new_line})
		end
		new_line = false

		local char_after_tilde = string.sub(string, j+1,j+1)
		if char_after_tilde == nilstr then
			error(string.format("MapEditGUIRender:createDrawableText(): %s ill-formated string, character expected after ~", string))
		end

		if char_after_tilde == "N" or char_after_tilde == "n" then
			new_line = true
			j = j+2
		elseif char_after_tilde == "B" or char_after_tilde == "b" then
			--if curr_type ~= "bold" then curr_type = "bold"
			--                       else curr_type = "regular" end
			if     curr_type == "bold"   then curr_type = "regular"
			elseif curr_type == "italic" then curr_type = "ibold"
			elseif curr_type == "regular" then curr_type = "bold"
			end
			j = j+2
		elseif char_after_tilde == "I" or char_after_tilde == "i" then
			--if curr_type ~= "italic" then curr_type = "italic"
			--                         else curr_type = "regular" end
			if     curr_type == "bold"   then curr_type = "ibold"
			elseif curr_type == "italic" then curr_type = "regular"
			elseif curr_type == "regular" then curr_type = "italic"
			end
			j = j+2
		elseif char_after_tilde == "R" or char_after_tilde == "r" then
			curr_type = "regular"
			curr_col  = 0xFFFFFF
			j = j+2
		elseif char_after_tilde == "(" then
			local a,b,in_bracket = string.find(string, "%((.-)%)", j+1)

			if not in_bracket then
				error(string.format("MapEditGUIRender:createDrawableText(): %s ill-formated string, expected ~(col) after ~(", string))
			end

			local in_col_table = col_table[in_bracket]
			if in_col_table then
				curr_col = in_col_table
			else
				curr_col = tonumber(in_bracket, 16)
			end

			j = b+1
		else
			error(string.format("MapEditGUIRender:createDrawableText(): %s ill-formated string, unrecognised character after ~", string))
		end
	end

	j = #string
	if i<=j then
		table.insert(substrs, {string.sub(string,i,j),curr_type,curr_col,new_line})
	end

	local function HexToRGB(hex)
	    local r = math.floor(hex / 65536) % 256 
	    local g = math.floor(hex / 256)   % 256  
   		local b = hex % 256
		return r,g,b
	end

	local texts = {}
	local tinfo = {}
	love.graphics.setColor(1,1,1,1)
	for i,v in ipairs(substrs) do
		local str   = v[1]
		local ttype = v[2]
		local col   = v[3]
		local nl    = v[4]

		local f = nil
		if     ttype == "regular" then f = font
		elseif ttype == "bold"    then f = font_bold
		elseif ttype == "italic"  then f = font_italic
		elseif ttype == "ibold"   then f = font_ibold
		end
		local r,g,b = HexToRGB(col)
		local S = 1/255
		texts[i] = love.graphics.newText(f, {{r*S,g*S,b*S},str})
		local t = texts[i]

		tinfo[i] = {t:getWidth(), t:getHeight(), nl}
	end

	local min,max = math.min, math.max
	local maxw,maxh = 0,0
	local w,h = 0,0
	for i,v in ipairs(tinfo) do
		local tw,th,nl = v[1],v[2],v[3]
		if nl then
			maxw = math.max(w,maxw)
			maxh = maxh + h
			w,h=tw,th
		else
			w,h = w+tw,math.max(h,th)
		end
	end
	maxw = math.max(w,maxw)
	maxh = maxh + h

	local canvas = canvas or love.graphics.newCanvas(maxw,maxh)
	love.graphics.origin()
	love.graphics.setShader()
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas(canvas)
	h=0
	local x,y=0,0
	for i,v in ipairs(tinfo) do
		local text = texts[i]
		local tw,th,nl = v[1],v[2],v[3]
		if nl then
			y=y+h
			h=0
			x=0
		end

		love.graphics.draw(text,x,y-1)
		x,h = x+tw,math.max(h,th)
	end
	love.graphics.setCanvas()

	return canvas,maxw,maxh
end

function MapEditGUIRender:createDynamicTextObject(init_string, width, format_func, font,fontb,fonti,fontib)
	local this = {
		string = init_string or "",
		internal_string = "",
		width  = width or 500,
		canvas = love.graphics.newCanvas(width,64,{format="rgb10a2"}),
		formatter = format_func,
		font = font,
		fontb = fontb,
		fonti = fonti,
		fontib = fontib,
		w = 0,
		h = 0,

		-- text object for calculating cursor positions
		dummytext = MapEditGUIRender:createDrawableTextBasic(init_string, font,fontb,fonti,fontib),

		clearcanvas=function(self)
			love.graphics.setCanvas(self.canvas)
			love.graphics.clear(0,0,0,0)
			love.graphics.setCanvas()
		end,
		set = function(self,text)
			local result = string.gsub(text,"~","~~") -- tilde is reserved for formatting bold,italic,colour etc. and is not visible
			                                          -- ~~ is treated as an escape character
			if self.formatter then
				local new_result = self.formatter(result)
				if new_result then result = new_result end
			end
			self.internal_string = result
			self.string = text

			self:clearcanvas()
			local _,w,h = MapEditGUIRender:createDrawableText(result, self.font, self.fontb, self.fonti, self.fontib, self.canvas)
			self.w = w or 0
			self.h = h or 0
		end,
		concat = function(self,text)
			local text = (self.string) .. text
			self:set(text)
		end,
		insert = function(self,text,i)
			local str_len = utf8.len(self.string)
			if i>str_len then self:concat(text) return end
			local result = self.string
			if i<=1 then
				result = text..result
			else
				local offset = utf8.offset(self.string,i-1)
				if i==0 then offset = 0 end
				local offset2 = utf8.offset(self.string,i)
				result = string.sub(self.string,1,offset)..text..string.sub(self.string,offset2,-1)
			end
			self:set(result)
		end,
		get = function(self)
			return self.string
		end,
		popchar = function(self, index)
			if self.string == "" then return end
			local str
			if not index then
				local offset = utf8.offset(self.string,-1)
				str = string.sub(self.string,1,offset-1)
			else
				local offset1 = math.max(utf8.offset(self.string,math.max(index,1))-1,0)
				local offset2 = utf8.offset(self.string,index+1)
				str = string.sub(self.string,1,offset1)..string.sub(self.string,offset2,-1)
			end
			self:set(str)
		end,
		strlen = function(self)
			return utf8.len(self.string)
		end,
		getcharpos = function(self, pos)
			local offset = utf8.offset(self.string,pos)
			self.dummytext:set(string.sub(self.string,1,offset-1))
			return self.dummytext:getWidth()
		end,
		draw = function(self,x,y,r,sx,sy)
			love.graphics.draw(self.canvas,x,y,r,sx,sy)
		end
	}

	this:set(this.string)

	return this
end

-- without color/bold/italic formatting (for now)
function MapEditGUIRender:createDrawableTextLimited(string, limit, align, font, font_bold, font_italic, font_ibold)
	assert_type(string, "string")
	assert(limit)
	local align = align or "left"
	local font = font or self.font
	local font_bold = font_bold or self.font_bold
	local font_italic = font_italic or self.font_italic
	local font_ibold = font_ibold or self.font_ibold
	assert(font and font_bold and font_italic and font_ibold)

	local drawable = love.graphics.newText(font, "")
	drawable:setf(string,limit,align)
	return drawable
end

function MapEditGUIRender:createDrawableTextBasic(string, font, font_bold, font_italic, font_ibold)
	assert_type(string, "string")
	local font = font or self.font
	local font_bold = font_bold or self.font_bold
	local font_italic = font_italic or self.font_italic
	local font_ibold = font_ibold or self.font_ibold
	assert(font and font_bold and font_italic and font_ibold)
	local drawable = love.graphics.newText(font, string)
	return drawable
end

function MapEditGUIRender:drawableFormatString(name, props)
	assert(name)
	local input_type = type(name)
	local str = nil
	if input_type == "string" then
		str = name
	elseif input_type == "table" then
		local str_f = name[1]
		local str_d = {}
		for i=2,#name do
			str_d[i-1] = this.props[name[i]]
		end
		str = string.format(str_f, unpack(str_d))
	else
		error("MapEditGUIRender:drawableFormatString(): expected string/table in name field", 2)
	end
	local drawable_text = self:createDrawableText(str)
	local w,h = drawable_text:getDimensions()
	return drawable_text,w,h
end

function MapEditGUIRender:createContextMenuBackground(w,h, col)
	local canvas = love.graphics.newCanvas(w,h)

	cxtm_bb = self.__cxtm_bb 
	cxtm_tt = self.__cxtm_tt 
	cxtm_rr = self.__cxtm_rr 
	cxtm_ll = self.__cxtm_ll 
	cxtm_tr = self.__cxtm_tr 
	cxtm_tl = self.__cxtm_tl 
	cxtm_br = self.__cxtm_br 
	cxtm_bl = self.__cxtm_bl

	local bg_col = self.cxtm_bg_col
	local col = col or {1,1,1}

	love.graphics.origin()
	love.graphics.setShader()
	love.graphics.setCanvas(canvas)
	love.graphics.clear(bg_col[1],bg_col[2],bg_col[3],1)
	love.graphics.setColor(col[1],col[2],col[3],1)

	love.graphics.draw(cxtm_tl,0  ,0,   0, 1,1)
	love.graphics.draw(cxtm_tr,w-2,0,   0, 1,1)
	love.graphics.draw(cxtm_bl,0  ,h-2, 0, 1,1)
	love.graphics.draw(cxtm_br,w-2,h-2, 0, 1,1)

	local w2 = w-4
	local h2 = h-4
	love.graphics.draw(cxtm_ll,0  ,2  , 0, 1 ,h2)
	love.graphics.draw(cxtm_rr,w-2,2  , 0, 1 ,h2)
	love.graphics.draw(cxtm_tt,2  ,0  , 0, w2,1 )
	love.graphics.draw(cxtm_bb,2  ,h-2, 0, w2,1 )

	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas()
	return canvas
end


function MapEditGUIRender:drawGenericOption(x,y,w,h, bg, txt, icon, arrow, state, buffer_info)
	local bl = buffer_info.l_no_icon
	if icon then
		bl = buffer_info.l
	end

	love.graphics.origin()
	love.graphics.draw(bg,x,y)

	-- if hoverable
	local int = math.floor
	if state == "hover" then

		local mode, alphamode = love.graphics.getBlendMode()
		love.graphics.setColor(255/255,161/255,66/255,0.8)
		love.graphics.setBlendMode("add","alphamultiply")

		love.graphics.rectangle("fill",x,y,w,h)

		love.graphics.setColor(1,1,1,1)
		love.graphics.setBlendMode("subtract","alphamultiply")

		if txt then
			love.graphics.draw(txt,int(x+bl),int(y+buffer_info.t))
		end

		if icon then
			love.graphics.draw(icon,x+buffer_info.icon_l,y+buffer_info.icon_t)
		end

		love.graphics.setBlendMode(mode, alphamode)

	elseif state ~= "disable" then
		if txt then
			love.graphics.draw(txt, int(x+bl), int(y+buffer_info.t))
		end
		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end
	else
		love.graphics.setShader(self.grayscale)
		love.graphics.setColor(0.9,0.9,1,0.3)

		if txt then
			love.graphics.draw(txt,int(x+bl),int(y+buffer_info.t))
		end
		if icon then
			love.graphics.draw(icon,x+buffer_info.icon_l,y+buffer_info.icon_t)
		end

		love.graphics.setShader()
	end
	if arrow then
		love.graphics.draw(self.icons["icon_sub.png"],
			x + w - buffer_info.arrow_r, y + buffer_info.arrow_t)
	end

	love.graphics.setColor(1,1,1,1)
end

function MapEditGUIRender:drawScrollBar(x,y,h,ratio)
	local tt = self.__scrlb_tt
	local mm = self.__scrlb_mm
	local bb = self.__scrlb_bb 
	local b  = self.__scrlb_b

	love.graphics.origin()
	love.graphics.translate(x,y)
	love.graphics.draw(tt,0,0)
	love.graphics.draw(mm,0,2,0,1,(h-4))
	love.graphics.draw(bb,0,h-2)
	love.graphics.draw(b,0,(h-20)*ratio)
	love.graphics.origin()
end

function MapEditGUIRender:drawTile(x,y,w,h, bg_col, border_col)
	local bg_col     = bg_col or {0,0,0,1}
	local border_col = border_col or {0.6,0.6,0.6,1}
	love.graphics.setColor(bg_col)
	love.graphics.rectangle("fill",x,y,w,h)
	love.graphics.setColor(border_col)
	love.graphics.rectangle("line",x,y,w,h)
	love.graphics.setColor(1,1,1,1)
end

function MapEditGUIRender:drawOption(x,y,w,h, txt, icon, arrow, state, buffer_info, text_align)
	cxtm_bb = self.__cxtm_bb 
	cxtm_tt = self.__cxtm_tt 
	cxtm_rr = self.__cxtm_rr 
	cxtm_ll = self.__cxtm_ll 
	cxtm_tr = self.__cxtm_tr 
	cxtm_tl = self.__cxtm_tl 
	cxtm_br = self.__cxtm_br 
	cxtm_bl = self.__cxtm_bl

	local bg_col = self.cxtm_bg_col
	local col = col or {1,1,1}

	love.graphics.origin()

	love.graphics.setColor(bg_col[1], bg_col[2], bg_col[3],1)
	love.graphics.rectangle("fill",x,y,w,h)

	love.graphics.setColor(col[1],col[2],col[3],1)

	love.graphics.translate(x,y)

	love.graphics.draw(cxtm_tl,0  ,0,   0, 1,1)
	love.graphics.draw(cxtm_tr,w-2,0,   0, 1,1)
	love.graphics.draw(cxtm_bl,0  ,h-2, 0, 1,1)
	love.graphics.draw(cxtm_br,w-2,h-2, 0, 1,1)

	local w2 = w-4
	local h2 = h-4
	love.graphics.draw(cxtm_ll,0  ,2  , 0, 1 ,h2)
	love.graphics.draw(cxtm_rr,w-2,2  , 0, 1 ,h2)
	love.graphics.draw(cxtm_tt,2  ,0  , 0, w2,1 )
	love.graphics.draw(cxtm_bb,2  ,h-2, 0, w2,1 )

	love.graphics.setColor(1,1,1,1)
	love.graphics.origin()

	local bl = buffer_info.l_no_icon
	if icon then
		bl = buffer_info.l
	end

	if type(icon) == "string" then
		icon = self.icons[icon]
	end

	-- if hoverable
	local int = math.floor
	if state == "hover" then
		local mode, alphamode = love.graphics.getBlendMode()
		love.graphics.setColor(255/255,161/255,66/255,0.8)
		love.graphics.setBlendMode("add","alphamultiply")

		love.graphics.rectangle("fill",x,y,w,h)

		love.graphics.setColor(1,1,1,1)
		love.graphics.setBlendMode("subtract","alphamultiply")

		if txt then
			local txt_x = int(x+bl)
			if text_align == "middle" then
				local txt_w = txt:getDimensions()
				txt_x = int(x+w*0.5-txt_w*0.5)
			end
			love.graphics.draw(txt,txt_x,int(y+buffer_info.t))
		end
		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end

		love.graphics.setBlendMode(mode, alphamode)

	elseif state ~= "disable" then
		if txt then
			local txt_x = int(x+bl)
			if text_align == "middle" then
				local txt_w = txt:getDimensions()
				txt_x = int(x+w*0.5-txt_w*0.5)
			end
			love.graphics.draw(txt,txt_x,int(y+buffer_info.t))
		end
		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end
	else
		love.graphics.setShader(self.grayscale)
		love.graphics.setColor(0.9,0.9,1,0.3)

		if txt then
			local txt_x = int(x+bl)
			if text_align == "middle" then
				local txt_w = txt:getDimensions()
				txt_x = int(x+w*0.5-txt_w*0.5)
			end
			love.graphics.draw(txt,txt_x,int(y+buffer_info.t))
		end
		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end

		love.graphics.setShader()
	end
	if arrow then
		love.graphics.draw(self.icons["icon_sub.png"],
			x + w - buffer_info.arrow_r, y + buffer_info.arrow_t)
	end

	love.graphics.setColor(1,1,1,1)
end

function MapEditGUIRender:drawCloseButton(x,y,w,h, txt, icon, arrow, state, buffer_info, text_align)
	x_bb = self.__x_bb 
	x_tt = self.__x_tt 
	x_rr = self.__x_rr 
	x_ll = self.__x_ll 
	x_tr = self.__x_tr 
	x_tl = self.__x_tl 
	x_br = self.__x_br 
	x_bl = self.__x_bl

	local bg_col = self.x_bg_col
	local col = col or {1,1,1}

	love.graphics.origin()

	love.graphics.setColor(bg_col[1], bg_col[2], bg_col[3],1)
	love.graphics.rectangle("fill",x,y,w,h)

	love.graphics.setColor(col[1],col[2],col[3],1)

	love.graphics.translate(x,y)

	love.graphics.draw(x_tl,0  ,0,   0, 1,1)
	love.graphics.draw(x_tr,w-2,0,   0, 1,1)
	love.graphics.draw(x_bl,0  ,h-2, 0, 1,1)
	love.graphics.draw(x_br,w-2,h-2, 0, 1,1)

	local w2 = w-4
	local h2 = h-4
	love.graphics.draw(x_ll,0  ,2  , 0, 1 ,h2)
	love.graphics.draw(x_rr,w-2,2  , 0, 1 ,h2)
	love.graphics.draw(x_tt,2  ,0  , 0, w2,1 )
	love.graphics.draw(x_bb,2  ,h-2, 0, w2,1 )

	love.graphics.setColor(1,1,1,1)
	love.graphics.origin()

	local bl = buffer_info.l_no_icon
	if icon then
		bl = buffer_info.l
	end

	if type(icon) == "string" then
		icon = self.icons[icon]
	end

	-- if hoverable
	local int = math.floor
	if state == "hover" then
		local mode, alphamode = love.graphics.getBlendMode()
		love.graphics.setColor(255/255,161/255,66/255,0.8)
		love.graphics.setBlendMode("add","alphamultiply")

		love.graphics.rectangle("fill",x,y,w,h)

		love.graphics.setColor(1,1,1,1)
		love.graphics.setBlendMode("subtract","alphamultiply")

		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end

		love.graphics.setBlendMode(mode, alphamode)
	else
		if icon then
			love.graphics.draw(icon,int(x+buffer_info.icon_l),int(y+buffer_info.icon_t))
		end
	end

	love.graphics.setColor(1,1,1,1)
end

function MapEditGUIRender:drawInset(x,y,w,h)
	cxtm_bb = self.__cxtm_bb 
	cxtm_tt = self.__cxtm_tt 
	cxtm_rr = self.__cxtm_rr 
	cxtm_ll = self.__cxtm_ll 
	cxtm_tr = self.__cxtm_tr 
	cxtm_tl = self.__cxtm_tl 
	cxtm_br = self.__cxtm_br 
	cxtm_bl = self.__cxtm_bl

	local bg_col = self.cxtm_bg_col
	local col = col or {1,1,1}

	love.graphics.origin()

	love.graphics.setColor(bg_col[1], bg_col[2], bg_col[3],1)
	love.graphics.rectangle("fill",x,y,w,h)

	love.graphics.setColor(col[1],col[2],col[3],1)

	love.graphics.translate(x,y)

	--love.graphics.draw(cxtm_tl,0  ,0,   0, 1,1)
	--love.graphics.draw(cxtm_tr,w-2,0,   0, 1,1)
	--love.graphics.draw(cxtm_bl,0  ,h-2, 0, 1,1)
	--love.graphics.draw(cxtm_br,w-2,h-2, 0, 1,1)

	--local w2 = w-4
	--local h2 = h-4
	--love.graphics.draw(cxtm_ll,0  ,2  , 0, 1 ,h2)
	--love.graphics.draw(cxtm_rr,w-2,2  , 0, 1 ,h2)
	--love.graphics.draw(cxtm_tt,2  ,0  , 0, w2,1 )
	--love.graphics.draw(cxtm_bb,2  ,h-2, 0, w2,1 )
	love.graphics.draw(cxtm_rr, -2  , 0   , 0, 1 , h )
	love.graphics.draw(cxtm_ll,  w  , 0   , 0, 1 , h )
	love.graphics.draw(cxtm_tt,  0  , -2  , 0, w , 1 )
	love.graphics.draw(cxtm_bb,  0  ,  h  , 0, w , 1 )

	love.graphics.setColor(1,1,1,1)
	love.graphics.origin()
end

function MapEditGUIRender:generateSphereVertices(radius, numSegments, numRings)
	local vertices = {}

	for ring = 0, numRings do
		local phi = math.pi * (ring / numRings)
		local cosPhi = math.cos(phi)
		local sinPhi = math.sin(phi)

		for segment = 0, numSegments do
			local theta = 2 * math.pi * (segment / numSegments)
			local cosTheta = math.cos(theta)
			local sinTheta = math.sin(theta)

			local x = radius * sinPhi * cosTheta
			local y = radius * cosPhi
			local z = radius * sinPhi * sinTheta

			local u = segment / numSegments
			local v = ring / numRings

			local normalX = x / radius
			local normalY = y / radius
			local normalZ = z / radius

			table.insert(vertices, {x, y, z, u, v, normalX, normalY, normalZ})
		end
	end

	return vertices
end

return MapEditGUIRender
