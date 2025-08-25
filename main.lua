local p1
local bump = require("lib.bump")
local world = bump.newWorld()


local function drawBlocks()
    for _, block in ipairs(blocks) do
        drawBox(block, 1, 0, 0)
    end
end

function love.load()
    Object = require("lib.classic")
    local Player = require("player")
    sti = require("lib/sti")
    gameMap = sti("Maps/Street.lua")
    p1 = Player(100, 200)
    camera = require("lib.camera")
    cam = camera(p1.x, p1.y, 2)

    world:add(p1, p1.x, p1.y, 16, 32)

    if gameMap.layers["Walls"] then
        for _, wall in ipairs(gameMap.layers["Walls"].objects) do
            world:add(wall, wall.x, wall.y, wall.width, wall.height)
        end
    end
    addBlock(200, 250, 16, 32)
end

function love.update(dt)
    local dx, dy = p1.x - cam.x, p1.y - cam.y
    cam:move(dx / 2, dy / 2)

    p1:update(dt, world)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x < w / 4 then
        cam.x = w / 4
    end

    if cam.x > mapW - w / 4 then
        cam.x = mapW - w / 4
    end

    if cam.y < h / 4 then
        cam.y = h / 4
    end

    if cam.y > mapH - h / 4 then
        cam.y = mapH - h / 4
    end

end

function love.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["Background"])
    p1:draw()
    
    drawBlocks()
    cam:detach()
end
