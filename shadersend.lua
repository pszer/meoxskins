return function(shader, uniform, ...)
	if shader:hasUniform(uniform) then shader:send(uniform, ...) end
end
