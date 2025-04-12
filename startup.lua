-- Turtle Script
local modemSide = "left"  -- Pas dit aan als de modem aan een andere kant is aangesloten
rednet.open(modemSide)    -- Open de rednet modem

-- Functie om turtle te registreren
function registerTurtle()
    rednet.broadcast("go")  -- Stuur bericht naar Master Computer om turtle te registreren
end

-- Functie om de status van de turtle te controleren
function checkTurtleStatus()
    -- Controleer of de turtle brandstof heeft (actief is)
    if turtle.getFuelLevel() > 0 then
        rednet.send(rednet.lookup("master")[1], "active")  -- Stuur een "active" bericht naar de master
    else
        rednet.send(rednet.lookup("master")[1], "inactive")  -- Stuur een "inactive" bericht naar de master
    end
end

-- Luister naar berichten van de Master Computer
while true do
    local _, sender, _, _, message = os.pullEvent("rednet_message")
    
    if message == "checkStatus" then
        checkTurtleStatus()  -- Controleer de status van de turtle
    elseif message == "stop" then
        -- Stop de turtle
        term.clear()
        term.setCursorPos(1, 1)
        print("Turtle gestopt. Wacht op opdracht.")
        break
    end
end
