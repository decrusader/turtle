-- Master Computer Script
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de modem voor communicatie

local activeTurtles = {}  -- Houdt bij welke turtles actief zijn
local programName = "turtleProgram"  -- Het programma dat naar de turtles wordt verzonden

-- Functie om het aantal actieve turtles weer te geven
function showUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Aantal actieve turtles: " .. #activeTurtles)
end

-- Functie om turtles te stoppen
function stopTurtle(turtleID)
    -- Zoek de turtle in de lijst en verwijder deze
    for i, id in ipairs(activeTurtles) do
        if id == turtleID then
            table.remove(activeTurtles, i)
            break
        end
    end
    showUI()  -- Update de UI met het nieuwe aantal actieve turtles
end

-- Functie om turtles weer te starten
function startTurtle(turtleID)
    -- Voeg de turtle toe aan de lijst van actieve turtles
    table.insert(activeTurtles, turtleID)
    showUI()  -- Update de UI met het nieuwe aantal actieve turtles
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

-- Commando-ontvangst loop
function handleCommands()
    while true do
        local event, param = os.pullEvent("rednet_message")
        
        if event == "rednet_message" then
            local msg, sender = param, sender
            
            if msg == "stop" then
                -- Verwijder turtle uit actieve lijst
                stopTurtle(sender)
            elseif msg == "go" then
                -- Voeg turtle toe aan actieve lijst
                startTurtle(sender)
            elseif msg == "verstuur/" .. programName then
                -- Het programma wordt geüpdatet en naar de turtles gestuurd
                sendProgramToTurtles()
            end
        end
    end
end

-- Start de commando-handler
handleCommands()
