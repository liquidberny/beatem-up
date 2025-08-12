local p1

function love.load()
  Object = require("lib/classic")
  local Player = require("player")
  
  p1 = Player(100, 100)
end

function love.update(dt)
  p1:update(dt)
end

function love.draw()
  p1:draw()
end