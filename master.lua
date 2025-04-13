-- Controleer of modem aan de linkerkant zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

rednet.open("left")

local turtles = {}
local lastUpdate = 0
local updateInterval = 2  -- seconden

-- Tel actieve turtles
local function countTurtles()
    local c = 0
    for _ in pairs(turtles) do
        c = c + 1
    end
    return c
end

-- Functie om actieve turtles op te halen
local function getActiveTurtles()
    turtles = {}
    rednet.broadcast("check")
    local timer = os.startTimer(1.5)

    while true do
        local event, id, msg = os.pullEvent()
        if event == "rednet_message" and msg == "pong" then
            turtles[id] = true
        elseif event == "timer" and id == timer then
            break
        end
    end
end

-- UI tekenen
local function drawUI()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)

    print("== MASTER CONTROLLER ==")
    print("Actieve turtles: " .. tostring(countTurtles()))
    print("------------------------")
    print("Commando's:")
    print("  start             -> ontgrendel turtles")
    print("  stop              -> blokkeer turtles")
    print("  destruct          -> maak turtles onbruikbaar")
    print("  ping <bestand>    -> stuur programma naar turtles")
    print("  delete <bestand>  -> verwijder programma op turtles")
    print("  exit              -> sluit dit programma")
    print("------------------------")
    io.write("master> ")
end

-- Programma verzenden
local function sendProgramToTurtles(filename)
    if not fs.exists(filename) then
        print("\nBestand '" .. filename .. "' bestaat niet.")
        return
    end

    local file = fs.open(filename, "r")
    local content = file.readAll()
    file.close()

    for id in pairs(turtles) do
        rednet.send(id, "program:" .. filename .. ":" .. content)
    end

    print("\nProgramma '" .. filename .. "' verzonden naar " .. tostring(countTurtles()) .. " turtle(s).")
end

-- Input verwerken
local function handleInput(input)
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    local cmd = args[1]

    if cmd == "exit" then
        print("Programma afgesloten.")
        return false

    elseif cmd == "start" or cmd == "stop" or cmd == "destruct" then
        rednet.broadcast(cmd)
        print("\nCommando '" .. cmd .. "' verzonden.")

    elseif cmd == "delete" and args[2] then
        rednet.broadcast("delete:" .. args[2])
        print("\nDelete commando verzonden voor '" .. args[2] .. "'.")

    elseif cmd == "ping" and args[2] then
        sendProgramToTurtles(args[2])

    else
        print("\nOngeldig commando of ontbrekend argument.")
    end

    return true
end

-- Hoofdlus
while true do
    -- Update lijst met actieve turtles elke X seconden
    if os.clock() - lastUpdate > updateInterval then
        getActiveTurtles()
        lastUpdate = os.clock()
    end

    drawUI()
    term.setCursorBlink(true)
    local input = read()
    term.setCursorBlink(false)

    if not handleInput(input) then
        break
    end
end
