-- 
-- Remembers the last directory used to open/save a file
--

require 'string'

local dirmem = {
	_prev = {},
}

local slash = "/"
if love.system.getOS() == "Windows" then
	slash = "\\"
end

local function get_home()
	if love.system.getOS() == "Windows" then
		return os.getenv("USERPROFILE") or "C:\\"
	else
		return os.getenv("HOME") or "~/"
	end
end

local function to_path(f)
	local sl = string.len(f)
	for i=sl,1,-1 do
			if f:sub(i,i) == slash then
				return f:sub(1,i)
			end
	end

	return get_home()
end

dirmem.memo = function(to, filepath)
	dirmem._prev[to] = to_path(filepath)
end
dirmem.init = function(to, filepath)
	if not dirmem._prev[to] then dirmem.memo(to, filepath) end
end

dirmem.get = function(from)
	return dirmem._prev[from] or get_home()
end

return dirmem
