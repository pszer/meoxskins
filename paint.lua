local paint = {

	paint_shader = love.graphics.newShader("paint.glsl")

}

function paint:drawPixel(args)
	local canvas = args.target
	local pos    = args.pixel
	local colour  = args.colour

	if not canvas then error("paint:drawPixel(): no target given.") end
	if not pos then error("paint:drawPixel(): no pixel position given.") end
	if not colour then error("paint:drawPixel(): no colour given.") end

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
