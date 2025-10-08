local paint = {

	paint_shader = love.graphics.newShader("paint.glsl"),

	mirror = {

		["slim"]={
			arm_r_front  = {rect={44,20,3,12},dest="arm_l_front"},
			arm_r_right  = {rect={40,20,4,12},dest="arm_l_left"},
			arm_r_left   = {rect={47,20,4,12},dest="arm_l_right"},
			arm_r_back   = {rect={51,20,3,12},dest="arm_l_back"},
			arm_r_top    = {rect={44,16,3,4},dest="arm_l_top"},
			arm_r_bottom = {rect={47,16,3,4},dest="arm_l_bottom"},

			arm_l_front  = {rect={44-8,20+32,3,12},dest="arm_r_front"},
			arm_l_right  = {rect={40-8,20+32,4,12},dest="arm_r_left"},
			arm_l_left   = {rect={47-8,20+32,4,12},dest="arm_r_right"},
			arm_l_back   = {rect={51-8,20+32,3,12},dest="arm_r_back"},
			arm_l_top    = {rect={44-8,16+32,3,4},dest="arm_r_top"},
			arm_l_bottom = {rect={47-8,16+32,3,4},dest="arm_r_bottom"},

			arm_r_o_front  = {rect={44,20+16,3,12},dest="arm_l_o_front"},
			arm_r_o_right  = {rect={40,20+16,4,12},dest="arm_l_o_left"},
			arm_r_o_left   = {rect={47,20+16,4,12},dest="arm_l_o_right"},
			arm_r_o_back   = {rect={51,20+16,3,12},dest="arm_l_o_back"},
			arm_r_o_top    = {rect={44,16+16,3,4},dest="arm_l_o_top"},
			arm_r_o_bottom = {rect={47,16+16,3,4},dest="arm_l_o_bottom"},

			arm_l_o_front  = {rect={44-8+16,20+32,3,12},dest="arm_r_o_front"},
			arm_l_o_right  = {rect={40-8+16,20+32,4,12},dest="arm_r_o_left"},
			arm_l_o_left   = {rect={47-8+16,20+32,4,12},dest="arm_r_o_right"},
			arm_l_o_back   = {rect={51-8+16,20+32,3,12},dest="arm_r_o_back"},
			arm_l_o_top    = {rect={44-8+16,16+32,3,4},dest="arm_r_o_top"},
			arm_l_o_bottom = {rect={47-8+16,16+32,3,4},dest="arm_r_o_bottom"},

			leg_r_front  = {rect={04,20,4,12},dest="leg_l_front"},
			leg_r_right  = {rect={00,20,4,12},dest="leg_l_left"},
			leg_r_left   = {rect={08,20,4,12},dest="leg_l_right"},
			leg_r_back   = {rect={12,20,4,12},dest="leg_l_back"},
			leg_r_top    = {rect={04,16,4,4},dest="leg_l_top"},
			leg_r_bottom = {rect={08,16,4,4},dest="leg_l_bottom"},
			leg_r_o_front  = {rect={04,20+16,4,12},dest="leg_l_o_front"},
			leg_r_o_right  = {rect={00,20+16,4,12},dest="leg_l_o_left"},
			leg_r_o_left   = {rect={08,20+16,4,12},dest="leg_l_o_right"},
			leg_r_o_back   = {rect={12,20+16,4,12},dest="leg_l_o_back"},
			leg_r_o_top    = {rect={04,16+16,4,4},dest="leg_l_o_top"},
			leg_r_o_bottom = {rect={08,16+16,4,4},dest="leg_l_o_bottom"},

			leg_l_front  = {rect={04+16,20+32,4,12},dest="leg_r_front"},
			leg_l_right  = {rect={00+16,20+32,4,12},dest="leg_r_left"},
			leg_l_left   = {rect={08+16,20+32,4,12},dest="leg_r_right"},
			leg_l_back   = {rect={12+16,20+32,4,12},dest="leg_r_back"},
			leg_l_top    = {rect={04+16,16+32,4,4},dest="leg_r_top"},
			leg_l_bottom = {rect={08+16,16+32,4,4},dest="leg_r_bottom"},
			leg_l_o_front  = {rect={04,20+32,4,12},dest="leg_r_o_front"},
			leg_l_o_right  = {rect={00,20+32,4,12},dest="leg_r_o_left"},
			leg_l_o_left   = {rect={08,20+32,4,12},dest="leg_r_o_right"},
			leg_l_o_back   = {rect={12,20+32,4,12},dest="leg_r_o_back"},
			leg_l_o_top    = {rect={04,16+32,4,4},dest="leg_r_o_top"},
			leg_l_o_bottom = {rect={08,16+32,4,4},dest="leg_r_o_bottom"},
		},

		["wide"]={
			arm_r_front  = {rect={44,20,4,12},dest="arm_l_front"},
			arm_r_right  = {rect={40,20,4,12},dest="arm_l_left"},
			arm_r_left   = {rect={48,20,4,12},dest="arm_l_right"},
			arm_r_back   = {rect={52,20,4,12},dest="arm_l_back"},
			arm_r_top    = {rect={44,16,4,4},dest="arm_l_top"},
			arm_r_bottom = {rect={48,16,4,4},dest="arm_l_bottom"},

			arm_l_front  = {rect={44-8,20+32,4,12},dest="arm_r_front"},
			arm_l_right  = {rect={40-8,20+32,4,12},dest="arm_r_left"},
			arm_l_left   = {rect={48-8,20+32,4,12},dest="arm_r_right"},
			arm_l_back   = {rect={52-8,20+32,4,12},dest="arm_r_back"},
			arm_l_top    = {rect={44-8,16+32,4,4},dest="arm_r_top"},
			arm_l_bottom = {rect={48-8,16+32,4,4},dest="arm_r_bottom"},

			arm_r_o_front  = {rect={44,20+16,4,12},dest="arm_l_o_front"},
			arm_r_o_right  = {rect={40,20+16,4,12},dest="arm_l_o_left"},
			arm_r_o_left   = {rect={48,20+16,4,12},dest="arm_l_o_right"},
			arm_r_o_back   = {rect={52,20+16,4,12},dest="arm_l_o_back"},
			arm_r_o_top    = {rect={44,16+16,4,4},dest="arm_l_o_top"},
			arm_r_o_bottom = {rect={48,16+16,4,4},dest="arm_l_o_bottom"},

			arm_l_o_front  = {rect={44-8+16,20+32,4,12},dest="arm_r_o_front"},
			arm_l_o_right  = {rect={40-8+16,20+32,4,12},dest="arm_r_o_left"},
			arm_l_o_left   = {rect={48-8+16,20+32,4,12},dest="arm_r_o_right"},
			arm_l_o_back   = {rect={52-8+16,20+32,4,12},dest="arm_r_o_back"},
			arm_l_o_top    = {rect={44-8+16,16+32,4,4},dest="arm_r_o_top"},
			arm_l_o_bottom = {rect={48-8+16,16+32,4,4},dest="arm_r_o_bottom"},

			leg_r_front  = {rect={04,20,4,12},dest="leg_l_front"},
			leg_r_right  = {rect={00,20,4,12},dest="leg_l_left"},
			leg_r_left   = {rect={08,20,4,12},dest="leg_l_right"},
			leg_r_back   = {rect={12,20,4,12},dest="leg_l_back"},
			leg_r_top    = {rect={04,16,4,4},dest="leg_l_top"},
			leg_r_bottom = {rect={08,16,4,4},dest="leg_l_bottom"},
			leg_r_o_front  = {rect={04,20+16,4,12},dest="leg_l_o_front"},
			leg_r_o_right  = {rect={00,20+16,4,12},dest="leg_l_o_left"},
			leg_r_o_left   = {rect={08,20+16,4,12},dest="leg_l_o_right"},
			leg_r_o_back   = {rect={12,20+16,4,12},dest="leg_l_o_back"},
			leg_r_o_top    = {rect={04,16+16,4,4},dest="leg_l_o_top"},
			leg_r_o_bottom = {rect={08,16+16,4,4},dest="leg_l_o_bottom"},

			leg_l_front  = {rect={04+16,20+32,4,12},dest="leg_r_front"},
			leg_l_right  = {rect={00+16,20+32,4,12},dest="leg_r_left"},
			leg_l_left   = {rect={08+16,20+32,4,12},dest="leg_r_right"},
			leg_l_back   = {rect={12+16,20+32,4,12},dest="leg_r_back"},
			leg_l_top    = {rect={04+16,16+32,4,4},dest="leg_r_top"},
			leg_l_bottom = {rect={08+16,16+32,4,4},dest="leg_r_bottom"},
			leg_l_o_front  = {rect={04,20+32,4,12},dest="leg_r_o_front"},
			leg_l_o_right  = {rect={00,20+32,4,12},dest="leg_r_o_left"},
			leg_l_o_left   = {rect={08,20+32,4,12},dest="leg_r_o_right"},
			leg_l_o_back   = {rect={12,20+32,4,12},dest="leg_r_o_back"},
			leg_l_o_top    = {rect={04,16+32,4,4},dest="leg_r_o_top"},
			leg_l_o_bottom = {rect={08,16+32,4,4},dest="leg_r_o_bottom"},
		},


	}

}

function paint:drawPixel(args)
	local canvas = args.target
	local pos    = args.pixel
	local colour = args.colour
	local mirror = args.mirror

	if not canvas then error("paint:drawPixel(): no target given.") end
	if not pos then error("paint:drawPixel(): no pixel position given.") end
	if not colour then error("paint:drawPixel(): no colour given.") end

	local function test_rect(rect)
		local x,y,w,h = rect[1],rect[2],rect[3],rect[4]
		return pos[1] > x and pos[1] <= x+w and
					 pos[2] > y and pos[2] <= y+h
	end

	if mirror then
		local edit = require 'edit'
		local mode = edit.active_mode

		local mirror_info = self.mirror[mode]

		for i,v in pairs(mirror_info) do
			if test_rect(v.rect) then
				print("hit",i)
				print(pos[1],pos[2],unpack(v.rect))

				local m1 = v.rect
				local m2 = mirror_info[v.dest].rect

				local Dx = m2[1] + (m1[1]+m1[3]-pos[1]) + 1
				local Dy = m2[2] - m1[2]

				local new_pos = {Dx,pos[2]+Dy}

				self:drawPixel{target=canvas,pixel=new_pos,colour=colour,mirror=false}
			end
		end
	end

	love.graphics.reset()
	love.graphics.setShader(self.paint_shader)
	self.paint_shader:send("colour", colour)
	love.graphics.setCanvas(canvas)
	love.graphics.points(pos[1]-1, pos[2])
	love.graphics.reset()
end

function paint:erasePixel(args)
	local canvas = args.target
	local pos    = args.pixel
	local mirror = args.mirror

	if not canvas then error("paint:drawPixel(): no target given.") end
	if not pos then error("paint:drawPixel(): no pixel position given.") end

	local function test_rect(rect)
		local x,y,w,h = rect[1],rect[2],rect[3],rect[4]
		return pos[1] > x and pos[1] <= x+w and
					 pos[2] > y and pos[2] <= y+h
	end

	if mirror then
		local edit = require 'edit'
		local mode = edit.active_mode

		local mirror_info = self.mirror[mode]

		for i,v in pairs(mirror_info) do
			if test_rect(v.rect) then
				local m1 = v.rect
				local m2 = mirror_info[v.dest].rect

				local Dx = m2[1] + (m1[1]+m1[3]-pos[1]) + 1
				local Dy = m2[2] - m1[2]

				local new_pos = {Dx,pos[2]+Dy}

				self:erasePixel{target=canvas,pixel=new_pos,mirror=false}
			end
		end
	end

	love.graphics.reset()
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(0,0,0,0)
	love.graphics.setCanvas(canvas)
	love.graphics.points(pos[1]+1, pos[2]+1)
	love.graphics.reset()
end

function paint:fillFace(args)
	local canvas = args.target
	local mesh = args.mesh
	local t_i  = args.index
	local col  = args.colour

	local start = math.floor((t_i-1) / 6) * 6 + 1

	local min_x,min_y =  1/0, 1/0
	local max_x,max_y = -1/0,-1/0

	for i=0,5 do
		local _,_,_,u,v = mesh:getVertex(start + i)

		if u < min_x then min_x = u end
		if v < min_y then min_y = v end
		if u > max_x then max_x = u end
		if v > max_y then max_y = v end
	end

	min_x = min_x * 64
	max_x = max_x * 64
	min_y = min_y * 64
	max_y = max_y * 64

	love.graphics.reset()
	love.graphics.setShader(self.paint_shader)
	self.paint_shader:send("colour", col)
	love.graphics.setCanvas(canvas)
	--love.graphics.points(pos[1], pos[2])
	love.graphics.rectangle("fill",min_x,min_y,max_x-min_x,max_y-min_y)
	love.graphics.setShader()
	love.graphics.setCanvas()
end

return paint
