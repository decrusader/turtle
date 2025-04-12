-- Master Computer Script
local activeTurtles = {}  -- Turtles die actief zijn (we gaan een lijst gebruiken om te tracken)
local programName = "turtleProgram"  -- Naam van het te verzenden programma

-- Functie om alle turtles te verkrijgen in het netwerk
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

-- Functie om een programma naar alle turtles te verzenden
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

-- UI om het aantal actieve turtles te tonen
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
                -- Turtle is gestopt
                activeTurtles[sender] = nil
                showUI()
            elseif msg == "go" then
                -- Turtle is weer actief
                table.insert(activeTurtles, sender)
                showUI()
            elseif msg == "verstuur/" .. programName then
                -- Het programma wordt geüpdatet en naar de turtles gestuurd
                sendProgramToTurtles()
            end
        end
    end
end

-- Start het commando handler
getTurtles()
showUI()
handleCommands()
