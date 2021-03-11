-- CORE FILE

-- luacheck: push ignore
local Paths = Feint.Core.Paths
local Math = Feint.Math
local Util = Feint.Util
local Graphics = Feint.Core.Graphics
local LoveGraphics = love.graphics
local Time = Feint.Core.Time
local Log = Feint.Log
local Core = Feint.Core
local Input = Feint.Core.Input
Util.Debug.logLevel = 2

-- It sets up a default world and passes love callbacks to the ECS
local World = Feint.ECS.World
local Mouse = Input.Mouse

-- function cache
local getTime = love.timer.getTime

-- fps counter variables
local	fpsList
local fpsIndex
local fpsSum

local fpsGraph1
local memGraph1

local DEFAULT_FONT
local DEFAULT_FONT_BOLD
local DEFAULT_FONT_HEIGHT

-- direct requires (BAD BUT EASY)
local ffi = require("ffi")
local Game = require("src/game")

-- luacheck: pop ignore

-- local oldRate = Time.rate
function love.keypressed(key, ...)
	if key == "space" then
		print(Time:isPaused())
		if Time:isPaused() then
			print("PLAY")
			Time:unpause()
		else
			print("PAUSE")
			Time:pause()
		end
	end
end
function love.keyreleased(...)
end

function love.mousemoved(x, y, dx, dy)
	Input.mousemoved(x, y, dx, dy)
end

function love.mousepressed(...)
end
function love.mousereleased(...)
end

function love.threaderror(thread, message)
	error(string.format("Thread (%s): Error \"%s\"\n", thread, message), 2)
end
function love.resize(x, y)
	Graphics:setScreenResolution(x, y)
	-- love.draw()
	-- Graphics:draw()
end

function love.load()
	Time.framerate = -1 -- 60 -- framerate cap
	Time.rate = 1 / 60 -- update dt
	Time.sleep = 0.001 -- don't toast the CPU
	Time:setSpeed(1) -- default game speed

	fpsList = {}
	for i = 1, Time.G_AVG_FPS_DELTA_ITERATIONS, 1 do
		fpsList[i] = 0
	end
	fpsIndex = 1
	fpsSum = 0

	love.math.setRandomSeed(Math.G_SEED)

	DEFAULT_FONT = LoveGraphics.newFont("Assets/fonts/FiraCode-Regular.ttf", 28)
	DEFAULT_FONT_BOLD = LoveGraphics.newFont("Assets/fonts/FiraCode-Bold.ttf", 28)
	DEFAULT_FONT_HEIGHT = DEFAULT_FONT:getHeight()
	LoveGraphics.setFont(DEFAULT_FONT)

	Game:init()

	-- Immediate Mode GUI
	-- Graphics.UI.Immediate.Initialize()
end


function love.update(dt)
	Time:update()
	Time:setSpeed(Mouse.PositionNormalized.x)
	Graphics.clear()

	local startTime = getTime()

	-- Feint.Core.Thread:update()

	Game:update(dt)

	-- if Graphics.UI.Immediate then
	-- 	Graphics.UI.Immediate.Update(dt)
	-- end

	local endTime = getTime()

	Time.G_UPDATE_DT = endTime - startTime

	Time.G_UPDATE_TIME = Time.G_UPDATE_TIME + (Time.G_UPDATE_DT - Time.G_UPDATE_TIME) * (1 - Time.G_UPDATE_TIME_SMOOTHNESS)

	Time.G_UPDATE_TIME_PERCENT_FRAME = Time.G_UPDATE_TIME / (Time.rate) * 100

	Graphics.UI.Immediate.Update(Time.G_RENDER_DT)
end

local function updateRender(dt) -- luacheck: ignore
end

local function debugDraw()
	LoveGraphics.printf(
		Time:isPaused() and string.format("Game Speed: %s\n", "Paused") or
		string.format("Game Speed: %.3f\n", Time:getSpeed()),
		400, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)

	-- FPS
	LoveGraphics.printf(
		string.format("FPS:      %7.2f, DT:      %7.4fms\n", Time.G_FPS, 1000 * Time.G_FPS_DELTA),
		0, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)
	-- [[
	LoveGraphics.printf(
		string.format("FPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Time.G_AVG_FPS, 1000 * Time.G_AVG_FPS_DELTA),
		0, DEFAULT_FONT_HEIGHT / 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("FPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Time.dt, 1000 * Time.dt),
		0, DEFAULT_FONT_HEIGHT / 2 * 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- UPDATE TIME
	LoveGraphics.printf(
		string.format("UPDATE:     %8.4fms, %6.2f%% 60Hz\n", 1000 * Time.G_UPDATE_TIME, Time.G_UPDATE_TIME_PERCENT_FRAME),
		0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE AVG: %8.4fms, %6.2f%% 60Hz\n", 0, 0),
		0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE TRUE:%8.4fms, %6.2f%% 60Hz\n", 1000 * Time.G_UPDATE_DT, Time.G_UPDATE_DT / (Time.rate) * 100),
		0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	-- RENDER TIME
	LoveGraphics.printf(
		string.format("RENDER:     %8.4fms, %6.2f%% Frame\n", 1000 * Time.G_RENDER_TIME, Time.G_RENDER_TIME_PERCENT_FRAME),
		350, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER AVG: %8.4fms, %6.2f%% Frame\n", 0, 0),
		350, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER TRUE:%8.4fms, %6.2f%% Frame\n", 1000 * Time.G_RENDER_DT, Time.G_RENDER_DT / (Time.rate) * 100),
		350, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	LoveGraphics.printf(
		string.format("FRAME BUDGET: %6.2f%% Frame\n", Time.G_UPDATE_TIME_PERCENT_FRAME + Time.G_RENDER_TIME_PERCENT_FRAME),
		400, DEFAULT_FONT_HEIGHT / 2 * 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)


	-- LoveGraphics.printf(
	-- 	string.format("TPS:      %7.2f, DT:      %7.4fms\n", Time.G_TPS, 1000 * Time.G_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Time.G_AVG_TPS, 1000 * Time.G_AVG_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Time.rate, 1000 * Time.rate),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )

	-- MEMORY
	LoveGraphics.printf(string.format("Memory Usage (MiB):   %12.2f", Core.Util.getMemoryUsageKiB() / 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 8, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (KiB):   %12.2f", Core.Util.getMemoryUsageKiB()),
		0, DEFAULT_FONT_HEIGHT / 2 * 9, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (bytes): %12.2f", Core.Util.getMemoryUsageKiB() * 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 10, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- DRAWING
	local stats = LoveGraphics.getStats()
	LoveGraphics.printf(string.format("Draw calls: %d", stats.drawcalls),
		0, DEFAULT_FONT_HEIGHT / 2 * 12, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Texture Memory: %d bytes", stats.texturememory),
		0, DEFAULT_FONT_HEIGHT / 2 * 13, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	--]]

	-- LoveGraphics.printf(string.format("Entity Count: %d", World.DefaultWorld.EntityManager:getEntityCount()),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 15, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- local queueCacheData = World.DefaultWorld.EntityManager:getQueueCacheDebug()
	-- local i = 0
	-- for k, v in pairs(queueCacheData) do
	-- 	i = i + 1
	-- 	LoveGraphics.printf(string.format("%-20.20s: %0.6f ms", k, v.runTime * 1000),
	-- 		0, DEFAULT_FONT_HEIGHT / 2 * (16 + i - 1), Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- 	)
	-- end
end
function love.draw(dt)
	do
		Time.G_FPS_DELTA = Time.G_FPS_DELTA + (Time.dt - Time.G_FPS_DELTA) * (1 - Time.G_FPS_DELTA_SMOOTHNESS)
		Time.G_FPS = 1 / Time.G_FPS_DELTA
	end

	do
		fpsSum = fpsSum -	fpsList[fpsIndex] + Time.dt
		fpsList[fpsIndex] = Time.dt
		fpsIndex = fpsIndex % Time.G_AVG_FPS_DELTA_ITERATIONS + 1
		Time.G_AVG_FPS_DELTA = fpsSum / Time.G_AVG_FPS_DELTA_ITERATIONS

		Time.G_AVG_FPS = 1 / Time.G_AVG_FPS_DELTA
	end

	Time.G_INT = Time.accum / math.max(0, Time.rate)

	local startTime = getTime()

	-- LoveGraphics.setCanvas(canvas)
	-- LoveGraphics.clear()
	-- LoveGraphics.setColor(0.5, 0.5, 0.5, 1)
	-- LoveGraphics.rectangle("fill", 0, 0, Graphics.ScreenSize.x, Graphics.ScreenSize.y)
	-- LoveGraphics.setColor(1, 1, 1, 1)
	-- LoveGraphics.push()
	-- 	LoveGraphics.scale(Graphics.ScreenToRenderRatio.x, Graphics.ScreenToRenderRatio.y)
	-- 	LoveGraphics.translate(Graphics.ScreenSize.x / 2, Graphics.ScreenSize.y / 2)
	-- 	-- LoveGraphics.setWireframe(true)
	Graphics:updateInterpolate(Time.accum)
	-- 	-- Graphics.processQueue()
	Graphics:draw(Game)
	-- 	-- LoveGraphics.setWireframe(false)
	-- LoveGraphics.pop()
	-- LoveGraphics.setCanvas()
	-- -- print(Graphics.RenderToScreenRatio, Graphics.ScreenToRenderRatio)
	-- -- LoveGraphics.translate(720 * Graphics.ScreenToRenderRatio.x / 2, 1)
	-- local sx, sy = Graphics.RenderToScreenRatio.x, Graphics.RenderToScreenRatio.y
	-- LoveGraphics.draw(canvas, 0, 0, 0, sx, sy, 0, 0)
	-- -- LoveGraphics.draw(canvas, 50, 50, 0, 1, 1, 0, 0)

	-- Graphics.UI.Immediate.Draw(Time.G_RENDER_DT)

	-- fpsGraph.drawGraphs(2, {fpsGraph1, memGraph1})
	-- LoveGraphics.setFont(DEFAULT_FONT)

	-- Game:draw()

	debugDraw()

	local endTime = getTime()

	Time.G_RENDER_DT = endTime - startTime

	Time.G_RENDER_TIME = Time.G_RENDER_TIME + (Time.G_RENDER_DT - Time.G_RENDER_TIME) * (1 - Time.G_RENDER_TIME_SMOOTHNESS)

	Time.G_RENDER_TIME_PERCENT_FRAME = Time.G_RENDER_TIME / (Time.rate) * 100


	--[[
	local f = 60
	acc = acc + Time.G_RENDER_DT * f
	while acc > 1 / 60 do
		updateRender(acc)
		acc = acc - 1 / 60
	end
	--]]
end
function love.quit()
end

Util.Debug.PRINT_ENV(_G, false)

printf("\n")
Log.log("Exiting run.lua\n")
