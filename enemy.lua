local Character = require("character")
local anim8 = require "lib.anim8"
local Enemy = Character:extend()

function Enemy:new(x, y)
    Enemy.super.new(self, x, y, 50)
    self.walkingImage = love.graphics.newImage("Sprites/Enemy/Walk.png")
    self.idleImage = love.graphics.newImage("Sprites/Enemy/Idle.png")
    self.punchImage = love.graphics.newImage("Sprites/Enemy/Punch.png")
    self.hurtImage = love.graphics.newImage("Sprites/Enemy/Hurt.png")
    self.knockdownImage = love.graphics.newImage("Sprites/Enemy/Knockdown.png")

    local g = anim8.newGrid(16, 32, self.walkingImage:getWidth(), self.walkingImage:getHeight())
    local singleG = anim8.newGrid(20, 32, self.punchImage:getWidth(), self.punchImage:getHeight())

    self.animation = anim8.newAnimation(g('1-4', 1), 0.3)
    self.punch = anim8.newAnimation(singleG(1, 1), 1.0)

    self.moving = false
    self.punching = false
    self.scaleX = 1

    self.punchTimer = 0
    self.punchDuration = 0.5
    self.punchCooldown = 2.0
    self.cooldownTimer = 0
    self.punchRange = 20
    self.attackDamage = 10

    self.moveStyle = "direct"
    self.strafePhase = math.random() * 2 * math.pi
    self.jitterTimer = 0
    self.jitterAngle = 0

    self.hitstunDuration = 0.4
    self.hitstunTimer = 0
    self.lastHitTime = -math.huge

    self.dying = false
    self.deathDuration = 1.0
    self.deathTimer = 0
end

function Enemy:takeDamage(amount)
    Enemy.super.takeDamage(self, amount)
    self.hitstunTimer = self.hitstunDuration
    self.lastHitTime = love.timer.getTime()
    self.punching = false
    self.punchTimer = 0
end

function Enemy:startDying()
    self.dying = true
    self.deathTimer = self.deathDuration
end

function Enemy:isDeathAnimDone()
    return self.dying and self.deathTimer <= 0
end

function Enemy:update(dt, world, player)
    if self.dying then
        self.deathTimer = self.deathTimer - dt
        return
    end

    if self.hitstunTimer > 0 then
        self.hitstunTimer = math.max(0, self.hitstunTimer - dt)
        self.moving = false
        return
    end

    local px, py = player.x, player.y
    self.animation:update(dt)

    local dx = px - self.x
    local dy = py - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    self.scaleX = (px >= self.x) and 1 or -1

    if self.cooldownTimer > 0 then
        self.cooldownTimer = self.cooldownTimer - dt
    end

    if self.punching then
        self.punchTimer = self.punchTimer - dt
        if self.punchTimer <= 0 then
            self.punching = false
            self.punch:gotoFrame(1)
        end
        return
    end

    if distance < self.punchRange then
        self.moving = false
        if self.cooldownTimer <= 0 then
            self.punching = true
            self.punchTimer = self.punchDuration
            self.cooldownTimer = self.punchCooldown
            player:takeDamage(self.attackDamage)
        end
    else
        self.moving = true
        local angle = math.atan2(py - self.y, px - self.x)

        if self.moveStyle == "strafer" then
            self.strafePhase = self.strafePhase + dt * 3
            angle = angle + math.sin(self.strafePhase) * 0.6
        elseif self.moveStyle == "erratic" then
            self.jitterTimer = self.jitterTimer - dt
            if self.jitterTimer <= 0 then
                self.jitterTimer = 0.3 + math.random() * 0.4
                self.jitterAngle = (math.random() - 0.5) * 1.4
            end
            angle = angle + self.jitterAngle
        end

        local moveX = math.cos(angle) * self.speed * dt
        local moveY = math.sin(angle) * self.speed * dt
        local goalX = self.x + moveX + Character.footprintOffsetX
        local goalY = self.y + moveY + Character.footprintOffsetY
        local actualX, actualY = world:move(self, goalX, goalY, Character.movementFilter)
        self.x = actualX - Character.footprintOffsetX
        self.y = actualY - Character.footprintOffsetY
    end
end

function Enemy:draw()
    if self.dying then
        local originX = self.scaleX == 1 and 0 or self.knockdownImage:getWidth()
        love.graphics.draw(self.knockdownImage, self.x, self.y, 0, self.scaleX, 1, originX, 0)
        return
    end

    if self.hitstunTimer > 0 then
        local originX = self.scaleX == 1 and 0 or self.hurtImage:getWidth()
        love.graphics.draw(self.hurtImage, self.x, self.y, 0, self.scaleX, 1, originX, 0)
        return
    end

    local img = self.punching and self.punchImage or self.moving and self.walkingImage or self.idleImage
    local animation = self.punching and self.punch or self.animation
    local originX = self.scaleX == 1 and 0 or 16
    animation:draw(img, self.x, self.y, nil, self.scaleX, 1, originX, 0)
end

return Enemy
