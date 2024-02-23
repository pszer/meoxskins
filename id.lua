--[[ utility function for giving out unique ids
--]]
--
-- UniqueID() returns a function which gives incrementing numbers upon every call
-- maybe a lil pointless, but i like how it reads :3

function UniqueID()
	local t = 0
	return function()
		local s = t
		t = t + 1
		return s
	end
end

-- give what this returns as an input validating function to a property
-- table to turn that property into a guaranteed unique id!
function UniqueID_Valid()
	local id = UniqueID()
	return function (i)
		return true, id()
	end
end
