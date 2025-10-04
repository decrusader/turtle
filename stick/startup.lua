-- Plank naar Stokjes Converter (Automatisch)
-- Input: Kist voor de turtle
-- Output: Kist achter de turtle

--[[ INSTRUCTIES:
1. Plaats een kist met planken VOOR de turtle.
2. Plaats een lege kist ACHTER de turtle.
3. Geef de turtle brandstof en start dit script.
]]

-- Configuratie van itemnamen
local PLANK_ITEM_NAME_PARTIAL = "_planks"
local STICK_ITEM_NAME = "stick" -- De meeste modpacks gebruiken 'stick' in de naam

--------------------------------------------------------------------------------
-- FUNCTIES
--------------------------------------------------------------------------------

-- Functie om planken uit de kist VOOR de turtle te halen.
-- Houdt altijd het laatste slot (16) vrij voor het craften.
local function getPlanks()
    local itemsPulled = false
    -- Blijf items zuigen zolang slot 16 leeg is en de actie slaagt
    while turtle.getItemCount(16) == 0 do
        if turtle.suck() then -- Zuigt van voren
            itemsPulled = true
        else
            -- Stop de lus als de kist voor leeg is
            break
        end
    end
    return itemsPulled
end

-- Functie om alle planken om te zetten naar stokjes.
local function craftPlanksToSticks()
    local itemsCrafted = false
    -- Loop door de eerste 15 slots om planken te vinden
    for i = 1, 15 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer of het item een plank is
        if item and string.find(item.name, PLANK_ITEM_NAME_PARTIAL) then
            -- Craft de volledige stack. 
            -- De turtle kent het recept (2 planken -> 4 stokjes)
            -- Als er meer dan 64 stokjes worden gemaakt, wordt een volgend leeg slot gebruikt.
            if turtle.craft() then
                print("Planken in slot " .. i .. " omgezet naar stokjes.")
                itemsCrafted = true
            end
        end
    end
    return itemsCrafted
end

-- Functie om alle stokjes in de kist ACHTER de turtle te plaatsen.
local function depositSticks()
    local itemsDropped = false
    
    -- Draai om naar de kist achter de turtle
    turtle.turnRight()
    turtle.turnRight()

    -- Loop door alle 16 slots om stokjes te vinden
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer of het item een stokje is
        if item and string.find(item.name, STICK_ITEM_NAME) then
            -- Drop de volledige stack in de kist (nu voor de turtle)
            if turtle.drop() then
                itemsDropped = true
            end
        end
    end
    
    -- Draai terug naar de beginpositie
    turtle.turnRight()
    turtle.turnRight()
    
    if itemsDropped then
        print("Stokjes gedeponeerd in de achterste kist.")
    end
    return itemsDropped
end

--------------------------------------------------------------------------------
-- HOOFDPROGRAMMA
--------------------------------------------------------------------------------

print("Plank-naar-Stokje programma gestart.")
print("Input: Voor | Output: Achter")

while true do
    -- Voer alle stappen in een logische volgorde uit
    local pulled = getPlanks()
    local crafted = craftPlanksToSticks()
    local dropped = depositSticks()

    -- Wachtmechanisme om server-lag te voorkomen
    if not pulled and not crafted and not dropped then
        -- Als er een hele cyclus niets is gebeurd, wacht dan wat langer
        print("Wachten op nieuwe planken...")
        os.sleep(5)
    else
        -- Korte pauze na een succesvolle actie
        os.sleep(1)
    end
end
