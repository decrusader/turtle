-- Turtle Script: Wacht op commando's van de Master
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de rednet modem

-- Functie om turtle te registreren
function registerTurtle()
    rednet.broadcast("go")  -- Stuur bericht naar Master Computer om turtle te registreren
end

-- Wacht op commando om te stoppen
while true do
    -- Registreer de turtle bij opstarten
    registerTurtle()
    
    -- Wacht op berichten van de Master Computer
    local _, sender, _, _, message = os.pullEvent("rednet_message")
    
    print("Turtle ontving bericht: " .. message)  -- Debugging, toont het bericht dat ontvangen wordt
    
    if message == "stop" then
        -- Stop de turtle
        term.clear()
        term.setCursorPos(1, 1)
        print("Turtle gestopt. Wacht op opdracht.")
        break
    elseif message == "go" then
        -- De turtle blijft actief
        term.clear()
        term.setCursorPos(1, 1)
        print("Turtle is actief.")
    end
end
