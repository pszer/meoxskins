--
-- skin visible parts gui element
--
--

local guirender = require 'gui.guidraw'
local guibutton = require 'gui.button'
local cursor = require 'gui.cursor'

local EditGUIVisible = {
	__type = "mapeditbutton",
	grayscale_shader = love.graphics.newShader("grayscale.glsl","grayscale.glsl"),
	box_info = {

		["head"]       = {51,12,38,35},
		["head_o"]     = {43,0,54,31},
		["torso"]      = {51,61,38,42},
		["torso_o"]    = {43,49,54,53},

		["leftleg"]    = {81,117,18,43},
		["leftleg_o"]   = {74,105,32,26},
		["rightleg"]   = {41,117,18,43},
		["rightleg_o"] = {34,105,32,26},

		["leftarm"]    = {107,60,18,43},
		["leftarm_o"]  = {100,49,32,26},
		["rightarm"]   = {15,60,18,43},
		["rightarm_o"] = {8,49,32,26}

	},

	translate = {
		slim = {

			["head"]       = "head",
			["head_o"]     = "head_o",
			["torso"]      = "torso",
			["torso_o"]    = "torso_o",

			["leftleg"]    = "leg_l",
			["leftleg_o"]   = "leg_l_o",
			["rightleg"]   = "leg_r",
			["rightleg_o"] = "leg_r_o",

			["leftarm"]    = "arm_slim_l",
			["leftarm_o"]  = "arm_slim_l_o",
			["rightarm"]   = "arm_slim_r",
			["rightarm_o"] = "arm_slim_r_o"
		},

		wide = {

			["head"]       = "head",
			["head_o"]     = "head_o",
			["torso"]      = "torso",
			["torso_o"]    = "torso_o",

			["leftleg"]    = "leg_l",
			["leftleg_o"]   = "leg_l_o",
			["rightleg"]   = "leg_r",
			["rightleg_o"] = "leg_r_o",

			["leftarm"]    = "arm_wide_l",
			["leftarm_o"]  = "arm_wide_l_o",
			["rightarm"]   = "arm_wide_r",
			["rightarm_o"] = "arm_wide_r_o"
		},
	}
}
EditGUIVisible.__index = EditGUIVisible

function EditGUIVisible:new(get_mode, get_mirror_mode)
	local this = {
		x=0,
		y=0,
		w=140,
		h=160,
		hover = false,
		get_mode = get_mode
	}

	function this:updateHoverInfo()
		local x,y,w,h = self.x, self.y, self.w, self.h
		local mx,my = love.mouse.getPosition()
		if x<=mx and mx<=x+w and
		   y<=my and my<=y+h
		then
			self.hover = true

			local mx,my = love.mouse.getPosition()
			mx = mx - self.x
			my = my - self.y

			local mode = self.get_mode()
			local translate = self.translate[mode]
			local function test_rect(rect)
				local x,y,w,h = rect[1],rect[2],rect[3],rect[4]
				return mx >= x and mx <= x+w and
							 my >= y and my <= y+h
			end
			local function test(part_name, exclude)
				local rect1 = self.box_info[part_name]
				if not test_rect(rect1) then return false end
				if not exclude or (exclude and not test_rect(self.box_info[exclude])) then
					return true
				end
				return false
			end

			if test("head_o","head") then cursor.hand() 
			elseif test("head",nil) then cursor.hand() 
			elseif test("torso_o","torso") then cursor.hand() 
			elseif test("torso",nil) then cursor.hand() 
			elseif test("leftarm_o","leftarm") then cursor.hand() 
			elseif test("leftarm",nil) then cursor.hand() 
			elseif test("rightarm_o","rightarm") then cursor.hand() 
			elseif test("rightarm",nil) then cursor.hand() 
			elseif test("leftleg_o","leftleg") then cursor.hand() 
			elseif test("leftleg",nil) then cursor.hand() 
			elseif test("rightleg_o","rightleg") then cursor.hand() 
			elseif test("rightleg",nil) then cursor.hand() end
			if test_rect{115,129,24,31} then
				cursor.hand()
			end

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
		local model = require 'model'

		love.graphics.reset()
		function draw_part(texture, part_name)
			local state = model.visible[part_name]

			if state then
				love.graphics.setShader()
			else
				love.graphics.setShader(self.grayscale_shader)
			end
			love.graphics.draw(texture)
		end

		local mode = self.get_mode()

		love.graphics.translate(self.x,self.y)
		draw_part(guirender["head_o"],"head_o")
		draw_part(guirender["head"],"head")

		draw_part(guirender["torso_o"],"torso_o")
		draw_part(guirender["torso"],"torso")

		draw_part(guirender["leftleg_o"],"leg_l_o")
		draw_part(guirender["leftleg"],"leg_l")
		draw_part(guirender["rightleg_o"],"leg_r_o")
		draw_part(guirender["rightleg"],"leg_r")

		if mode == "wide" then
			draw_part(guirender["leftarm_o"],"arm_wide_l_o")
			draw_part(guirender["leftarm"],"arm_wide_l")
			draw_part(guirender["rightarm_o"],"arm_wide_r_o")
			draw_part(guirender["rightarm"],"arm_wide_r")
		else
			draw_part(guirender["leftarm_o"],"arm_slim_l_o")
			draw_part(guirender["leftarm"],"arm_slim_l")
			draw_part(guirender["rightarm_o"],"arm_slim_r_o")
			draw_part(guirender["rightarm"],"arm_slim_r")
		end

		local mirror_mode = get_mirror_mode()
		if mirror_mode then
			love.graphics.setShader()
		else
			love.graphics.setShader(self.grayscale_shader)
		end
		love.graphics.draw(guirender["mirror"])

		love.graphics.reset()
	end

	function this:action()
		local mx,my = love.mouse.getPosition()
		mx = mx - self.x
		my = my - self.y

		local mode = self.get_mode()
		local translate = self.translate[mode]

		local function test_rect(rect)
			local x,y,w,h = rect[1],rect[2],rect[3],rect[4]
			return mx >= x and mx <= x+w and
			       my >= y and my <= y+h
		end

		local function test(part_name, exclude)
			local rect1 = self.box_info[part_name]
			if not test_rect(rect1) then return false end
			if not exclude or (exclude and not test_rect(self.box_info[exclude])) then
				local part_name = translate[part_name]
				local model = require 'model'
				model.visible[part_name] = not model.visible[part_name]
			end
			return false
		end

		if test("head_o","head") then return end
		if test("head",nil) then return end
		if test("torso_o","torso") then return end
		if test("torso",nil) then return end
		if test("leftarm_o","leftarm") then return end
		if test("leftarm",nil) then return end
		if test("rightarm_o","rightarm") then return end
		if test("rightarm",nil) then return end
		if test("leftleg_o","leftleg") then return end
		if test("leftleg",nil) then return end
		if test("rightleg_o","rightleg") then return end
		if test("rightleg",nil) then return end

		if test_rect{115,129,24,31} then
			local edit = require 'edit'
			edit.mirror_mode = not edit.mirror_mode
		end
	end

	function this.setX(self,x)
			self.x = x
	end
	function this.setY(self,y)
			self.y = y
	end
	function this.setW(self,w)
		end
	function this.setH(self,h) 
		end

	setmetatable(this, EditGUIVisible)
	return this
end

return EditGUIVisible
