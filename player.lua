local Character = require("character")

local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)

    
    self.walkingImage = love.graphics.newImage("Sprites/Walk_1.png")
    self.walkingAnimation = {}
    for i = 0, 4 do 
        table.insert(self.walkingAnimation,
            love.graphics.newQuad(i * 16, 0, 16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
        )
    end

    
    self.idleImage = love.graphics.newImage("Sprites/Idle_1.png")
    self.idleAnimation = {}
    for i = 0, 4 do 
        table.insert(self.idleAnimation,
            love.graphics.newQuad(i * 16, 0, 16, 32, self.idleImage:getWidth(), self.idleImage:getHeight())
        )
    end

    self.currentFrame = 1
    self.moving = false
    self.lastState = "idle" 
end

function Player:update(dt)
    self.moving = false

    
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.moving = true
    end
    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.moving = true
    end
    if love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.moving = true
    end
    if love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.moving = true
    end

    
    local currentState = self.moving and "walk" or "idle"
    if currentState ~= self.lastState then
        self.currentFrame = 1
        self.lastState = currentState
    end

    
    local animFrames = self.moving and self.walkingAnimation or self.idleAnimation
    self.currentFrame = self.currentFrame + 5 * dt
    if self.currentFrame > #animFrames then
        self.currentFrame = 1
    end
end

function Player:draw()
    local anim = self.moving and self.walkingAnimation or self.idleAnimation
    local img = self.moving and self.walkingImage or self.idleImage
    love.graphics.draw(
        img,
        anim[math.floor(self.currentFrame)],
        self.x, self.y,
        0, 3, 3
    )
end

return Player
