-- Log naar Plank Converter (Automatisch: Input Boven, Output Onder)
-- Opgelost voor 'number expected' error en verbeterd om continu te draaien

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
    repeat
        -- Zuigt één itemstack naar de eerste lege slot of vult een bestaande logstack.
        -- We vangen 'count' op. Als 'success' false is, is 'count' meestal nil.
        success, count = turtle.suck(INPUT_SIDE)

        if success then
            -- Als het zuigen succesvol was, tellen we de hoeveelheid op.
            totalSucked = totalSucked + (count or 1) -- 'count' zou het aantal opgezogen items moeten zijn, maar default naar 1 voor de zekerheid.
        end
        
        -- Zorg ervoor dat we items met een specifieke naam zoeken voordat we doorgaan
        -- We stoppen de lus als 'success' false is (geen items meer, of probleem).
    until not success or totalSucked >= 64*16 -- Stop als suck faalt of als inventaris (theoretisch) vol is.

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
            local success, count = turtle.drop(OUTPUT_SIDE, item.count)
            
            if success then
                dumpedCount = dumpedCount + (count or item.count)
            end
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
    
    -- Wachtmechanisme
    if not logsPulled and not crafted and not planksDumped then
        print("Geen activiteit. 5 seconden wachten...")
        os.sleep(5) 
    else
        -- Korte pauze voor de volgende cyclus
        sleepShort()
    end
end
