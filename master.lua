-- master.lua (op de master computer)

-- Functie om te controleren of een bestand bestaat
function fileExists(filename)
    local file = fs.open(filename, "r")
    if file then
        file.close()
        return true
    else
        return false
    end
end

-- Bestand en turtle ID
local filename = "mine.lua"      -- Het bestand dat je wilt versturen
local turtleId = 1               -- Vervang dit met de juiste turtle ID (meestal het ID van de turtle)

-- Controleer of het bestand bestaat
if fileExists(filename) then
    -- Open het bestand en lees de inhoud
    local file = fs.open(filename, "r")
    local fileContent = file.readAll()
    file.close()

    -- Verbind met de turtle via rednet
    rednet.open("left")  -- Zorg ervoor dat je de juiste kant gebruikt voor je modem

    -- Verstuur het bestand naar de turtle
    print("Verzend bestand " .. filename .. " naar turtle " .. turtleId)
    rednet.send(turtleId, {filename, fileContent}, "fileTransferProtocol")

    print("Bestand succesvol verzonden naar turtle.")
else
    print("Het bestand " .. filename .. " bestaat niet.")
end
