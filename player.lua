local Character = require("character")
local anim8 = require "lib.anim8"

local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)

    self.walkingImage = love.graphics.newImage("Sprites/Player/Walk_1.png")
    self.idleImage = love.graphics.newImage("Sprites/Player/Idle_1.png")
    self.punchImage = love.graphics.newImage("Sprites/Player/Punch.png")
    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    local singleG = anim8.newGrid(20, 32, self.punchImage:getWidth(), self.punchImage:getHeight())

    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.punch = anim8.newAnimation(singleG(1, 1), 0.5)

    self.moving = false
    self.punching = false
    
    
    self.scaleX = 1 
    
    
    self.walkOriginX = 8  
    self.punchOriginX = 10 
end

function Player:update(dt, world)
    self.moving = false
    self.punching = false

    self.animation:update(dt)

    local speed = self.speed
    local dx, dy = 0, 0

    if love.keyboard.isDown("z") then
        self.moving = false
        self.punching = true
    end

    if love.keyboard.isDown("left") and self.punching == false then
        dx = -speed * dt
        self.moving = true
        self.scaleX = -1 
    elseif love.keyboard.isDown("right") and self.punching == false then
        dx = speed * dt
        self.moving = true
        self.scaleX = 1 
    end

    if love.keyboard.isDown("up") and self.punching == false then
        dy = -speed * dt
        self.moving = true
    elseif love.keyboard.isDown("down") and self.punching == false then
        dy = speed * dt
        self.moving = true
    end

    if dx ~= 0 or dy ~= 0 then
        self.x, self.y = world:move(self, self.x + dx, self.y + dy)
    end
end

function Player:draw()
    local img = self.moving and self.walkingImage or self.punching and self.punchImage or self.idleImage
    local animation = self.punching and self.punch or self.animation
    
    
    local originX
    if self.punching then
        originX = self.punchOriginX
    else
        originX = self.walkOriginX
    end
    
    
    animation:draw(img, self.x, self.y, nil, self.scaleX, 1, originX, 16)
end

return Player