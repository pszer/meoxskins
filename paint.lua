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
	love.graphics.setShader()
	love.graphics.setCanvas()
end

return paint
