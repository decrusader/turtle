-- Master Computer Script
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de modem voor communicatie

local activeTurtles = {}  -- Houdt bij welke turtles actief zijn
local programName = "turtleProgram"  -- Het programma dat naar de turtles wordt verzonden

-- Functie om het aantal actieve turtles weer te geven
function showUI()
    term.clear()  -- Wis het scherm
    term.setCursorPos(1, 1)
    print("Aantal actieve turtles: " .. #activeTurtles)  -- Toon het aantal actieve turtles
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

-- Functie om alle turtles op te vragen en hun status te controleren
function checkTurtleStatus()
    local turtles = rednet.lookup("turtle", nil)  -- Zoek naar alle turtles op het netwerk
    for _, turtleID in ipairs(turtles) do
        -- Stuur een bericht naar de turtle om zijn brandstofstatus te controleren
        rednet.send(turtleID, "checkStatus")
        local _, status = rednet.receive()
        
        if status == "active" then
            -- Turtle heeft brandstof en is dus actief
            startTurtle(turtleID)
        else
            -- Turtle heeft geen brandstof en is dus niet actief
            stopTurtle(turtleID)
        end
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

-- Functie om alles te stoppen en de actieve lijst te wissen
function clearTurtles()
    for _, id in ipairs(activeTurtles) do
        rednet.send(id, "stop")
    end
    activeTurtles = {}  -- Leeg de lijst van actieve turtles
    showUI()  -- Update de UI na het wissen
end

-- Functie om het scherm van de master computer leeg te maken
function clearScreen()
    term.clear()  -- Wis het scherm
    term.setCursorPos(1, 1)  -- Zet de cursor naar de bovenkant van het scherm
    print("Scherm gewist!")  -- Optioneel, je kunt hier een bericht tonen
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
            elseif msg == "clear" then
                -- Wis het scherm van de master computer
                clearScreen()
            elseif msg == "clearTurtles" then
                -- Stop alles en wis de actieve turtles
                clearTurtles()
            end
        end
    end
end

-- Toon de UI voor het eerst en start de commando-handler
showUI()

-- Roep de functie aan om de status van alle turtles te controleren
checkTurtleStatus()

-- Start de commando-handler
handleCommands()
