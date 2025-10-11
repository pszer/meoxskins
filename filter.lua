local filter = {
	
}

-- shader is a filename, shader code string or a love2d shader object
-- it is for fragment shader code only
--
-- params is a table of the uniform variable names defined in the shader, each
-- entry is a string for the uniform name, or table pair {uniform_name, is_array} if the uniform
-- is an array
--
-- defaults is a table which specifies the default values to use for the uniform values,
-- its indices are the names for the variable.
function filter:define_shader_filter(shader, params, defaults)
	if type(shader) == "string" then
		shader = love.graphics.newShader(
			-- default vertex shader
			[[#pragma language glsl3
				vec4 position( mat4 transform_projection, vec4 vertex_position ){
      	return transform_projection * vertex_position;}]],
			-- the filters fragment shader
			shader)
	end
	params = params or {}
	defaults = defaults or {}

	local f = {
		params = params,
		shader = shader,
		defaults = defaults,
	}

	f.apply = function(self, canvas, args)
		local w,h = canvas.getPixelDimensions(canvas)
		local new_canvas = love.graphics.newCanvas(w,h)
		new_canvas:setFilter("nearest","nearest")

		love.graphics.reset()
		love.graphics.setCanvas(new_canvas)
		love.graphics.setShader(self.shader)
		f:send_args(args)

		love.graphics.draw(canvas)
		love.graphics.reset()

		return new_canvas
	end

	f.send_args = function(self, args)
		for _,uniform in pairs(self.params) do
			if type(uniform) == "table" and uniform[2] then
				-- arrays must be unpacked for the love2d shader send function
				f.shader:send(uniform, (args[uniform[1]] and unpack(args[uniform[1]])) or unpack(f.defaults[uniform[1]]))
			else
				f.shader:send(uniform, args[uniform] or f.defaults[uniform])
			end
		end
	end

	return f
end

test_filter = filter:define_shader_filter("filter/invert.glsl", {}, {})

return filter
