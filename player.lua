local Character = require("character")
local anim8 = require "lib.anim8"

local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)

    self.walkingImage = love.graphics.newImage("Sprites/Walk_1.png")
    self.idleImage = love.graphics.newImage("Sprites/Idle_1.png")

    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)

    self.moving = false
    self.forward = true
end

function Player:update(dt)
    self.moving = false
    self.animation:update(dt)

    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.moving = true

        if self.forward then
            self.forward = false
            self.animation:flipH()
        end
    end

    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.moving = true

        if not self.forward then
            self.forward = true
            self.animation:flipH()
        end
    end

    if love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.moving = true
    end
    if love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.moving = true
    end
end


function Player:draw()
    local img = self.moving and self.walkingImage or self.idleImage

    self.animation:draw(img, self.x, self.y, 0 , 3, 3)
end

return Player
