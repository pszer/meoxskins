require "io"

local fileio = {}

function fileio:dataFromFile(filepath)
	local f = assert(io.open(filepath, "r"))
	local t = f:read("*all")
	local data = love.filesystem.newFileData(t,filepath)
	return data
end

function fileio:writeToFile(filedata, filepath)
	local f = assert(io.open(filepath, "w"))
	local t = f:write(filedata:getString())
end

return fileio
