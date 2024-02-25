local paint = {

	paint_shader = love.graphics.newShader("paint.glsl"),

	right_arm_region = {40,16,16,16},
	left_arm_region  = {32,48,14,16},
	right_leg_region = {0 ,16,16,16},
	left_leg_region  = {16,46,16,16},

	right_arm_o_region = {40,32,16,16},
	left_arm_o_region  = {48,48,14,16},
	right_leg_o_region = {0 ,32,16,16},
	left_leg_o_region  = {0,48,16,16},

}

paint.mirror_dest = {}
paint.mirror_dest["right_arm_region"] = paint["left_arm_region"]
paint.mirror_dest["left_arm_region"] = paint["right_arm_region"]
paint.mirror_dest["right_arm_o_region"] = paint["left_arm_o_region"]
paint.mirror_dest["left_arm_o_region"] = paint["right_arm_o_region"]
paint.mirror_dest["right_leg_region"] = paint["left_leg_region"]
paint.mirror_dest["left_leg_region"] = paint["right_leg_region"]
paint.mirror_dest["right_leg_o_region"] = paint["left_leg_o_region"]
paint.mirror_dest["left_leg_o_region"] = paint["right_leg_o_region"]

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
		return pos[1] >= x and pos[1] <= x+w and
					 pos[2] >= y and pos[2] <= y+h
	end

	if mirror then
		for i,v in pairs(self.mirror_dest) do
			if test_rect(self[i]) then
				local m1 = self[i]
				local m2 = v

				local Dx = m2[1] - m1[1]
				local Dy = m2[2] - m1[2]

				local new_pos = {pos[1]+Dx,pos[2]+Dy}

				self:drawPixel{target=canvas,pixel=new_pos,colour=colour,mirror=false}
			end
		end
	end

	love.graphics.reset()
	love.graphics.setShader(self.paint_shader)
	self.paint_shader:send("colour", colour)
	love.graphics.setCanvas(canvas)
	love.graphics.points(pos[1], pos[2])
	love.graphics.reset()
end

function paint:erasePixel(args)
	local canvas = args.target
	local pos    = args.pixel
	local mirror = args.mirror

	if not canvas then error("paint:drawPixel(): no target given.") end
	if not pos then error("paint:drawPixel(): no pixel position given.") end

	love.graphics.reset()
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(0,0,0,0)
	love.graphics.setCanvas(canvas)
	love.graphics.points(pos[1], pos[2])
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
