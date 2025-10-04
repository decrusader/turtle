-- Log naar Plank Converter (Automatisch: Input Boven, Output Onder)
-- Versie met robuustere log-herkenning en inventarisbeheer.

local LOG_ITEM_NAME_PARTIAL = "_log"  -- Matcht alle item-ID's die '_log' bevatten

-- Functie om de turtle te laten wachten
local function sleepShort()
    os.sleep(0.5)
end

-- Functie om logs uit de inputkist te halen (zorgt dat slot 16 leeg blijft)
local function suckLogs()
    local totalSucked = 0
    local success, count

    -- Ga door met zuigen zolang er ruimte is en de actie slaagt.
    -- Stopt wanneer het laatste slot (16) een item bevat.
    while turtle.getItemCount(16) == 0 do
        success, count = turtle.suckUp()

        if success then
            if type(count) == "number" then
                totalSucked = totalSucked + count
            else
                totalSucked = totalSucked + 1 
            end
        else
            -- Stop de lus als er niets meer te zuigen valt
            break
        end
    end

    if totalSucked > 0 then
        print(string.format("Logs binnengehaald: %d stuks.", totalSucked))
        return true
    else
        return false
    end
end

-- Functie om de logs om te zetten naar planken (minder strikte naamcontrole)
local function craftAllLogs()
    local crafted = false
    
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleert of '_log' in de itemnaam voorkomt
        if item and string.find(item.name, LOG_ITEM_NAME_PARTIAL) then
            local logsToCraft = item.count
            
            -- Craft de geselecteerde stack (meest betrouwbare methode)
            if turtle.craft() then
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
    
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer op planken
        if item and string.find(item.name, "_planks") then
            local success, count = turtle.dropDown(item.count)
            
            if success and type(count) == "number" then
                dumpedCount = dumpedCount + count
            elseif success then
                dumpedCount = dumpedCount + item.count
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
        sleepShort()
    end
end
