-- chat.lua
-- Simpel chatprogramma met keuze voor kanaal

-- Vind modem en open
local modem = peripheral.find("modem") or error("Geen modem gevonden", 0)

-- Vraag kanaal
term.clear()
term.setCursorPos(1,1)
write("Kies een channel (0-65535): ")
local channel = tonumber(read())
if not channel then error("Ongeldig channel", 0) end

-- Open kanaal
modem.open(channel)
print("Chat gestart op kanaal " .. channel)
print("Typ berichten hieronder. Ctrl+T om te stoppen.")

-- Functie om berichten te sturen
local function sendMessage(text)
  local id = os.getComputerID()
  modem.transmit(channel, channel, ("id: %d %s"):format(id, text))
end

-- Parallel: 1 = luisteren, 2 = typen
local function receiveLoop()
  while true do
    local event, side, ch, replyCh, message, dist = os.pullEvent("modem_message")
    if ch == channel then
      print(message)  -- gewoon tonen
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

parallel.waitForAny(receiveLoop, inputLoop)
