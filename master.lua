-- Controleer of modem aan de linkerkant zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet op de linker modem
rednet.open("left")

-- Verzamel actieve turtles
local function getActiveTurtles(timeout)
    local turtles = {}
    rednet.broadcast("check")  -- Vraag alle turtles om zich te melden
    local timer = os.startTimer(timeout or 2)

    while true do
        local event, p1, p2 = os.pullEvent()

        if event == "rednet_message" and type(p2) == "string" then
            if p2 == "pong" then
                turtles[p1] = true
            end

        elseif event == "timer" and p1 == timer then
            break
        end
    end

    return turtles
end

-- Verstuur een programma naar alle actieve turtles
local function sendProgramToTurtles(filename)
    if not fs.exists(filename) then
        print("Bestand '" .. filename .. "' bestaat niet.")
        return
    end

    local file = fs.open(filename, "r")
    local content = file.readAll()
    file.close()

    local turtles = getActiveTurtles()

    local count = 0
    for id in pairs(turtles) do
        rednet.send(id, "program:" .. filename .. ":" .. content)
        count = count + 1
    end

    print("Programma '" .. filename .. "' verzonden naar " .. count .. " turtle(s).")
end

-- Simpele menu-loop
while true do
    term.setCursorBlink(true)
    io.write("master> ")
    local input = read()
    term.setCursorBlink(false)

    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end

    local cmd = args[1]

    if cmd == "stop" or cmd == "start" or cmd == "destruct" then
        rednet.broadcast(cmd)
        print("Commando '" .. cmd .. "' verzonden.")

    elseif cmd == "delete" and args[2] then
        rednet.broadcast("delete:" .. args[2])
        print("Verwijdercommando voor '" .. args[2] .. "' verzonden.")

    elseif cmd == "ping" and args[2] then
        sendProgramToTurtles(args[2])

    elseif cmd == "exit" then
        print("Programma afgesloten.")
        break

    else
        print("Onbekend commando. Gebruik: start | stop | destruct | delete <bestand> | ping <bestand> | exit")
    end
end
