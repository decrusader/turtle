-- Log naar Plank Converter (Robuuste Versie)
-- Plaatst de turtle OP de kist waar de planken in moeten.
-- Plaatst de kist met logs BOVENOP de turtle.

local LOG_ITEM_NAME_PARTIAL = "_log"
local PLANK_ITEM_NAME_PARTIAL = "_planks"

--------------------------------------------------------------------------------
-- FUNCTIES
--------------------------------------------------------------------------------

-- Functie om logs uit de kist boven de turtle te halen
-- Houdt altijd het laatste slot (16) vrij voor het craften.
local function getLogs()
    local itemsPulled = false
    -- Blijf items zuigen zolang slot 16 leeg is en de actie slaagt
    while turtle.getItemCount(16) == 0 do
        if turtle.suckUp() then
            itemsPulled = true
        else
            -- Stop de lus als de kist boven leeg is
            break
        end
    end
    return itemsPulled
end

-- Functie om alle logs in de inventaris om te zetten naar planken
local function craftLogsToPlanks()
    local itemsCrafted = false
    -- Loop door de eerste 15 slots (slot 16 is onze werkruimte)
    for i = 1, 15 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer of het item een log is
        if item and string.find(item.name, LOG_ITEM_NAME_PARTIAL) then
            -- Craft de volledige stack in de geselecteerde slot
            if turtle.craft() then
                print("Logs omgezet naar planken in slot " .. i)
                itemsCrafted = true
            end
        end
    end
    return itemsCrafted
end

-- Functie om alle planken naar de kist eronder te verplaatsen
local function depositPlanks()
    local itemsDropped = false
    -- Loop door alle 16 slots
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer of het item planken zijn
        if item and string.find(item.name, PLANK_ITEM_NAME_PARTIAL) then
            -- Drop de volledige stack naar beneden
            if turtle.dropDown() then
                itemsDropped = true
            end
        end
    end
    if itemsDropped then
        print("Planken gedeponeerd in de kist.")
    end
    return itemsDropped
end

--------------------------------------------------------------------------------
-- HOOFDPROGRAMMA
--------------------------------------------------------------------------------

print("Log-naar-Plank programma gestart.")
print("Input: Boven | Output: Onder")

while true do
    -- Voer de stappen in volgorde uit
    local pulled = getLogs()
    local crafted = craftLogsToPlanks()
    local dropped = depositPlanks()

    -- Wachtmechanisme om server-lag te voorkomen
    if not pulled and not crafted and not dropped then
        -- Als er niets te doen was, wacht dan wat langer
        print("Wachten op nieuwe logs...")
        os.sleep(5)
    else
        -- Korte pauze na een succesvolle cyclus
        os.sleep(1)
    end
end
