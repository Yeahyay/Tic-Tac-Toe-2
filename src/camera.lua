local camera = {}

function camera:new(...)
	local newCamera = {}
	setmetatable(newCamera, {
		__index = self
	})
	newCamera:init(...)
	return newCamera
end

local Flux = Feint.Util.Tween.Flux

function camera:init()
	self.Zoom = 0
	self.ZoomLevel = 0
	self.ZoomRange = 4
	self.Position = Feint.Math.Vec2(0, 0)
	self.PositionTo = Feint.Math.Vec2(0, 0)
	self.Velocity = Feint.Math.Vec2(0, 0)
	self.Bounds = {
		Feint.Math.Vec2(Feint.Core.Graphics.ScreenSize.x * 0.5, Feint.Core.Graphics.ScreenSize.y * 0.5);
		Feint.Math.Vec2(-Feint.Core.Graphics.ScreenSize.x * 0.5, -Feint.Core.Graphics.ScreenSize.y * 0.5);
	}
end

function camera:update()
	-- self.Velocity = self.Velocity * 0.9
	-- self.Position = self.Position + self.Velocity
	-- self.Zoom = math.exp(1 * self.ZoomLevel)
	Flux.to(self.Position, 0.15, {x = self.PositionTo.x, y = self.PositionTo.y}):ease("quadout")
	Flux.to(self, 0.15, {Zoom = math.pow(2, self.ZoomLevel)}):ease("quadout")
end

function camera:setPosition(x, y)
	self.Position:set(x, y)
end

function camera:moveBy(x, y)
	-- local Velocity = self.Velocity
	-- Velocity.x = Velocity.x + x
	-- Velocity.y = Velocity.y + y
	local PositionTo = self.PositionTo
	PositionTo.x = PositionTo.x + x
	PositionTo.y = PositionTo.y + y
end

function camera:changeZoom(zoom)
	self:setZoom(self.ZoomLevel + zoom)
end

function camera:setZoom(zoom)
	self.ZoomLevel = Feint.Math.clamp(zoom, -1, 1)
end

return camera
