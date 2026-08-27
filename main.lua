local bump = require("lib.bump")
local camera = require("lib.camera")

local world
local p1
local enemies = {}
local Character, Player, Enemy

local spawnPoints = {
    { 150, 210 },
    { 350, 210 },
    { 250, 270 },
    { 100, 280 },
}

local moveStyles = { "direct", "strafer", "erratic" }
local moveStyleIndex = 0

local function spawnEnemy()
    local pt = spawnPoints[math.random(#spawnPoints)]
    local e = Enemy(pt[1], pt[2])
    moveStyleIndex = moveStyleIndex % #moveStyles + 1
    e.moveStyle = moveStyles[moveStyleIndex]
    world:add(e, e.x + Character.footprintOffsetX, e.y + Character.footprintOffsetY,
        Character.footprintWidth, Character.footprintHeight)
    table.insert(enemies, e)
end

local function initGame()
    world = bump.newWorld()
    p1 = Player(100, 200)
    enemies = {}

    world:add(p1, p1.x + Character.footprintOffsetX, p1.y + Character.footprintOffsetY,
        Character.footprintWidth, Character.footprintHeight)

    for _ = 1, 3 do
        spawnEnemy()
    end

    if gameMap.layers["Walls"] then
        for _, wall in ipairs(gameMap.layers["Walls"].objects) do
            world:add(wall, wall.x, wall.y, wall.width, wall.height)
        end
    end

    cam.x, cam.y = p1.x, p1.y
end

function love.load()
    math.randomseed(os.time())

    Object = require("lib.classic")
    Character = require("character")
    Player = require("player")
    Enemy = require("enemy")
    sti = require("lib/sti")
    gameMap = sti("Maps/Street.lua")
    cam = camera(100, 200, 3)

    initGame()

    gameState = "menu"
end

function love.update(dt)
    if gameState ~= "playing" then
        return
    end

    local dx, dy = p1.x - cam.x, p1.y - cam.y
    cam:move(dx / 2, dy / 2)

    p1:update(dt, world)
    for _, e in ipairs(enemies) do
        e:update(dt, world, p1)
    end

    for _, e in ipairs(enemies) do
        if e:isDead() and not e.dying then
            world:remove(e)
            e:startDying()
        end
    end

    for i = #enemies, 1, -1 do
        if enemies[i]:isDeathAnimDone() then
            table.remove(enemies, i)
            spawnEnemy()
        end
    end

    if p1:isDead() and not p1.knockedOut then
        p1:startKnockout()
    end

    if p1:isKnockoutAnimDone() then
        gameState = "gameover"
    end

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

    local now = love.timer.getTime()
    local visibleEnemies = {}
    for _, e in ipairs(enemies) do
        if not e.dying and now - e.lastHitTime < 1.0 then
            table.insert(visibleEnemies, e)
        end
    end

    local rowHeight = barHeight + 20
    for i, e in ipairs(visibleEnemies) do
        local eBarX = love.graphics.getWidth() - margin - barWidth
        local eBarY = love.graphics.getHeight() - margin - barHeight - (i - 1) * rowHeight
        local ePct = math.max(0, e.health / e.maxHealth)

        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", eBarX, eBarY, barWidth, barHeight)
        love.graphics.setColor(0.8, 0.1, 0.1)
        love.graphics.rectangle("fill", eBarX, eBarY, barWidth * ePct, barHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", eBarX, eBarY, barWidth, barHeight)
        love.graphics.print("E" .. i .. "  " .. e.health .. "/" .. e.maxHealth, eBarX, eBarY - 14)
    end

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

function drawGameOver()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER", 0, h / 2 - 20, w, "center")
    love.graphics.printf("Presiona ENTER para reiniciar", 0, h / 2 + 10, w, "center")
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
        return
    end

    if gameState == "gameover" then
        drawGameOver()
        return
    end

    cam:attach()
    gameMap:drawLayer(gameMap.layers["Background"])
    p1:draw()
    for _, e in ipairs(enemies) do
        e:draw()
    end

    if debugMode then
        love.graphics.setColor(0, 1, 0, 0.5)
        local px, py, pw, ph = world:getRect(p1)
        love.graphics.rectangle("line", px, py, pw, ph)

        love.graphics.setColor(1, 0, 0, 0.5)
        for _, e in ipairs(enemies) do
            if not e.dying then
                local ex, ey, ew, eh = world:getRect(e)
                love.graphics.rectangle("line", ex, ey, ew, eh)
            end
        end

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
    if gameState == "menu" then
        if key == "return" or key == "space" then
            gameState = "playing"
        end
        return
    end

    if gameState == "gameover" then
        if key == "return" or key == "space" then
            initGame()
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

            for _, e in ipairs(enemies) do
                if not e.dying then
                    local dx = e.x - p1.x
                    local dy = e.y - p1.y

                    local correctDirection = (p1.scaleX == 1 and dx > 0) or (p1.scaleX == -1 and dx < 0)

                    local distance = math.sqrt(dx * dx + dy * dy)

                    if correctDirection and distance < punchRange + punchReach then
                        e:takeDamage(p1.attackDamage or 15)
                        break
                    end
                end
            end
        end
    end
end
