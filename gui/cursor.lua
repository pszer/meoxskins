--
-- cursor
--

local cursor = {

	_arrow = love.mouse.getSystemCursor("arrow"),
	_ibeam = love.mouse.getSystemCursor("ibeam"),
	_cross = love.mouse.getSystemCursor("crosshair"),
	_hand = love.mouse.getSystemCursor("hand"),
	_no = love.mouse.getSystemCursor("no"),

}

function cursor.arrow() love.mouse.setCursor(cursor._arrow) end
function cursor.ibeam() love.mouse.setCursor(cursor._ibeam) end
function cursor.cross() love.mouse.setCursor(cursor._cross) end
function cursor.hand() love.mouse.setCursor(cursor._hand) end
function cursor.no() love.mouse.setCursor(cursor._no) end

return cursor
