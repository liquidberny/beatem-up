local p1

function love.load()
  Object = require("lib/classic")
  local Player = require("player")
  
  p1 = Player(100, 100)
end

function love.update(dt)
  p1:update(dt)
end

local r, g, b = love.math.colorFromBytes(132, 193, 238)
love.graphics.setBackgroundColor(r, g, b)

function love.draw()
  p1:draw()
end