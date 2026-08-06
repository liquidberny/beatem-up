local Character = Object:extend()

Character.footprintWidth = 16
Character.footprintHeight = 10
Character.footprintOffsetX = 0
Character.footprintOffsetY = 22

function Character:new(x, y, speed)
    self.x = x
    self.y = y
    self.health = 100
    self.maxHealth = 100
    self.speed = speed or 100
    self.isCharacter = true
end

function Character:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
end

function Character:isDead()
    return self.health <= 0
end

function Character.movementFilter(item, other)
    if other.isCharacter then
        return nil
    end
    return "slide"
end

return Character
