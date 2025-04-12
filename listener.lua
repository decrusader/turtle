-- listener.lua (op de turtle)

-- Open rednet om verbinding te maken met de master computer
rednet.open("left")  -- Zorg ervoor dat je de juiste kant gebruikt voor je modem

-- Wacht op het bestand
while true do
    local senderId, message, protocol = rednet.receive("fileTransferProtocol")
    
    -- Controleer of er een bestand is ontvangen
    if message then
        local filename = message[1]        -- Bestandsnaam ontvangen
        local fileContent = message[2]     -- Bestandsinhoud ontvangen

        -- Open en schrijf de inhoud naar het bestand op de turtle
        local file = fs.open(filename, "w")
        file.write(fileContent)
        file.close()

        print("Bestand " .. filename .. " is ontvangen en opgeslagen op de turtle.")
    end
end
