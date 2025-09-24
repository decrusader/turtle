local modem = peripheral.find("modem") or error("Geen modem gevonden", 0)

term.clear()
term.setCursorPos(1,1)
write("Kies een channel: ")
local channel = tonumber(read())
if not channel then error("Ongeldig channel", 0) end

modem.open(channel)
print("Chat gestart op kanaal " .. channel)
print("Crtl + t om de chat te stoppen")
sleep(3)
term.clear()
term.setCursorPos(1,1)

local function sendMessage(text)
  local id = os.getComputerID()
  modem.transmit(channel, channel, ("id: %d %s"):format(id, text))
end

local function receiveLoop()
  while true do
    local event, side, ch, replyCh, message, dist = os.pullEvent("modem_message")
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
    if keys.isDown(keys.ctrl) and keys.isDown(keys.t) then
      print("Stopped by Q + E combo")
      return  
    end
  end
end

parallel.waitForAny(receiveLoop, inputLoop, stopLoop)
