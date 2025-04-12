-- Geoptimaliseerd Turtle Mining programma van Decrusader v1.0
 
-- Invoer
local tArgs = { ... }
if #tArgs < 4 then
    print("Gebruik: mine <lengte> <breedte> <hoogte> <ja/nee (fakkels)>")
    return
end
 
local lengte = tonumber(tArgs[1])
local breedte = tonumber(tArgs[2])
local hoogte = tonumber(tArgs[3])
local torches = tArgs[4]:lower() == "ja"
 
if not lengte or not breedte or not hoogte then
    print("Ongeldige invoer. Zorg dat lengte, breedte en hoogte getallen zijn.")
    return
end
 
-- UI
local VERSION = "v1.0"
local totalBlocks = lengte * breedte
local minedBlocks = 0
 
function updateUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Turtle Mining " .. VERSION .. " - door Decrusader")
    print("Fuel: " .. turtle.getFuelLevel())
    print(string.format("Progress: %d / %d", minedBlocks, totalBlocks))
end
 
-- Refuel check
function refuelIfNeeded()
    while turtle.getFuelLevel() < 10 do
        updateUI()
        print("Laag brandstofniveau! Voeg brandstof toe...")
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(0) then
                turtle.refuel()
                print("Bijgetankt!")
                return
            end
        end
        sleep(2)
    end
end
 
-- Lava/Water detectie
function isDangerBlock(block)
    return block.name and (block.name:find("lava") or block.name:find("water"))
end
 
-- Direct stoppen bij lava
function checkForLava()
    local checks = {
        { turtle.inspect, "voor" },
        { turtle.inspectUp, "boven" },
        { turtle.inspectDown, "onder" }
    }
 
    for _, check in ipairs(checks) do
        local inspectFn, richting = check[1], check[2]
        local success, data = inspectFn()
        if success and isDangerBlock(data) then
            updateUI()
            print("‼️ Lava gedetecteerd " .. richting .. "! Mining gestopt.")
            error("Lava gevonden, veiligheid geactiveerd.")
        end
    end
end
 
-- Dig functies
function dig()
    while turtle.detect() do
        local success, data = turtle.inspect()
        if success and not isDangerBlock(data) then
            turtle.dig()
            sleep(0.1)
        else
            break
        end
    end
end
 
function digUp()
    while turtle.detectUp() do
        local success, data = turtle.inspectUp()
        if success and not isDangerBlock(data) then
            turtle.digUp()
            sleep(0.1)
        else
            break
        end
    end
end
 
function digDown()
    while turtle.detectDown() do
        local success, data = turtle.inspectDown()
        if success and not isDangerBlock(data) then
            turtle.digDown()
            sleep(0.1)
        else
            break
        end
    end
end
 
-- Veilig bewegen
function moveSafe(moveFn)
    refuelIfNeeded()
    local tries = 0
    while not moveFn() do
        dig()
        sleep(0.1)
        tries = tries + 1
        if tries > 5 then
            print("Kan niet bewegen, mogelijk geblokkeerd")
            return false
        end
    end
    return true
end
 
-- Fakkel functie
function placeTorch()
    for i = 1, 16 do
        turtle.select(i)
        local detail = turtle.getItemDetail()
        if detail and detail.name:find("torch") then
            turtle.placeDown()
            break
        end
    end
end
 
-- mijnpatroon
function mineOptimized()
    local turnRight = true
 
    for w = 1, breedte do
        for l = 1, lengte do
            checkForLava()
 
            -- Mine kolom omhoog
            for h = 1, hoogte - 1 do
                digUp()
                moveSafe(turtle.up)
            end
 
            -- Mine kolom omlaag
            for h = 1, hoogte - 1 do
                digDown()
                moveSafe(turtle.down)
            end
 
            minedBlocks = minedBlocks + 1
            updateUI()
 
            if torches and minedBlocks % 6 == 0 then
                turtle.turnLeft()
                turtle.turnLeft()
                placeTorch()
                turtle.turnLeft()
                turtle.turnLeft()
            end
 
            -- Volgende blok in rij
            if l < lengte then
                dig()
                moveSafe(turtle.forward)
            end
        end
 
        -- Volgende rij
        if w < breedte then
            if turnRight then
                turtle.turnRight()
                dig()
                moveSafe(turtle.forward)
                turtle.turnRight()
            else
                turtle.turnLeft()
                dig()
                moveSafe(turtle.forward)
                turtle.turnLeft()
            end
            turnRight = not turnRight
        end
    end
end
 
-- Starten
term.clear()
term.setCursorPos(1,1)
print("Start met minen...")
refuelIfNeeded()
updateUI()
mineOptimized()
updateUI()
print("Mining voltooid!")
 
