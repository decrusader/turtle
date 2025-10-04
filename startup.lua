-- Log naar Plank Converter (Automatisch: Input Boven, Output Onder)
-- Opgelost voor 'suck' error en verbeterd om continu te draaien

local LOG_ITEM_NAME_PARTIAL = "_log"  -- Matcht alle item-ID's die eindigen op _log
local INPUT_SIDE = "up"              -- Inventaris om logs uit te halen (boven)
local OUTPUT_SIDE = "down"           -- Inventaris om planken in te plaatsen (onder)

-- Functie om de turtle te laten wachten, nuttig in een oneindige lus
local function sleepShort()
    os.sleep(0.5)
end

-- Functie om logs uit de inputkist te halen
local function suckLogs()
    local totalSucked = 0
    local success, count

    -- Zuig continu totdat er geen logs meer zijn of de inventaris vol is.
    -- turtle.suck("up") trekt één stack van één item. We moeten het herhalen.
    repeat
        -- Zuigt één itemstack naar de eerste lege slot (of vult een bestaande logstack)
        success, count = turtle.suck(INPUT_SIDE)
        if success and count > 0 then
            totalSucked = totalSucked + count
        end
    until not success or totalSucked >= 64*16 -- Stop als suck faalt of als inventaris vol is (max 16 stacks * 64 items)

    if totalSucked > 0 then
        print(string.format("Logs binnengehaald: %d stuks.", totalSucked))
        return true
    else
        return false
    end
end

-- Functie om de logs om te zetten naar planken
local function craftAllLogs()
    local crafted = false
    
    -- Loop door alle 16 slots om te kijken of er logs zijn om te craften
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer op logs
        if item and string.find(item.name, LOG_ITEM_NAME_PARTIAL .. "$") then
            local logsToCraft = item.count
            
            -- Probeer alle logs in de geselecteerde stack te craften
            local success = turtle.craft(logsToCraft)
            
            if success then
                print(string.format("Gecraft: %d logs omgezet naar planken.", logsToCraft))
                crafted = true
            end
            -- Zelfs als het craften faalt (volle inventaris), gaan we door om de output te dumpen
        end
    end
    
    return crafted
end

-- Functie om planken naar de outputkist te sturen
local function dumpPlanks()
    local dumpedCount = 0
    
    -- Loop door alle slots van de turtle (1 tot 16)
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer op planken (alle item-ID's die eindigen op _planks)
        if item and string.find(item.name, "_planks$") then
            
            -- Stuur de planken naar de output inventaris (onder)
            -- turtle.drop probeert de hele stack te droppen
            local success, count = turtle.drop(OUTPUT_SIDE, item.count)
            
            if success then
                dumpedCount = dumpedCount + count
            end
            -- We gaan door met de volgende slot, zelfs na een succesvolle drop.
        end
    end
    
    if dumpedCount > 0 then
        print(string.format("Planken gedumpt: %d stuks naar onder.", dumpedCount))
    end
    
    return dumpedCount > 0
end

-- HOOFD PROGRAMMA LUS
while true do
    -- 1. Logs binnentrekken
    local logsPulled = suckLogs()
    
    -- 2. Alles craften
    local crafted = craftAllLogs()
    
    -- 3. Planken dumpen
    local planksDumped = dumpPlanks()
    
    -- Wachtmechanisme: Als er niets is gedaan (geen logs, geen planken gedumpt), wacht langer.
    if not logsPulled and not crafted and not planksDumped then
        print("Geen logs gevonden, 5 seconden wachten...")
        os.sleep(5) 
    else
        -- Korte pauze voor de volgende cyclus om de serverbelasting te verminderen
        sleepShort()
    end
end
