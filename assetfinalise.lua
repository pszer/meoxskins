local function __finaliseModel( fname , objs )
	local mesh_data = objs.mesh_data
	local layout = mesh_data.layout
	local blob = mesh_data.blob
	local indices = mesh_data.indices
	local mesh = love.graphics.newMesh(layout, blob, "triangles")
	mesh:setVertexMap(indices)
	objs.mesh = mesh

	objs.mesh_data = nil
	-- we give the model a release function
	objs.release = function(objs)
		local mesh = objs.mesh
		if mesh then mesh:release() end
	end

	return objs
end

local function __finaliseTexture( fname , img_data )
	local tex_attributes = require "cfg.texture_attributes"
	local atts = tex_attributes[fname] or {}

	local img
	if atts.texture_type == "cube" then
		img = love.graphics.newCubeImage(img_data, {mipmaps = true, linear = false})
	else
		img = love.graphics.newImage(img_data, {linear = false})
	end
	img_data:release()
	return img
end

local function __finaliseSound( fname , source )
	return source
end

local function __finaliseMusic( fname , source )
	return source
end

local function __finaliseTTF( fname , file_data )
	return file_data
end

local __finalise_asset_funcs = {
	["model"]   = __finaliseModel,
	["texture"] = __finaliseTexture,
	["sound"]   = __finaliseSound,
	["music"]   = __finaliseMusic,
	["ttf"]     = __finaliseTTF
}
return __finalise_asset_funcs
