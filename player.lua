local Character = require("character")
local anim8 = require "lib.anim8"

local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)

    self.walkingImage = love.graphics.newImage("Sprites/Walk_1.png")
    self.idleImage = love.graphics.newImage("Sprites/Idle_1.png")

    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    self.walkingAnimation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.idleAnimation = anim8.newAnimation(g('1-4', 1), 0.1)

    self.moving = false
end

function Player:update(dt)

    self.moving = false

    self.idleAnimation:update(dt)

    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.moving = true
        self.walkingAnimation:update(dt)
    end
    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.walkingAnimation:update(dt)
        self.moving = true
    end
    if love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.walkingAnimation:update(dt)
        self.moving = true
    end
    if love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.walkingAnimation:update(dt)
        self.moving = true
    end

end

function Player:draw()
    local anim = self.moving and self.walkingAnimation or self.idleAnimation
    local img = self.moving and self.walkingImage or self.idleImage

    anim:draw(img, self.x, self.y, 0 , 3, 3)
end

return Player
