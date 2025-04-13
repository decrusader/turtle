-- build.lua

-- Args
local args = {...}
if #args < 3 then
    print("Gebruik: build <breedte> <lengte> <hoogte>")
    return
end

local width = tonumber(args[1])
local length = tonumber(args[2])
local height = tonumber(args[3])

if not width or not length or not height then
    print("Ongeldige invoer.")
    return
end

-- Refuel
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

-- Bewegingsfuncties
local function smartForward()
    autoRefuel()
    while not turtle.forward() do
        turtle.dig()
        sleep(0.1)
    end
end

local function smartUp()
    autoRefuel()
    while not turtle.up() do
        turtle.digUp()
        sleep(0.1)
    end
end

local function smartDown()
    autoRefuel()
    while not turtle.down() do
        turtle.digDown()
        sleep(0.1)
    end
end

-- Blok plaatsen
local function placeBlock()
    turtle.select(1)
    if not turtle.detectDown() then
        turtle.placeDown()
    end
end

-- Bouw één laag in zigzag
local function buildLayer()
    for w = 1, width do
        for l = 1, length do
            placeBlock()
            if l < length then
                smartForward()
            end
        end
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

-- Keer terug naar het begin van de laag
local function returnToLayerStart()
    if width % 2 == 1 then
        turtle.turnRight()
        for i = 1, width - 1 do
            smartForward()
        end
        turtle.turnRight()
    else
        if length > 1 then
            turtle.turnLeft()
            turtle.turnLeft()
            for i = 1, length - 1 do
                smartForward()
            end
        end
    end
end

-- Bouw volledige kubus
for h = 1, height do
    term.setCursorPos(1,1)
    term.clearLine()
    print("Laag " .. h .. "/" .. height)

    buildLayer()
    returnToLayerStart()
    for i = 1, h do
        smartDown()
    end
    for i = 1, h do
        smartUp()
    end
end

-- Eindpositie terug op grond
for i = 1, height do
    smartDown()
end

print("✅ Kubus gebouwd & turtle terug op startpositie!")
