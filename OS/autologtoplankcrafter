-- Log naar Plank Converter voor Crafty Turtle

-- De Turtle Inventory slots 1 tot 16
local LOG_ITEM_NAME = "minecraft:oak_log" -- Vervang dit door het exacte ID van de logs die je gebruikt
local LOGS_PER_CRAFT = 1
local PLANK_OUTPUT_COUNT = 4

function craftLogsToPlanks()
    print("Start met het omzetten van logs naar planken...")
    
    -- Loop door alle 16 slots van de turtle
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        
        -- Controleer of het item in de slot een log is
        if item and (item.name == LOG_ITEM_NAME or string.find(item.name, "_log$")) then
            local logsInStack = item.count
            local craftsPossible = math.floor(logsInStack / LOGS_PER_CRAFT)
            
            if craftsPossible > 0 then
                -- Probeer te craften. Een log in de 3x3 grid geeft 4 planken.
                local success = turtle.craft(logsInStack)
                
                if success then
                    print(string.format("Succes: %d logs in slot %d omgezet naar %d planken.", 
                        logsInStack, i, logsInStack * PLANK_OUTPUT_COUNT))
                else
                    print(string.format("Fout: Kon de logs in slot %d niet omzetten. Misschien is de inventaris vol?", i))
                    -- Stop met craften als het niet lukt (meestal vol)
                    return 
                end
            end
        end
    end
    
    print("Klaar met omzetten.")
end

-- Voer de functie uit
craftLogsToPlanks()
