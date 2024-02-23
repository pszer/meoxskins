require "provtype"

-- note about TTF
-- only the filedata for the TTF is loaded, once retrieved
-- it has to be converted

Loader = {__type = "loader",

	models   = {__dir="models/", __ref_counts={}, __release = "release" },
	textures = {__dir="img/"   , __ref_counts={}, __release = "release" },
	sounds   = {__dir="sfx/"   , __ref_counts={}, __release = "release" },
	music    = {__dir="music/" , __ref_counts={}, __release = "release" },
	ttf      = {__dir="ttf/"   , __ref_counts={}, __release = "release" },

	type_str_to_asset_table = {},

	request_channel  = love.thread.getChannel( "loader_requests" ),
	finished_channel = love.thread.getChannel( "loader_finished" ),

	requests = {},
	requests_count = 0,

	demand_timeout = 5.0,

	thread = love.thread.newThread( "threads/assetload.lua" )

}

Loader.__index = Loader
Loader.type_str_to_asset_table = {
	["model"] = Loader.models,
	["texture"] = Loader.textures,
	["sound"] = Loader.sounds,
	["music"] = Loader.music,
	["ttf"] = Loader.ttf
}

function Loader:initThread()
	self.thread:start()
end

function Loader:addAsset(asset_table, asset, filename)
	assert(asset_table and asset and filename)

	local already_loaded = asset_table[filename]
	if already_loaded then
		error(string.format("Loader:addAsset(): %s%s already loaded", asset_table.__dir, tostring(filename))) end

	asset_table[filename] = asset
	asset_table.__ref_counts[filename] = 0
end

function Loader:removeAsset(asset_table, filename)
	assert(asset_table, filename)

	local asset = asset_table[filename]
	if not asset then
		error(string.format("Loader:removeAsset(): %s%s is not loaded", asset_table.__dir, tostring(filename))) end

	local ref_count = asset_table.__ref_counts[filename]
	if ref_count > 0 then
		error(string.format("Loader:removeAsset(): %s%s still has %d references, have you forgot to Loader:deref() ?",
		asset_table.__dir, tostring(filename), ref_count)) end

	local release_func_name = asset_table.__release
	asset[release_func_name] (asset)
	--release_func( asset )
	asset_table[filename] = nil
	asset_table.__ref_counts[filename] = nil
end

-- removes any assets without references
function Loader:cleanupAssets(asset_table)
	local function cleanup(asset_table)
		for name , asset in pairs(asset_table) do
			-- skip over internal variables
			if not (name == "__dir" or name == "__ref_counts" or name == "__release") then

				local ref_count = asset_table.__ref_counts[name]

				if ref_count == 0 then
					local release_func = asset_table.__release
					local asset = asset_table[name]

					asset_table[name] = nil
					asset_table.__ref_counts[name] = nil
					asset[release_func]( asset )

					print(string.format("Loader:cleaupAssets(): removing %s%s", asset_table.__dir, name))
				else
					print(string.format("Loader:cleaupAssets(): %s%s has %d references", asset_table.__dir, name, ref_count))
				end
			end
		end
	end

	for _,asset_table in pairs(self.type_str_to_asset_table) do
		cleanup(asset_table)
	end
end

-- signals the removal of 1 reference to an asset
-- argument asset_table can be a string for the asset type 
-- instead of an asset_table, such as "model" or "texture"
function Loader:deref(asset_table, filename)
	assert(asset_table, filename)

	local asset_table = asset_table
	if type(asset_table) == "string" then
		asset_table = self.type_str_to_asset_table[asset_table]
	end

	local asset = asset_table[filename]
	if not asset then
		error(string.format("Loader:deref(): %s%s is not loaded", asset_table.__dir, tostring(filename))) end

	local ref_counts = asset_table.__ref_counts
	local ref_count = ref_counts[filename]
	if ref_count <= 0 then
		error(string.format("Loader:deref(): %s%s has %d references, reference underflow",
		asset_table.__dir, tostring(filename), ref_count)) end

	print(string.format("Loader:deref(): %s%s refcount %d -> %d", asset_table.__dir, filename, ref_counts[filename], ref_counts[filename]-1))
	ref_counts[filename] = ref_counts[filename] - 1
end

function Loader:ref(asset_table, filename)
	assert(asset_table, filename)

	local asset = asset_table[filename]
	if not asset then
		error(string.format("Loader:ref(): %s%s is not loaded", asset_table.__dir, tostring(filename))) end

	local ref_counts = asset_table.__ref_counts
	ref_counts[filename] = ref_counts[filename] + 1
	return ref_counts[filename]
end

function Loader:sendRequest( type , base_dir , filename )
	local id = self.request_channel:push{ type , base_dir , filename }
	-- add to list of ongoing requests
	self.requests[base_dir .. filename] = id
	self.requests_count = self.requests_count + 1
end

-- returns true if it popped something
-- otherwise false
-- finished requests are in the format { type , filename , asset , error_str }
-- failed requests have asset set to nil and give an error_str
--
-- if argument demand is set, it demands from the queue with a timeout of Loader.demand_timeout seconds
-- or timeout given
function Loader:popRequest( demand , timeout )
	local data = self.finished_channel:pop()
	if demand and not data then
		data = self.finished_channel:demand( timeout or self.demand_timeout )
	end

	if not data then return false end

	local asset_type = data[1]
	local filename = data[2]
	local asset = data[3]
	local error_str = data[4]

	local asset_table = self.type_str_to_asset_table[asset_type]
	assert(asset_table)

	-- remove from active requests
	self.requests[asset_table.__dir .. filename] = nil
	self.requests_count = self.requests_count - 1

	if not asset then
		print(string.format("Loader: failed to load %s%s, %s", asset_table.__dir, filename or "(nil)", error_str or ""))
		return true
	else
		print(string.format("Loader: %s%s success", asset_table.__dir, filename))
	end

	asset_table[filename] = self:finaliseAsset( asset_type , filename , asset )
	asset_table.__ref_counts[filename] = 0
	return true
end

-- the worker thread returns models without a Love2D mesh and images
-- as ImageData and not as textures, this function takes these incomplete
-- assets and finalises them on the main thread.
function Loader:finaliseAsset( type , filename , asset )
	local finalisers = require "assetfinalise"
	local func = finalisers[type]
	assert(func)
	return func(filename , asset)
end

function Loader:finishQueue()
	while self.requests_count > 0 do
		--self:popRequest( true , 0.1)
		self:popRequest( false )
	end
end

-- checks if an asset is being actively requested right now
function Loader:isCurrentlyRequested(base_dir, filename)
	local path = base_dir .. filename
	if self.requests[path] then
		return true end
	return false
end

function Loader:openAsset(type, filename)
	assert_type(filename, "string")
	local assets = self.type_str_to_asset_table[type]
	assert(assets)
	local base_dir = assets.__dir
	if assets[filename] then return end
	self:sendRequest( type , base_dir , filename )
	print(string.format("Loader:openAsset(\"%s\",\"%s\")", type, filename))
end


-- the openX functions send a request to load an asset
-- if an asset is needed you use the getX functions
function Loader:openModel(filename)
	self:openAsset("model", filename) end

function Loader:openTexture(filename)
	self:openAsset("texture", filename) end

function Loader:openMusic(filename)
	self:openAsset("music", filename) end

function Loader:openSound(filename)
	self:openAsset("sound", filename) end

function Loader:openTTF(filename)
	self:openAsset("ttf", filename) end

-- returns an asset and (important) increases it's reference count
-- if you call this function it's your responsibility to call Loader:deref()
-- once you get rid of your reference to the asset otherwise it'll forever stay cached
function Loader:getAssetReference(type, filename)
	assert_type(filename, "string")
	local assets = self.type_str_to_asset_table[type]
	assert(assets)
	local base_dir = assets.__dir

	local already_loaded = assets[filename]
	if already_loaded then
		self:ref(assets, filename)
		return already_loaded
	end

	-- we check if there's an ongoing request for this asset before making
	-- a new one
	local is_in_queue = self:isCurrentlyRequested(base_dir, filename)
	if not is_in_queue then
		self:sendRequest( type , base_dir , filename )
	end

	self:finishQueue()

	local loaded = assets[filename]
	if not loaded then
		error(string.format("Loader:getAssetReference(): failed to load and get asset %s%s", base_dir, filename))
	end

	self:ref(assets, filename)
	return loaded
end

function Loader:getModelReference(filename)
	return Loader:getAssetReference("model", filename) end
function Loader:getTextureReference(filename)
	return Loader:getAssetReference("texture", filename) end
function Loader:getSoundReference(filename)
	return Loader:getAssetReference("sound", filename) end
function Loader:getMusicReference(filename)
	return Loader:getAssetReference("music", filename) end
function Loader:getTTFReference(filename)
	return Loader:getAssetReference("ttf", filename) end

function Loader:queryAsset(type, filename)
	assert_type(filename, "string")
	local assets = self.type_str_to_asset_table[type]
	assert(assets)
	local base_dir = assets.__dir

	local already_loaded = assets[filename]
	if already_loaded then
		self:ref(assets, filename)
		return already_loaded
	end

	-- we check if there's an ongoing request for this asset
	local is_in_queue = self:isCurrentlyRequested(base_dir, filename)
	if is_in_queue then
		self:finishQueue()
	end

	local now_loaded = assets[filename]
	if now_loaded then
		self:ref(assets, filename)
		return now_loaded
	end
end

function Loader:queryModel(filename)
	return Loader:queryAsset("model", filename) end
function Loader:queryTexture(filename)
	return Loader:queryAsset("texture", filename) end
function Loader:querySound(filename)
	return Loader:queryAsset("sound", filename) end
function Loader:queryMusic(filename)
	return Loader:queryAsset("music", filename) end
function Loader:queryTTF(filename)
	return Loader:queryAsset("ttf", filename) end

function Loader:getReferenceCount(type, filename)
	return self.type_str_to_asset_table[type].__ref_counts[filename]
end
