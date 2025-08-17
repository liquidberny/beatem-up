Character = Object:extend()

function Character:new(x, y)
  self.x = x
  self.y = y
  self.health = 100
  self.speed = 100
end

return Character

