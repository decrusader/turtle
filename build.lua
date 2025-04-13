-- build.lua

-- Parse args
local args = {...}
if #args < 3 then
    print("Gebruik: build <breedte> <lengte> <hoogte>")
    return
end

local width = tonumber(args[1])
local length = tonumber(args[2])
local height = tonumber(args[3])

if not width or not length or not height then
    print("Ongeldige getallen.")
    return
end

-- Helpers
local function log(msg)
    term.setCursorPos(1, 1)
    term.clearLine()
    print("Status: " .. msg)
end

local function autoRefuel()
    if turtle.getFuelLevel() < 10 then
        turtle.select(16)
        if not turtle.refuel(1) then
            print("⚠️ Geen brandstof in slot 16!")
            return false
        end
    end
    return true
end

-- Plaats blok onder turtle
local function placeBlock()
    turtle.select(1)
    if not turtle.detectDown() then
        turtle.placeDown()
    end
end

-- Ga 1 stap naar voren met refuel check
local function smartForward()
    autoRefuel()
    while not turtle.forward() do
        turtle.dig()
        sleep(0.2)
    end
end

-- Bouw 1 laag met zigzag patroon
local function buildLayer()
    for w = 1, width do
        for l = 1, length do
            placeBlock()
            if l < length then
                smartForward()
            end
        end

        -- Beweeg naar volgende rij
        if w < width then
            if w % 2 == 1 then
                turtle.turnRight()
                smartForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                smartForward()
                turtle.turnLeft()
            end
        end
    end
end

-- Keer terug naar beginpositie van de laag
local function resetToOrigin()
    if width % 2 == 1 then
        turtle.turnRight()
        for i = 1, width - 1 do
            smartForward()
        end
        turtle.turnRight()
    else
        turtle.turnLeft()
        turtle.turnLeft()
    end

    for i = 1, length - 1 do
        smartForward()
    end

    turtle.turnLeft()
    turtle.turnLeft()
end

-- Bouw het hele blok
for h = 1, height do
    log("Bouwen laag " .. h .. " / " .. height)
    buildLayer()
    if h < height then
        resetToOrigin()
        if not turtle.up() then
            turtle.digUp()
            turtle.up()
        end
    end
end

log("✅ Klaar!")
