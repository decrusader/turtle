-- Controleer of modem aan de linkerkant zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open modem
rednet.open("left")

-- Lijst van actieve turtles
local turtles = {}

-- Ping alle turtles en vraag status
local function pingTurtles()
    turtles = {}
    rednet.broadcast("ping")
    local start = os.clock()

    while os.clock() - start < 2 do
        local id, msg = rednet.receive(0.2)
        if msg == "pong" then
            turtles[id] = true
        end
    end
end

-- UI scherm
local function drawUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Master Controlepaneel")
    print("----------------------")
    print("Aantal actieve turtles: " .. tostring(#(function()
        local count = 0
        for _ in pairs(turtles) do count = count + 1 end
        return count
    end)()))
    print("")
    print("[1] Stop turtles (blokkeren)")
    print("[2] Start turtles (ontgrendelen)")
    print("[3] Ping opnieuw")
    print("[4] Verlaat programma")
end

-- Stuur commando naar alle turtles
local function broadcastCommand(cmd)
    for id in pairs(turtles) do
        rednet.send(id, cmd)
    end
end

-- Hoofdloop
while true do
    pingTurtles()
    drawUI()

    local event, key = os.pullEvent("key")
    if key == keys.one then
        broadcastCommand("stop")
        print("Stop commando verzonden.")
        os.sleep(1)

    elseif key == keys.two then
        broadcastCommand("start")
        print("Start commando verzonden.")
        os.sleep(1)

    elseif key == keys.three then
        print("Pingen...")
        os.sleep(1)

    elseif key == keys.four then
        print("Programma afgesloten.")
        break
    end
end
