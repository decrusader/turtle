-- chat.lua

local modem = peripheral.find("modem") or error("Geen modem gevonden!", 0)

-- Kies kanaal
term.clear()
term.setCursorPos(1,1)
write("Kies een channel (0-65535): ")
local channel = tonumber(read()) or error("Ongeldig channel", 0)

modem.open(channel)
print("Chat gestart op channel " .. channel)
print("Typ berichten. Ctrl+T om te stoppen.")

-- Stuurfunctie
local function sendMessage(text)
    local id = os.getComputerID()
    modem.transmit(channel, channel, ("id: %d %s"):format(id, text))
end

-- Ontvangstloop
local function receiveLoop()
    while true do
        local event, side, ch, replyCh, message, distance = os.pullEvent("modem_message")
        if ch == channel then
            print(message)
        end
    end
end

-- Invoerlus
local function inputLoop()
    while true do
        local text = read()
        if #text > 0 then
            sendMessage(text)
        end
    end
end

-- Stoploop Ctrl+T
local function stopLoop()
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.t and keyboard.isControlDown() then
            print("Ctrl+T gedrukt, programma stopt")
            return
        end
    end
end

-- Parallel uitvoeren
parallel.waitForAny(receiveLoop, inputLoop, stopLoop)
