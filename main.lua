local p1
local e1
local bump = require("lib.bump")
local world = bump.newWorld()

function love.load()
    Object = require("lib.classic")
    local Character = require("character")
    local Player = require("player")
    local Enemy = require("enemy")
    sti = require("lib/sti")
    gameMap = sti("Maps/Street.lua")
    p1 = Player(100, 200)
    e1 = Enemy(200, 200, 50)
    camera = require("lib.camera")
    cam = camera(p1.x, p1.y, 3)

    world:add(p1, p1.x + Character.footprintOffsetX, p1.y + Character.footprintOffsetY,
        Character.footprintWidth, Character.footprintHeight)
    world:add(e1, e1.x + Character.footprintOffsetX, e1.y + Character.footprintOffsetY,
        Character.footprintWidth, Character.footprintHeight)

    if gameMap.layers["Walls"] then
        for _, wall in ipairs(gameMap.layers["Walls"].objects) do
            world:add(wall, wall.x, wall.y, wall.width, wall.height)
        end
    end

    gameState = "menu"
end

function love.update(dt)
    if gameState ~= "playing" then
        return
    end

    local dx, dy = p1.x - cam.x, p1.y - cam.y
    cam:move(dx / 2, dy / 2)

    p1:update(dt, world)
    e1:update(dt, world, p1)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    local halfViewW = w / (2 * cam.scale)
    local halfViewH = h / (2 * cam.scale)

    if cam.x < halfViewW then
        cam.x = halfViewW
    end

    if cam.x > mapW - halfViewW then
        cam.x = mapW - halfViewW
    end

    if cam.y < halfViewH then
        cam.y = halfViewH
    end

    if cam.y > mapH - halfViewH then
        cam.y = mapH - halfViewH
    end

end

function drawHUD()
    local barWidth = 100
    local barHeight = 10
    local margin = 10

    local p1BarX = margin
    local p1BarY = love.graphics.getHeight() - margin - barHeight
    local p1Pct = math.max(0, p1.health / p1.maxHealth)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", p1BarX, p1BarY, barWidth, barHeight)
    love.graphics.setColor(0.1, 0.8, 0.1)
    love.graphics.rectangle("fill", p1BarX, p1BarY, barWidth * p1Pct, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", p1BarX, p1BarY, barWidth, barHeight)
    love.graphics.print("P1  " .. p1.health .. "/" .. p1.maxHealth, p1BarX, p1BarY - 14)

    local e1BarX = love.graphics.getWidth() - margin - barWidth
    local e1BarY = love.graphics.getHeight() - margin - barHeight
    local e1Pct = math.max(0, e1.health / e1.maxHealth)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", e1BarX, e1BarY, barWidth, barHeight)
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", e1BarX, e1BarY, barWidth * e1Pct, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", e1BarX, e1BarY, barWidth, barHeight)
    love.graphics.print("E1  " .. e1.health .. "/" .. e1.maxHealth, e1BarX, e1BarY - 14)

    love.graphics.setColor(1, 1, 1)
end

function drawMenu()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("BEAT 'EM UP", 0, h / 4, w, "center")
    love.graphics.printf("Presiona ENTER para iniciar", 0, h / 4 + 30, w, "center")

    love.graphics.printf("Controles", 0, h / 2 + 20, w, "center")
    love.graphics.printf("Flechas: moverse", 0, h / 2 + 45, w, "center")
    love.graphics.printf("Z: golpear", 0, h / 2 + 65, w, "center")
    love.graphics.printf("D: alternar hitboxes de debug", 0, h / 2 + 85, w, "center")
end

function love.draw()
    if gameState ~= "playing" then
        drawMenu()
        return
    end

    cam:attach()
    gameMap:drawLayer(gameMap.layers["Background"])
    p1:draw()
    e1:draw()

    if debugMode then
        love.graphics.setColor(0, 1, 0, 0.5)
        local px, py, pw, ph = world:getRect(p1)
        love.graphics.rectangle("line", px, py, pw, ph)

        love.graphics.setColor(1, 0, 0, 0.5)
        local ex, ey, ew, eh = world:getRect(e1)
        love.graphics.rectangle("line", ex, ey, ew, eh)

        love.graphics.setColor(1, 1, 0, 0.5)
        if gameMap.layers["Walls"] then
            for _, wall in ipairs(gameMap.layers["Walls"].objects) do
                love.graphics.rectangle("line", wall.x, wall.y, wall.width, wall.height)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
    cam:detach()

    drawHUD()
end

function love.keypressed(key)
    if gameState ~= "playing" then
        if key == "return" or key == "space" then
            gameState = "playing"
        end
        return
    end

    if key == "d" then
        debugMode = not debugMode
    end

    if key == "z" then

        if not p1.punching then
            local punchRange = 24
            local punchReach = 20

            local dx = e1.x - p1.x
            local dy = e1.y - p1.y

            local correctDirection = (p1.scaleX == 1 and dx > 0) or (p1.scaleX == -1 and dx < 0)

            local distance = math.sqrt(dx * dx + dy * dy)

            if correctDirection and distance < punchRange + punchReach then
                e1:takeDamage(p1.attackDamage or 15)
            end
        end
    end
end
