require "io"

local fileio = {}

function fileio:dataFromFile(filepath)
	local f = assert(io.open(filepath, "rb"))
	local t = f:read("*all")
	f:close()
	local data = love.filesystem.newFileData(t,filepath)
	return data
end

function fileio:writeToFile(filedata, filepath)
	local f = assert(io.open(filepath, "wb"))
	local t = f:write(filedata:getString())
	f:close()
end

return fileio
