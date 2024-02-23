local skin = {

	layers = {},
	--layers_visible = {},

}

local ID_COUNTER=0
function skin:addLayer(texture, name, index, visible)
	if name==nil then
		ID_COUNTER = ID_COUNTER + 1
		name = "Layer "..tostring(ID_COUNTER)
	end
	
	if visible == nil then visible = true end
	local size = #self.layers
	if index < 1 then index = 1 end
	if index > size+1 then index = size+1 end
	table.insert(self.layers, index, { texture=texture, name=name, visible=visible })
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

return skin
