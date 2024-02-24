local skin = {

	layers = {},
	--layers_visible = {},

}

function skin:load(texture, name)
	local name = name or "Layer"
	self.layers = {}
	self:addLayer(texture, name, 1, true)
end

local NAME_COUNTER=0
function skin:addLayer(texture, name, index, visible)
	if name==nil then
		NAME_COUNTER = NAME_COUNTER + 1
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
	love.graphics.draw(texture)
	love.graphics.reset()

	table.insert(self.layers, index, { texture=canvas, name=name, visible=visible, edit=nil })
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
