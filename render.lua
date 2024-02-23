local camera = require 'camera'
local model  = require 'model'
local skin   = require 'skin'
local cpml   = require 'cpml'

local render = {

	shader3d = love.graphics.newShader("3d.glsl","3d.glsl"),
	shader3dgrid = love.graphics.newShader("3dgrid.glsl","3dgrid.glsl"),

	--viewport3d = love.graphics.newCanvas(w,h, {format="rgba16f"}),
	--viewport3d_depth = love.graphics.newCanvas(w,h, {format="depth24stencil8"}),

}

function render:createCanvas()
	local w,h = love.graphics.getDimensions()
	self.viewport3d = love.graphics.newCanvas(w,h, {format="rgba16f"})
	self.viewport3d:setFilter("nearest","nearest")
	self.viewport3d_depth = love.graphics.newCanvas(w,h, {format="depth24stencil8"})
end

function render:setup3DCanvas()
	love.graphics.setCanvas{
		self.viewport3d,
		depth = true,
		depthstencil = self.viewport3d_depth
	 }
end

function render:clear3DCanvas()
	self:setup3DCanvas()
	love.graphics.clear(unpack(require 'bg_col'))
end

local id = cpml.mat4.new()
function render:viewportPass(shader,clear)
	love.graphics.setShader(shader)
	camera:sendToShader()
	shader:send("u_model", "column", id)
	love.graphics.setDepthMode("lequal",true)
	love.graphics.setMeshCullMode("back")

	local skin_layers = skin:getVisibleLayers()
	local visible_parts = model:getVisibleParts()

	for i,layer in ipairs(skin_layers) do
		model:applyLayerTexture(layer.texture)
		for i,v in ipairs(visible_parts) do
			shader:send("u_model","column",v.mat)
			love.graphics.draw(v.mesh)
		end
	end
end

function render:clearDepthBuffer()
	self:setup3DCanvas()
	love.graphics.clear(false,true,true)
end

return render
