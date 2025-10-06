local Character = require("character")
local anim8 = require "lib.anim8"

local Enemy = Character:extend()

function Enemy:new(x, y)
    Enemy.super.new(self, x, y, 50)

    self.walkingImage = love.graphics.newImage("Sprites/Enemy/Walk.png")
    self.idleImage = love.graphics.newImage("Sprites/Enemy/Idle.png")
    self.punchImage = love.graphics.newImage("Sprites/Enemy/Punch.png")
    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    local singleG = anim8.newGrid(20, 32, self.punchImage:getWidth(), self.punchImage:getHeight())

    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.punch = anim8.newAnimation(singleG(1, 1), 0.5)

    self.moving = false
    self.punching = false
    
    self.scaleX = 1 
    self.offsetX = 8 
end

function Enemy:update(dt, world, px, py)
    self.animation:update(dt)
    self.moving = true
    local dx = self.x - px
    local dy = self.y - py

    local distance = math.sqrt(dx * dx + dy * dy)
    
    
    if px > self.x then
        self.scaleX = 1 
    elseif px < self.x then
        self.scaleX = -1 
    end

    local angle = math.atan2(py - self.y, px - self.x)
    local cos = math.cos(angle)
    local sin = math.sin(angle)

    if distance < 16 then
        self.moving = false
    else
        self.x = self.x + cos * self.speed * dt
        self.y = self.y + sin * self.speed * dt
    end
end

function Enemy:draw()
    local img = self.moving and self.walkingImage or self.punching and self.punchImage or self.idleImage
    local animation = self.punching and self.punch or self.animation

    animation:draw(img, self.x, self.y, nil, self.scaleX, 1, self.offsetX)
end

return Enemy