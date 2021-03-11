local game = {}

local boards = {}
function game:init()
	local Board = require("src/board")
	local s = Feint.Core.Graphics.RenderSize.y / 2 + 20
	for x = 0, 2, 1 do
		for y = 0, 2, 1 do
			boards[x + y * 3] = Board:new(x * s, y * s)
		end
	end

	local Camera = require("src/camera")
	self.Camera = Camera:new()

	local modes = love.window.getFullscreenModes(1)
	for k, v in pairs(modes) do
		printf("width: %d, height %d\n", v.width, v.height)
	end
end

local Flux = Feint.Util.Tween.Flux
function game:update(dt)
	for k, v in pairs(boards) do
		v:update()
	end
	local cameraMoveSpeed = 20
	if love.keyboard.isDown("a") then
		self.Camera:moveBy(-cameraMoveSpeed, 0)
	end
	if love.keyboard.isDown("d") then
		self.Camera:moveBy(cameraMoveSpeed, 0)
	end
	if love.keyboard.isDown("w") then
		self.Camera:moveBy(0, cameraMoveSpeed)
	end
	if love.keyboard.isDown("s") then
		self.Camera:moveBy(0, -cameraMoveSpeed)
	end
	self.Camera:update(dt)
	Flux.update(dt)
end

function love.wheelmoved(x, y)
	game.Camera:changeZoom(y * 0.2)--(y / math.abs(y)) / math.exp(1.2 * math.abs(y)))
end

function game:draw()
	for k, v in pairs(boards) do
		v:draw()
	end
end

return game
