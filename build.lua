-- build.lua

-- Args
local args = {...}
if #args < 3 then
    print("Gebruik: build <breedte> <lengte> <hoogte>")
    return
end

width = tonumber(args[1])
length = tonumber(args[2])
height = tonumber(args[3])

if not width or not length or not height then
    print("Ongeldige invoer.")
    return
end

-- Refuel
local function autoRefuel()
    if turtle.getFuelLevel() < 10 then
        turtle.select(16)
        if not turtle.refuel(1) then
            print(" Geen brandstof in slot 16!")
            return false
        end
    end
    return true
end

local function selectSlot()
    for i = 1, 16 do
        local items = turtle.getItemCount(i)
        if items ~= 0 then
            turtle.select(i)
            break
        end
    end
end

-- Blok plaatsen
local function placeBlock()
    autoRefuel()
    selectSlot()
    if not turtle.detectDown() then
        turtle.placeDown()
    end
end

local function lengteVoor()
    for i = 2, length do
        turtle.forward()
        placeBlock()
    end
end
local function lengteAchter()
    for i = 2, length do
        turtle.back()
        placeBlock()
    end
end
local function layer()
    autoRefuel()
    turtle.up()
    placeBlock()
    for j = 1, width do
        if j % 2 == 0 then
            lengteAchter()
            turtle.turnRight()
            turtle.forward()
            placeBlock()
            turtle.turnLeft()
        else
            lengteVoor()
            turtle.turnRight()
            turtle.forward()
            placeBlock()
            turtle.turnLeft()
        end
    end
    turtle.turnLeft()
    for k = 1, width do
        turtle.forward()
    end
    turtle.turnRight()
    if width % 2 ~= 0 then
        for l = 1, length - 1 do
            turtle.back()
        end
    end
    
end

for i = 1, height do
    layer()
    turtle.up()
    placeBlock()
end
    
