-- build3d.lua

-- UI
local function printHeader()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== AutoBuilder 3D ===")
end

-- Refuel functie
local function autoRefuel()
    if turtle.getFuelLevel() < 50 then
        print("Bijvullen...")
        turtle.select(16)
        if not turtle.refuel(1) then
            print("Geen brandstof gevonden in slot 16!")
            return false
        end
    end
    return true
end

-- Vraag gebruiker om input
printHeader()
write("Lengte: ")
local length = tonumber(read())

write("Breedte: ")
local width = tonumber(read())

write("Hoogte: ")
local height = tonumber(read())

-- Controle input
if not length or not width or not height then
    print("Ongeldige invoer.")
    return
end

print("Start met bouwen...")

-- Functie om een laag te bouwen
local function buildLayer()
    for w = 1, width do
        for l = 1, length do
            autoRefuel()
            turtle.select(1)
            if turtle.detectDown() == false then
                turtle.placeDown()
            end
            if l < length then
                turtle.forward()
            end
        end
        -- Draai aan einde van rij
        if w < width then
            if w % 2 == 1 then
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        end
    end
end

-- Keer terug naar begin van laag
local function returnToStart()
    if width % 2 == 1 then
        turtle.turnRight()
        for i = 1, width - 1 do
            turtle.forward()
        end
        turtle.turnRight()
    else
        if length > 1 then
            turtle.turnLeft()
            turtle.turnLeft()
            for i = 1, length - 1 do
                turtle.forward()
            end
        end
    end
end

-- Bouw alle lagen
for h = 1, height do
    printHeader()
    print("Bouwen laag " .. h .. " van " .. height)
    buildLayer()
    if h < height then
        returnToStart()
        turtle.up()
    end
end

printHeader()
print("✅ Voltooid!")

