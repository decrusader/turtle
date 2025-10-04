-- Log naar Plank Converter (Automatisch: Input Boven, Output Onder)
-- Opgelost voor 'number expected' error door striktere controle op turtle.suck() output
-- en correcte directionele functies (suckUp/dropDown).

local LOG_ITEM_NAME_PARTIAL = "_log"  -- Matcht alle item-ID's die eindigen op _log
local OUTPUT_SIDE = "down"            -- Variabele behouden voor duidelijkheid, maar niet meer direct gebruikt in de drop-functie

-- Functie om de turtle te laten wachten, nuttig in een oneindige lus
local function sleepShort()
    os.sleep(0.5)
end

-- Functie om logs uit de inputkist te halen
local function suckLogs()
    local totalSucked = 0
    local success, count

    -- De lus gaat door zolang turtle.suckUp() succesvol is.
    repeat
        -- turtle.suckUp() retourneert (boolean succes, number/string/nil count).
        -- We vangen beide op.
        success, count = turtle.suckUp() -- *** CORRECTIE 1 ***

        if success then
            -- Als het zuigen succesvol was, MOET count een getal zijn (hoeveelheid items).
            -- We gebruiken 'type(count) == "number"' voor maximale veiligheid.
            if type(count) == "number" then
                totalSucked = totalSucked + count
            else
                -- Dit zou niet mogen gebeuren na 'success == true', maar voor de zekerheid:
                totalSucked = totalSucked + 1 
            end
        end
        
        -- Stop de lus wanneer success onwaar is.
        -- Dit betekent dat er niets meer in de inventaris zit of dat deze vol is.
    until not success or totalSucked >= 64*16

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
            local success, count = turtle.dropDown(item.count) -- *** CORRECTIE 2 ***
            
            if success and type(count) == "number" then
                dumpedCount = dumpedCount + count
            elseif success then
                -- Als 'count' geen nummer is, neem aan dat de hele stack is gedropt
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
        -- Korte pauze voor de volgende cyclus
        sleepShort()
    end
end
