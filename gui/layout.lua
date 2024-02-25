--
-- map edit gui layout formatting object
--

require "prop"

local guirender = require 'gui.guidraw'

local MapEditGUILayout = {
	__type="mapeditlayout"
}
MapEditGUILayout.__index = MapEditGUILayout

--
-- layout holds gui objects as a parent and positions them
-- according to a specified layout.
--
-- the layout argument specifies the layout by regions.
-- its format is as follows
--
-- 1. { id = string, split_type = "+x"/"+y"/"-x"/"-y", split_ratio = (0,1), sub = {...} }
-- 2. { id = string, split_type = "+x"/"+y"/"-x"/"-y", split_pix = [0,...), sub = {...} }
-- 3. { id = string, split_type = nil }
--
-- the split_type determines the way the region is split, "x" creates two regions
-- side by side horizontally and "y" vertically, id is the identifier string
-- for the left/top region created by a +x/+y split or the right/bottom region created
-- by a -x/-y split.
--
-- split_ratio/split_pix determines the way in which the region is split, split_ratio is number from
-- 0 to 1, increasing in the positive x/y direction, split_ratio=0.5 would split the regions equally in half.
-- split_pix is a fixed number in pixels.
--
-- sub specifies the layout of the subregion created by the split, which in turn can create furhter splits.
--
--
-- each argument after that is a table containing {string, function}
-- the string is the name for a region in this layout, function is a function(region) that returns x,y,w,h
-- the region argument it takes in will be filled in with the x,y,w,h of the previously specified layout
--

function MapEditGUILayout:define(layout, ...)
	local elements_def = { ... }

	local obj = {
		new = function(self, X, Y, w, h, elements)
			assert(X and Y)

			local this = {
				__type = "guilayout",
				layout = layout,
				layout_map = {},
				elements = elements,
				x = Y,
				y = X,
				w = w,
				h = h,
			}

			function this:setX(x)
				self.x=x end
			function this:setY(y)
				self.y=y end
			function this:setW(w)
				self.w=w
			end
			function this:setH(h)
				self.h=h
			end

			function this:updateXywh()
				local function update_xywh(layout, x,y,w,h, update_xywh)
					-- finish recursion
					if not layout then return end

					local stype = layout.split_type
					-- leaf region
					if stype == nil then
						layout.x,layout.y,layout.w,layout.h = x,y,w,h
						return
					end

					local xoffset,yoffset=nil,nil
					if layout.split_ratio then
						xoffset = layout.split_ratio*w
						yoffset = layout.split_ratio*h
					elseif layout.split_pix then
						xoffset = layout.split_pix
						yoffset = layout.split_pix
					else
						error("zomg")
					end

					if stype == "+x" then
						-- layout for the left region of the split
						layout.x = x
						layout.y = y
						layout.w = xoffset
						layout.h = h

						update_xywh(layout.sub,
						-- right region
						--  x     y     w       h
						 x+xoffset, y, w-xoffset, h,
						 update_xywh)
					elseif stype == "-x" then
						-- layout for the right region of the split
						layout.x = w-xoffset
						layout.y = y
						layout.w = xoffset
						layout.h = h

						update_xywh(layout.sub,
						-- left region
						-- x  y     w     h
						   x, y, w-xoffset, h,
						   update_xywh)
					elseif stype == "+y" then
						-- layout for the top region of the split
						layout.x = x
						layout.y = y
						layout.w = w
						layout.h = yoffset

						update_xywh(layout.sub,
						-- bottom region
						--  x     y     w      h
						    x, y+yoffset, w, h-yoffset,
						    update_xywh)
					elseif stype == "-y" then
						-- layout for the bottom region of the split
						layout.x = x
						layout.y = yoffset
						layout.w = w
						layout.h = h-yoffset

						update_xywh(layout.sub,
						-- top region
						--  x  y  w     h
						    x, y, w, yoffset,
						    update_xywh)
					else
						error("unknown split type")
					end
				end
				update_xywh(self.layout, self.x,self.y,self.w,self.h, update_xywh)

				local int = math.floor
				for i,v in ipairs(self.elements) do
					local def = elements_def[i]
					local region_id = def[1]
					local xywh_func = def[2]
					-- calculate new x,y,w,h and give them to the element
					local x,y,w,h = xywh_func(self.layout_map[region_id])
					if v.setX then v:setX(int(x)) end
					if v.setY then v:setY(int(y)) end
					if v.setW then v:setW(int(w)) end
					if v.setH then v:setH(int(h)) end
				end
			end

			local function map_out(layout, map_out)
				if not layout then return end
				local id = layout.id
				assert(id, "MapEditGUILayout:define(): region has no id")
				local v = this.layout_map[id]
				if v then
					assert(id, "MapEditGUILayout:define(): duplicate region id") end
				this.layout_map[id] = layout
				map_out(layout.sub, map_out)
			end
			map_out(this.layout, map_out)

			for i,v in ipairs(elements_def) do
				assert(v[1] and v[2], "MapEditGUILayout:define(): malformed element definition")
				assert(this.layout_map[v[1]],string.format("MapEditGUILayout:define(): %s undefined region", v[1]))
				assert(type(v[2])=="function",string.format("MapEditGUILayout:define(): expected function", v[2]))
			end

			setmetatable(this, MapEditGUILayout)
			return this
		end
	}

	return obj
end

return MapEditGUILayout
