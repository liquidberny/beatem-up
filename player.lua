local Character = require("character")
local anim8 = require "lib.anim8"
local Player = Character:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.walkingImage = love.graphics.newImage("Sprites/Player/Walk_1.png")
    self.idleImage = love.graphics.newImage("Sprites/Player/Idle_1.png")
    self.punchImage = love.graphics.newImage("Sprites/Player/Punch.png")
    self.hurtImage = love.graphics.newImage("Sprites/Player/Hurt.png")
    self.knockOutImage = love.graphics.newImage("Sprites/Player/Down_Death.png")

    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    local singleG = anim8.newGrid(20, 32, self.punchImage:getWidth(), self.punchImage:getHeight())

    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.punch = anim8.newAnimation(singleG(1, 1), 0.5)

    self.attackDamage = 15
    self.moving = false
    self.punching = false
    self.scaleX = 1
    self.walkOriginX = 0
    self.punchOriginX = 10

    self.punchTimer = 0
    self.punchDuration = 0

    self.hurtTimer = 0
    self.hurtDuration = 0.2

    self.knockedOut = false
    self.knockoutDuration = 1.0
    self.knockoutTimer = 0
end

function Player:takeDamage(amount)
    Player.super.takeDamage(self, amount)
    self.hurtTimer = self.hurtDuration
end

function Player:startKnockout()
    self.knockedOut = true
    self.knockoutTimer = self.knockoutDuration
end

function Player:isKnockoutAnimDone()
    return self.knockedOut and self.knockoutTimer <= 0
end

function Player:update(dt, world)
    if self.hurtTimer > 0 then
        self.hurtTimer = self.hurtTimer - dt
    end

    if self.knockedOut then
        self.knockoutTimer = self.knockoutTimer - dt
        return
    end

    self.animation:update(dt)

    if self.punching then
        self.punchTimer = self.punchTimer - dt
        if self.punchTimer <= 0 then
            self.punching = false
            self.punch:gotoFrame(1)
        end
        return
    end

    self.moving = false

    if love.keyboard.isDown("z") then
        self.punching = true
        self.punchTimer = self.punchDuration
        return
    end

    local speed = self.speed
    local dx, dy = 0, 0

    if love.keyboard.isDown("left") then
        dx = -speed * dt
        self.moving = true
        self.scaleX = -1
    elseif love.keyboard.isDown("right") then
        dx = speed * dt
        self.moving = true
        self.scaleX = 1
    end

    if love.keyboard.isDown("up") then
        dy = -speed * dt
        self.moving = true
    elseif love.keyboard.isDown("down") then
        dy = speed * dt
        self.moving = true
    end

    if dx ~= 0 or dy ~= 0 then
        local goalX = self.x + dx + Character.footprintOffsetX
        local goalY = self.y + dy + Character.footprintOffsetY
        local actualX, actualY = world:move(self, goalX, goalY, Character.movementFilter)
        self.x = actualX - Character.footprintOffsetX
        self.y = actualY - Character.footprintOffsetY
    end
end

function Player:draw()
    if self.knockedOut then
        local originX = self.scaleX == 1 and 0 or self.knockOutImage:getWidth()
        love.graphics.draw(self.knockOutImage, self.x, self.y, 0, self.scaleX, 1, originX, 0)
        return
    end

    if self.hurtTimer > 0 then
        local originX = self.scaleX == 1 and 0 or self.hurtImage:getWidth()
        love.graphics.draw(self.hurtImage, self.x, self.y, 0, self.scaleX, 1, originX, 0)
        return
    end

    local img = self.punching and self.punchImage or self.moving and self.walkingImage or self.idleImage
    local animation = self.punching and self.punch or self.animation
    local originX = self.scaleX == 1 and 0 or 16
    animation:draw(img, self.x, self.y, nil, self.scaleX, 1, originX, 0)
end

return Player
