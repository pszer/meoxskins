--[[ utility functions for creating input validity functions for
--   property tables
--]]
--

require 'math'

require "set"

-- limits property to be one of the entries in given table argument t
function PropIsOneOf(t)
	return function(x)
		-- if x is in t then its a valid unput
		for _,v in pairs(t) do
			if v == x then
				return true, x
			end
		end
		-- otherwise its a bad input
		return false, t[0]
	end
end

-- limits numbers to integers
function PropInteger()
	return function (x)
		return true, math.floor(x)
	end
end

-- limits numbers to >= m
function PropMin(m)
	return function (x)
		return true, math.max(m,x)
	end
end

-- limits numbers to <= m
function PropMax(m)
	return function (x)
		return true, math.min(m,x)
	end
end

-- limits numbers to a <= x <= b
function PropClamp(a,b)
	return function (x)
		return true, math.max(a , math.min(x,b))
	end
end

-- limits numbers to integers >= m
function PropIntegerMin(m)
	return function (x)
		return true, math.max(m,math.floor(x))
	end
end

-- limits numbers to integers <= m
function PropIntegerMax(m)
	return function (x)
		return true, math.min(m,math.floor(x))
	end
end

-- limits numbers to integers a <= x <= b
function PropIntegerClamp(a,b)
	return function (x)
		return true, math.max(a , math.min(math.floor(x),b))
	end
end

--[[ when a properties default value is a table literal, that table is not unique
--   and becomes shared across all property tables with that table as default
--   this valid function will give a new table instance if the property is set to nil
--]]
function PropDefaultTable(table)
	return function(x)
		if not x then
			local t = {}
			for i,v in pairs(table) do t[i]=v end
			return true, t
		else
			return true, x
		end
	end
end

function PropDefaultFunction(func)
	return function(x)
		if not x then
			return true, func()
		else
			return true, x
		end
	end
end

local cpml = require 'cpml'
local mat4new = cpml.mat4.new
function PropDefaultMatrix(table)
	return function(x)
		if not x then
			local t = mat4new(table)
			return true, t
		else
			return true, x
		end
	end
end

function PropEmptySet()
	return function(x)
		if not x then
			return true, Set:new()
		else
			return true, x
		end
	end
end

--[[ utility function used in creating properties that are links
--   to properties in other tables
--
--   should only be used in linking properties of children objects
--   to properties of parent objects
--]]
--

function PropLink(parent_prop, key)
	local l = {
		function()
			return parent_prop[key]
		end,
		function(x)
			parent_prop[key] = x
		end,
		__type = "link"
	}
	setmetatable(l,l)
	return l
end

-- use in situations where a property is expected to be linked
-- but only a constant value is required
function PropConst(const)
	local l = {
		function()
			return const
		end,
		function(x)
			const = x
		end,
		__type = "link"
	}
	setmetatable(l,l)
	return l
end
