local board = {}

function board:new(...)
	local newBoard = {}
	setmetatable(newBoard, {
		__index = self
	})
	newBoard:init(...)
	return newBoard
end

function board:init(PositionX, PositionY, SizeX, SizeY)
	self.Position = Feint.Math.Vec2(PositionX or 0, PositionY or 0)
	self.Size = Feint.Math.Vec2(SizeX or 3, SizeY or 3)
	self.CellSize = Feint.Core.Graphics.RenderSize.y / self.Size.y / 2
	self.Layout = {}
end

function board:newBoard()
	local SizeX = self.Size.x
	local SizeY = self.Size.y
	for x = 1, SizeX, 1 do
		for y = 1, SizeY, 1 do
			self.Layout[SizeX * (SizeY)] = -1
		end
	end
end

function board:draw()
-- self.CellSize = Feint.Core.Graphics.ScreenSize.y / self.Size.y / 2
	local CellSize = self.CellSize
	local SizeX = self.Size.x
	local SizeY = self.Size.y
	local offsetX = - SizeX / 2 * CellSize
	local offsetY = - SizeY / 2 * CellSize
	local PositionX = self.Position.x + offsetX
	local PositionY = self.Position.y + offsetY
	love.graphics.setLineWidth(10)
	for x = 0, SizeX - 1, 1 do
		for y = 0, SizeY - 1, 1 do
			love.graphics.rectangle("line", PositionX + x * CellSize, PositionY + y * CellSize, CellSize, CellSize)
		end
	end
end
function board:update()

end

return board
