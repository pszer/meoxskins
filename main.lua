local cpml = require 'cpml'

local dialog = require 'dialog'
local cube   = require 'cube'
local camera = require 'camera'
local render = require 'render'
local model  = require 'model'
local skin   = require 'skin'
local edit   = require 'edit'

require "assetloader"

function love.load( args )
	args = args or {}
	local skin_name = args[1]
	local skin_mode = args[2]

	if skin_mode and not (skin_mode == "wide" or skin_mode == "slim") then
		error("meoxskins expects argument ./meoxskins filename wide/slim")
	elseif not skin_mode then
		skin_mode = "wide"
	end

	model:generateModelMatrix()

	Loader:initThread()

	edit:load{skin_name = skin_name, skin_mode = skin_mode}

	camera:setPos(0,0,-16)
	camera:calcProj()
	render:createCanvas()

	edit:checkAutosaveRecover()
end

function love.update(dt)
	local t = love.timer.getTime()
	camera:calcMat()
	edit:update(dt)
	updateKeys()

	love.timer.sleep(0.0022)
end

function love.draw()
	edit:draw()
end

function love.resize()
	camera:calcProj()
	render:createCanvas()
	if GAMESTATE.resize then GAMESTATE:resize() end
end

GAMESTATE = edit
function love.keypressed(key, scancode, isrepeat)
	__keypressed(key, scancode, isrepeat)
	if GAMESTATE.keypressed then GAMESTATE:keypressed(key, scancode, isrepeat) end
end

function love.keyreleased(key, scancode)
	__keyreleased(key, scancode)
	if GAMESTATE.keyreleased then GAMESTATE:keyreleased(key, scancode) end
end

function love.mousepressed(x, y, button, istouch, presses)
	__mousepressed(x, y, button, istouch, presses)
	if GAMESTATE.mousepressed then GAMESTATE:mousepressed(x, y, button, istouch, presses) end
end

function love.mousereleased(x, y, button, istouch, presses)
	__mousereleased(x, y, button, istouch, presses)
	if GAMESTATE.mousereleased then GAMESTATE:mousereleased(x, y, button, istouch, presses) end
end

function love.mousemoved(x,y,dx,dy,istouch)
	if GAMESTATE.mousemoved then GAMESTATE:mousemoved(x,y,dx,dy,istouch) end
end

function love.wheelmoved(x,y)
	__wheelmoved(x,y)
	if GAMESTATE.wheelmoved then GAMESTATE:wheelmoved(x,y) end
end

function love.textinput(t)
	if GAMESTATE.textinput then GAMESTATE:textinput(t) end
end

function love.wheelmoved(x,y)
	__wheelmoved(x,y)
	if GAMESTATE.wheelmoved then GAMESTATE:wheelmoved(x,y) end
end

function love.quit()
	if GAMESTATE.quit then GAMESTATE:quit() end
end

function love.filedropped(file)
	if GAMESTATE.filedropped then
		GAMESTATE:filedropped(file)
	end
end
