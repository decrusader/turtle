-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")
print("Rednet geopend via linker modem.")

local turtles = {}

-- Functie om turtles te detecteren
local function pingTurtles()
    turtles = {}
    rednet.broadcast("ping")
    local timer = os.startTimer(2)

    while true do
        local event, id, msg = os.pullEvent()
        if event == "rednet_message" and msg == "pong" then
            table.insert(turtles, id)
        elseif event == "timer" and id == timer then
            break
        end
    end
end

-- UI weergeven
local function drawUI()
    term.clear()
    term.setCursorPos(1,1)
    print("Master Controller")
    print("Aantal actieve turtles: " .. #turtles)
    print("")
    print("Typ een commando hieronder:")
    print("  stop")
    print("  go")
    print("  verstuur <bestandsnaam>")
    print("  update <bestandsnaam>")
    print("")
    io.write("> ")
end

-- Programma verzenden naar turtles
local function sendProgramToTurtles(programName)
    if not fs.exists(programName) then
        print("Programma '" .. programName .. "' niet gevonden.")
        return
    end

    local file = fs.open(programName, "r")
    local data = file.readAll()
    file.close()

    for _, id in ipairs(turtles) do
        rednet.send(id, "delete:" .. programName)
        sleep(0.1)
        rednet.send(id, "program:" .. programName .. ":" .. data)
        sleep(0.1)
    end

    print("Programma '" .. programName .. "' verzonden naar alle turtles.")
end

-- Start eerste ping en UI
pingTurtles()
drawUI()
local refreshTimer = os.startTimer(2)

-- Hoofdlus: event-driven
while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "timer" and p1 == refreshTimer then
        pingTurtles()
        drawUI()
        refreshTimer = os.startTimer(5)

    elseif event == "char" then
        -- Begin met invoer van commando
        term.setCursorBlink(true)
        local input = read()
        term.setCursorBlink(false)

        local command, arg = input:match("^(%S+)%s*(.-)$")

        if command == "stop" or command == "go" then
            for _, id in ipairs(turtles) do
                rednet.send(id, command)
            end
            print("Commando '" .. command .. "' verzonden.")
        elseif (command == "verstuur" or command == "update") and arg ~= "" then
            sendProgramToTurtles(arg)
        else
            print("Ongeldig of onvolledig commando.")
        end

        sleep(2)
        pingTurtles()
        drawUI()
        refreshTimer = os.startTimer(5)
    end
end
