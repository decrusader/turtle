-- Master computer
local activeTurtles = {}
local turtleCount = 0
local PROGRAM_NAME = "example_program"

-- Functie om turtles te controleren
local function checkTurtles()
    -- Probeer verbinding te maken met elke turtle op het netwerk
    local turtles = peripheral.getNames()
    activeTurtles = {}
    turtleCount = 0

    for _, name in ipairs(turtles) do
        if string.match(name, "turtle") then
            if peripheral.call(name, "getFuelLevel") then
                table.insert(activeTurtles, name)
                turtleCount = turtleCount + 1
            end
        end
    end
end

-- Functie om een commando naar een turtle te sturen
local function sendCommandToTurtle(turtle, command)
    if peripheral.call(turtle, "executeCommand", command) then
        print("Commando '" .. command .. "' verzonden naar " .. turtle)
    else
        print("Kon commando niet verzenden naar " .. turtle)
    end
end

-- Functie om een programma naar een turtle te sturen
local function sendProgramToTurtle(turtle, programName)
    local program = fs.open(programName, "r")
    if program then
        local programCode = program.readAll()
        program.close()
        local file = fs.open("/rom/programs/" .. programName, "w")
        file.write(programCode)
        file.close()
        sendCommandToTurtle(turtle, "run " .. programName)
        print("Programma " .. programName .. " verzonden naar " .. turtle)
    else
        print("Kon programma " .. programName .. " niet vinden.")
    end
end

-- Functie om de UI weer te geven
local function displayUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Master Computer - Status")
    print("Aantal actieve turtles: " .. turtleCount)
    print("")
end

-- Main loop voor commando's
while true do
    displayUI()
    print("Geef commando in (stop/go/verstuur/update): ")
    local input = read()

    if input == "stop" then
        for _, turtle in ipairs(activeTurtles) do
            sendCommandToTurtle(turtle, "stop")
        end
        print("Alle turtles zijn gestopt.")
    elseif input == "go" then
        for _, turtle in ipairs(activeTurtles) do
            sendCommandToTurtle(turtle, "go")
        end
        print("Alle turtles zijn geactiveerd.")
    elseif input == "verstuur" or input == "update" then
        for _, turtle in ipairs(activeTurtles) do
            sendProgramToTurtle(turtle, PROGRAM_NAME)
        end
        print("Programma " .. PROGRAM_NAME .. " verzonden naar alle turtles.")
    end

    -- Wacht 5 seconden voor de volgende check
    sleep(5)
    checkTurtles()
end
