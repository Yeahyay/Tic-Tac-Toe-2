local board = {}

function board:new()
	local newBoard = {}
	setmetatable(newBoard, {
		__index = self
	})
	newBoard:init(newBoard)
	return newBoard
end

function board:init()
	self.sizeX = 0
	self.sizeY = 0
	self.layout = {}
end

function board:newBoard(sizeX, sizeY)
	self.sizeX = sizeX
	self.sizeY = sizeY
	for x = 1, sizeY, 1 do
		for y = 1, sizeX, 1 do
			self.layout[sizeX * (sizeY)] = -1
		end
	end
end

function board:draw()
	for x = 1, self.sizeY, 1 do
		for y = 1, self.sizeX, 1 do
			love.graphics.rectangle("line", x * self.sizeX, y * self.sizeY, self.sizeX, self.sizeY)
		end
	end
end
function board:update()

end

return board
