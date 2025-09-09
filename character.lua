Character = Object:extend()

function Character:new(x, y, speed)
  self.x = x
  self.y = y
  self.health = 100
  self.speed = speed or 100
end

return Character

