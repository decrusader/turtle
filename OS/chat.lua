local modem = peripheral.find("modem") or error("Geen modem gevonden!", 0)

term.clear()
term.setCursorPos(1,1)
write("Kies een channel (0-65535): ")
local channel = tonumber(read()) or error("Ongeldig channel", 0)

modem.open(channel)
print("Chat gestart op channel " .. channel)
print("Typ berichten. Ctrl+T om te stoppen.")
sleep(3)
term.clear()

local function sendMessage(text)
    local id = os.getComputerID()
    modem.transmit(channel, channel, ("id: %d %s"):format(id, text))
end

local function receiveLoop()
    while true do
        local event, side, ch, replyCh, message, distance = os.pullEvent("modem_message")
        if ch == channel then
            print("id: %d %s",message)
        end
    end
end

local function inputLoop()
    while true do
        local text = read()
        if #text > 0 then
            sendMessage(text)
        end
    end
end

local function stopLoop()
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.t and key.e then
            return
        end
    end
end

parallel.waitForAny(receiveLoop, inputLoop, stopLoop)
