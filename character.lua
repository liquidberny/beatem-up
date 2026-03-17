local Character = Object:extend()

function Character:new(x, y, speed)
    self.x = x
    self.y = y
    self.health = 100
    self.maxHealth = 100
    self.speed = speed or 100
end

function Character:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
end

function Character:isDead()
    return self.health <= 0
end

return Character