local cpml = require 'cpml'
local mat = {}

local X_axis = cpml.vec3.new(1,0,0)
local Y_axis = cpml.vec3.new(0,-1,0)
local Z_axis = cpml.vec3.new(0,0,1)
local mat4 = cpml.mat4.new
local mat4trans = function(pos)
	return cpml.mat4.translate(mat4(),cpml.mat4.identity(),cpml.vec3.new(pos))
end
local mat4rot = function(rot)
	local mat = mat4()
	mat:rotate(mat,rot[1],X_axis)
	mat:rotate(mat,rot[2],Y_axis)
	mat:rotate(mat,rot[3],Z_axis)
	return mat
end

mat.new   = cpml.mat4.new
mat.trans = mat4trans
mat.rot   = mat4rot

return mat
