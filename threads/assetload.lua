local tex_attributes   = require "cfg.texture_attributes"
local model_attributes = require "cfg.model_attributes"
local iqm = require "iqm-exm"

require "love.timer"
--require "love.graphics"
require "love.sound"
require "love.audio"
require "love.image"

local request_channel  = love.thread.getChannel( "loader_requests" )
local finished_channel = love.thread.getChannel( "loader_finished" )

local function __loadModel( base_dir , fname )

	local function readIQM(fname, save_data, preserve_cw)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open model file \"%s\"", fname) end

		local objs = iqm.load_threadsafe(fname, save_data, preserve_cw)
		if not objs then return nil, string.format("invalid IQM file \"%s\"", fname) end

		return objs, ""
	end

	local function readIQMAnimations(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open model animation file \"%s\"", fname) end

		local anims = iqm.load_anims_threadsafe(fname)
		if not anims then return nil, string.format("invalid IQM animations in file \"%s\"", fname) end

		return anims, ""
	end

	local fpath = base_dir .. fname

	local atts = model_attributes[fname] or {}
	local winding    = atts["model_vertex_winding"] or "ccw"
	local preserve_cw = winding == "cw"

	local objs, err_str = readIQM(fpath, false, preserve_cw)

	if not objs then
		return {"model" , fname , nil, err_str} end

	local anims, err_str = nil, ""
	if objs.has_anims then
		anims, err_str = readIQMAnimations(fpath)

		if not anims then
			return {"model" , fname , nil, err_str} end

		objs.anims = anims
	end

	return {"model", fname, objs, ""}
end

local function __loadTexture( base_dir , fname ) 

	-- for normal images
	local function openImage(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open file \"%s\"", fname) end

		local status, img  = pcall(
			function() return love.image.newImageData(fname) end)
		--local status, img = love.graphics.newImage(fname, {linear=false}) 

		if not status then return nil, string.format("invalid img file \"%s\", %s", fname, img) end
		--img:setWrap("repeat","repeat")

		return img, ""
	end

	attributes = tex_attributes[fname] or {}
	local fpath = base_dir .. fname

	local img, err_str = nil, nil 
	img, err_str = openImage( fpath )

	if not img then
		return {"texture" , fname , nil , err_str }
	end

	return {"texture" , fname , img , "" }
end

local function __loadSound( base_dir , fname )
	
	local function openSound(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open file \"%s\"", fname) end

		local status, sfx  = pcall(
			function() return love.audio.newSource(fname, "static") end)

		if not status then return nil, string.format("invalid sfx file \"%s\", %s", fname, tostring(sfx)) end

		return sfx, ""
	end

	local fpath = base_dir .. fname
	local sfx, err_str = openSound(fpath)
	if not sfx then
		return {"sound" , fname , nil , err_str }
	end
	return {"sound" , fname , sfx , "" }

end

-- same as __loadSound but loads the sound source as a stream instead of static
local function __loadMusic( base_dir , fname )
	
	local function openSound(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open file \"%s\"", fname) end

		local status, sfx  = pcall(
			function() return love.audio.newSource(fname, "stream") end)

		if not status then return nil, string.format("invalid music file \"%s\", %s", fname, tostring(sfx)) end

		return sfx, ""
	end

	local fpath = base_dir .. fname
	local sfx, err_str = openSound(fpath)
	if not sfx then
		return {"music" , fname , nil , err_str }
	end
	return {"music" , fname , sfx , "" }

end

local function __loadTTF( base_dir , fname )

	local function openTTF(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open file \"%s\"", fname) end

		local status, ttf  = pcall(
			function() return love.filesystem.newFileData(fname) end)

		if not status then return nil, string.format("invalid file \"%s\", %s", fname, tostring(ttf)) end

		return ttf, ""
	end

	local fpath = base_dir .. fname
	local ttf, err_str = openTTF(fpath)
	if not ttf then
		return {"ttf" , fname , nil , err_str }
	end
	return {"ttf" , fname , ttf , "" }
end


local load_funcs = {
	["model"]   = __loadModel,
	["texture"] = __loadTexture,
	["sound"]   = __loadSound,
	["music"]   = __loadMusic,
	["ttf"]     = __loadTTF
}

while true do
	local request = request_channel:pop()

	if request then
		local asset_type = request[1]
		local base_dir = request[2]
		local filename = request[3]

		local data = load_funcs[asset_type]( base_dir , filename )
		finished_channel:push(data)
	else
		love.timer.sleep(0.0020)
	end
end
