local cpml = require 'cpml'

local camera = {
	pos = {0,0,0},
	view_m = cpml.mat4.new(),
	rot_m = cpml.mat4.new(),
	rotview_m = cpml.mat4.new(),
	proj_m = cpml.mat4.new(),
}

function camera:setPos(x,y,z)
	self.pos[1] = x
	self.pos[2] = y
	self.pos[3] = z
end

function camera:calcProj(x,y)
	x = x or love.graphics.getWidth()
	y = y or love.graphics.getHeight()
	self.proj_m = cpml.mat4.from_perspective(75,x/y,1,512)
end

local _tempvec3 = cpml.vec3.new()
local _origin = cpml.vec3.new(0,0,0)
local _up     = cpml.vec3.new(0,1,0)
function camera:calcMat()
	local id =
	{1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
	for i=1,16 do
		self.view_m[i] = id[i]
		self.rot_m[i]  = id[i]
	end

	_tempvec3.x = -self.pos[1]
	_tempvec3.y = -self.pos[2]
	_tempvec3.z = -self.pos[3]
	self.view_m = self.view_m:translate(self.view_m, _tempvec3)

	self.rot_m = cpml.mat4.look_at(self.rot_m,-_tempvec3,_origin,_up)

	self.rotview_m = self.rot_m * self.view_m
end

function camera:sendToShader(shader)
	shader = shader or love.graphics.getShader()
	shader:send("u_view", "column", self.rotview_m)
	shader:send("u_proj", "column", self.proj_m)
end

return camera
