-- Controleer of de modem aan de rechterkant zit (modem op de turtle)
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end
-- Lijst van id's van alle verkochte turtles

-- Open rednet via de linker modem
rednet.open("left")

-- Functie voor verkochte turtle id's toe te voegen
local function addID(id)
    local file = fs.open("ids.txt", "a")
    file.append("\n"..id)
    file.close()
    print("Id nummer "..id.." is toegevoed")
end
-- Functie om een bericht naar de turtle te sturen
local function sendMessageToTurtle(msg)
    print("Verstuur bericht naar turtle: " .. msg)
    rednet.broadcast(msg)  -- Stuur het bericht naar alle turtles via de modem
end

-- Functie om de turtle te stoppen
local function stopTurtle()
    sendMessageToTurtle("stop")  -- Stop de turtle
    print("Turtle is geblokkeerd en wordt afgesloten...")
end

-- Functie om de turtle te starten (ontgrendelen)
local function startTurtle()
    sendMessageToTurtle("start")  -- Start de turtle
    print("Turtle is nu ontgrendeld en kan weer werken.")
end

-- Functie om een programma naar de turtle te sturen
local function sendProgramToTurtle(programName, programCode)
    local msg = "program:" .. programName .. ":" .. programCode
    sendMessageToTurtle(msg)
    print("Programma '" .. programName .. "' gestuurd naar turtle.")
end

-- Functie voor interactie met de gebruiker
local function userInput()
    while true do
        print("\nVoer een commando in: stop, start, send <programma naam> <code>, add id <id>")
        io.write("> ")
        local input = read()

        -- Verwerk de input van de gebruiker
        local command, arg1, arg2 = input:match("^(%w+)%s*(%S*)%s*(.*)")

        if command == "stop" then
            stopTurtle()  -- Verzend stop-commando naar de turtle
        elseif command == "start" then
            startTurtle()  -- Verzend start-commando naar de turtle
        elseif command == "send" and arg1 and arg2 then
            sendProgramToTurtle(arg1, arg2)  -- Verzend programma naar de turtle
        elseif command == "add id" and arg1 then
            addID(arg1) -- Voeg id toe
        else
            print("Ongeldig commando.")
        end
    end
end

-- Start het script en wacht op commando's van de gebruiker
userInput()
