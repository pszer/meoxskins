local skin = {

	layers = {},

}

function skin:load(texture, name)
	local name = name or "Layer"
	self.layers = {}
	self:addLayer(texture, name, 1, true)
end

local NAME_COUNTER=0
local ID_COUNTER=0
function skin:addLayer(texture, name, index, visible)
	if name==nil then
		NAME_COUNTER = NAME_COUNTER + 1
		ID_COUNTER = ID_COUNTER + 1
		name = "Layer "..tostring(ID_COUNTER)
	end
	
	if visible == nil then visible = true end
	local size = #self.layers
	if index < 1 then index = 1 end
	if index > size+1 then index = size+1 end

	local canvas = love.graphics.newCanvas(64,64)
	canvas:setFilter("nearest","nearest")
	love.graphics.reset()
	love.graphics.setCanvas(canvas)
	if texture then
		love.graphics.draw(texture)
	end
	love.graphics.reset()

	local t
	t = 
		{ 
			texture=canvas,
			name=name,
			visible=visible,
			preview=nil,

			open_preview = function()
				love.graphics.reset()
				t.preview = love.graphics.newCanvas(64,64)
				t.preview:setFilter("nearest","nearest")
				love.graphics.setCanvas(t.preview)
				love.graphics.draw(t.texture)
				love.graphics.reset()
				return t.preview
			end,

			commit_preview = function()
				local old_texture = t.texture
				t.texture = t.preview
				return old_texture, t.texture
			end
		}
	table.insert(self.layers, index, t)
end

function skin:getLayerCount(layer)
	return #self.layers
end

function skin:getLayerIndex(layer)
	for i,v in ipairs(self.layers) do
		if v==layer then return i end
	end
	return nil
end

function skin:swapLayers(i1,i2)
	print(i1,i2)
	local temp = self.layers[i2]
	self.layers[i2] = self.layers[i1]
	self.layers[i1] = temp
end

function skin:insertLayer(layer, index)
	if index then
		table.insert(self.layers,index,layer)
	else
		table.insert(self.layers,layer)
	end
end

function skin:removeLayer(index)
	if type(index) == "number" then
		local layer = self.layers[index]
		table.remove(self.layers, index)
		return layer, index
	else
		local I
		for i,v in ipairs(self.layers) do
			if v==index then
				I=i
				break
			end
		end
		if I then
			local layer = self.layers[I]
			table.remove(self.layers, I)
			return layer, I
		end
	end
end

function skin:createEmptyLayer(name)
	if name==nil then
		NAME_COUNTER = NAME_COUNTER + 1
		ID_COUNTER = ID_COUNTER + 1
		name = "Layer "..tostring(ID_COUNTER)
	end
	local canvas = love.graphics.newCanvas(64,64)
	canvas:setFilter("nearest","nearest")
	local t
	t = 
		{ 
			texture=canvas,
			name=name,
			visible=true,
			preview=nil,

			open_preview = function()
				love.graphics.reset()
				t.preview = love.graphics.newCanvas(64,64)
				t.preview:setFilter("nearest","nearest")
				love.graphics.setCanvas(t.preview)
				love.graphics.draw(t.texture)
				love.graphics.reset()
				return t.preview
			end,

			commit_preview = function()
				local old_texture = t.texture
				t.texture = t.preview
				return old_texture, t.texture
			end
		}
	return t
end

function skin:emptyLayer()
	return love.graphics.newCanvas(64,64)
end

function skin:getLayers()
	return self.layers
end

function skin:getVisibleLayers()
	local t = {}
	for i,v in ipairs(self.layers) do
		if self.layers[i].visible then
			table.insert(t, v)
		end
	end
	return t
end

function skin:pickColour(pixels)
	local count = #self.layers
	
	table.sort(pixels, function(a,b) return a[3]<b[3] end)

	for _,pix in ipairs(pixels) do
		for i=count,1,-1 do
			local layer = self.layers[i]
			if layer.visible then
				local image_data = layer.texture:newImageData()

				local colour = {image_data:getPixel(pix[1]-1,pix[2]-1)}
				if colour[4] > 0.0 then return colour end
			end
		end
	end

	return nil
end

return skin
