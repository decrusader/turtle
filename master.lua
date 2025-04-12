-- Master Computer Script
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de modem voor communicatie

local activeTurtles = {}  -- Houdt bij welke turtles actief zijn
local programName = "turtleProgram"  -- Het programma dat naar de turtles wordt verzonden

-- Functie om alle turtles in het netwerk te verkrijgen
function getTurtles()
    local ids = {}
    local termList = peripheral.getNames()
    
    -- Zoek naar alle turtles
    for _, id in ipairs(termList) do
        if peripheral.getType(id) == "turtle" then
            table.insert(ids, id)
        end
    end
    return ids
end

-- Functie om turtles te stoppen
function stopTurtles()
    for _, id in ipairs(activeTurtles) do
        rednet.send(id, "stop")
    end
end

-- Functie om turtles weer te starten
function startTurtles()
    for _, id in ipairs(activeTurtles) do
        rednet.send(id, "go")
    end
end

-- Functie om een programma naar de turtles te sturen
function sendProgramToTurtles()
    local program = fs.open(programName, "r")
    local programCode = program.readAll()
    program.close()
    
    -- Versleutelen van het programma (Base64)
    local encodedCode = textutils.serializeToBase64(programCode)
    
    for _, id in ipairs(activeTurtles) do
        rednet.send(id, "update " .. encodedCode)
    end
end

-- Functie om het aantal actieve turtles weer te geven
function showUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Aantal actieve turtles: " .. #activeTurtles)
end

-- Commando-ontvangst loop
function handleCommands()
    while true do
        local event, param = os.pullEvent("rednet_message")
        
        if event == "rednet_message" then
            local msg, sender = param, sender
            
            if msg == "stop" then
                -- Verwijder turtle uit actieve lijst
                activeTurtles[sender] = nil
                showUI()
            elseif msg == "go" then
                -- Voeg turtle toe aan actieve lijst
                table.insert(activeTurtles, sender)
                showUI()
            elseif msg == "verstuur/" .. programName then
                -- Het programma wordt geüpdatet en naar de turtles gestuurd
                sendProgramToTurtles()
            end
        end
    end
end

-- Verkrijg de turtles en toon de UI
getTurtles()
showUI()

-- Start de commando-handler
handleCommands()
