local Character = require("character")
local anim8 = require "lib.anim8"

local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)

    self.walkingImage = love.graphics.newImage("Sprites/Walk_1.png")
    self.idleImage = love.graphics.newImage("Sprites/Idle_1.png")
    self.punchImage = love.graphics.newImage("Sprites/Punch.png")
    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    local singleG = anim8.newGrid(20, 32, self.punchImage:getWidth(), self.punchImage:getHeight())
    
    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.punch = anim8.newAnimation(singleG(1,1), 0.5 )

    self.moving = false
    self.punching = false
    self.forward = true
end

function Player:update(dt)
    self.moving = false
    self.punching = false


    self.animation:update(dt)
    
    if love.keyboard.isDown("z") then
        self.moving = false
        self.punching = true
    end

    if love.keyboard.isDown("left") and self.punching == false then
        self.x = self.x - self.speed * dt
        self.moving = true

        if self.forward then
            self.forward = false
            self.animation:flipH()
            self.punch:flipH()
        end
    end

    if love.keyboard.isDown("right") and self.punching == false then
        self.x = self.x + self.speed * dt
        self.moving = true

        if not self.forward then
            self.forward = true
            self.animation:flipH()
            self.punch:flipH()
        end
    end

    if love.keyboard.isDown("up") and self.punching == false then
        self.y = self.y - self.speed * dt
        self.moving = true
    end
    if love.keyboard.isDown("down") and self.punching == false then
        self.y = self.y + self.speed * dt
        self.moving = true
    end

end


function Player:draw()
    local img = self.moving and self.walkingImage or self.punching and self.punchImage or self.idleImage


    local animation = self.punching and self.punch or self.animation
    animation:draw(img, self.x, self.y, 0 , 3, 3)
end

return Player
