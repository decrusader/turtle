-- Turtle Script: Wacht op commando's van de Master
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de rednet modem

local programName = "turtleProgram"  -- Het programma dat de master verzendt
local password = "geheim"  -- Het wachtwoord voor beveiliging

-- Functie om om het wachtwoord te vragen
function askForPassword()
    term.clear()
    term.setCursorPos(1, 1)
    write("Voer het wachtwoord in: ")
    local input = read()
    if input == password then
        return true
    else
        print("Wachtwoord incorrect!")
        return false
    end
end

-- Altijd wachten op commando van de master computer
while true do
    local _, sender, _, _, message = os.pullEvent("rednet_message")
    
    if message == "stop" then
        -- Stop de turtle
        term.clear()
        term.setCursorPos(1, 1)
        print("Turtle gestopt. Wacht op opdracht.")
        break
    elseif message == "go" then
        -- Start de turtle weer
        term.clear()
        term.setCursorPos(1, 1)
        print("Turtle gestart! Begin met werken.")
        
        -- Wacht op een geüpdate versie van het programma
        while true do
            local _, sender, _, _, message = os.pullEvent("rednet_message")
            
            if string.sub(message, 1, 7) == "update " then
                -- Ontvang en decodeer de versleutelde code
                local encodedCode = string.sub(message, 8)
                local decodedCode = textutils.unserializeFromBase64(encodedCode)
                
                -- Sla het gedecodeerde bestand op
                local file = fs.open(programName, "w")
                file.write(decodedCode)
                file.close()
                
                -- Voer het programma uit
                term.clear()
                term.setCursorPos(1, 1)
                print("Programma bijgewerkt! Het programma wordt uitgevoerd.")
                
                -- Voer het gedecodeerde programma uit
                load(decodedCode)()
                break
            end
        end
    end
end
