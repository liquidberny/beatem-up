local p1

function love.load()
  Object = require("lib/classic")
  local Player = require("player")
  sti = require("lib/sti")
  gameMap = sti("Maps/Street.lua")
  p1 = Player(100, 100)
end

function love.update(dt)
  p1:update(dt)
end

local r, g, b = love.math.colorFromBytes(132, 193, 238)
love.graphics.setBackgroundColor(r, g, b)

function love.draw()
  gameMap:draw(0,0,2,2)
  p1:draw()
end