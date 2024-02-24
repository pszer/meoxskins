local skin = {

	layers = {},

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
