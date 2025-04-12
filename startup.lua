-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

-- Functie om de vergrendelingsstatus op te slaan in een bestand
local function saveLockStatus(status)
    local file = fs.open("locked_status.txt", "w")
    file.write(textutils.serialize(status))  -- Sla de status op als tekst
    file.close()
end

-- Functie om de vergrendelingsstatus in te lezen van een bestand
local function loadLockStatus()
    if fs.exists("locked_status.txt") then
        local file = fs.open("locked_status.txt", "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)  -- Zet de opgeslagen tekst om in een boolean
    else
        return false  -- Als er geen bestand is, gaan we ervan uit dat de turtle niet vergrendeld is
    end
end

-- Laad de status van de vergrendeling bij het opstarten
local locked = loadLockStatus()

-- Functie om de turtle volledig te blokkeren
local function blockTurtle()
    while locked do
        os.sleep(1)  -- Wacht 1 seconde tussen de checks, zodat de turtle niets kan doen.
    end
end

-- Voer een programma in de achtergrond uit
local function runProgramAsync(name)
    if locked then
        print("Turtle is vergrendeld en kan geen programma uitvoeren.")
        return
    end

    parallel.waitForAny(function()
        local success, err = pcall(function()
            shell.run(name)
        end)
        if not success then
            print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
        end
    end)
end

-- Verwerk rednet berichten
local function listenForRednet()
    while true do
        -- Als turtle vergrendeld is, stop dan de uitvoering van deze functie
        blockTurtle()

        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            locked = true
            saveLockStatus(locked)  -- Sla de vergrendelingsstatus op
            print("Turtle is nu vergrendeld. Geen programma's kunnen meer worden uitgevoerd.")
            print("Turtle blokkeert nu en sluit automatisch af.")
            os.sleep(3)  -- Wacht een paar seconden om het bericht te tonen
            os.shutdown()  -- Stop de turtle automatisch na het blokkeren

        elseif msg == "go" then
            locked = false
            saveLockStatus(locked)  -- Sla de vergrendelingsstatus op
            print("Turtle is ontgrendeld en kan weer programma's uitvoeren.")

        elseif string.sub(msg, 1, 7) == "delete:" then
            local name = string.sub(msg, 8)
            if fs.exists(name) then
                fs.delete(name)
            end

        elseif string.sub(msg, 1, 8) == "program:" then
            local rest = string.sub(msg, 9)
            local name, code = rest:match("([^:]+):(.+)")
            if name and code then
                local file = fs.open(name, "w")
                file.write(code)
                file.close()

                if not locked then
                    runProgramAsync(name)
                else
                    print("Turtle is vergrendeld, kan het programma niet uitvoeren.")
                end
            end

        elseif not locked then
            runProgramAsync(msg)
        else
            print("Turtle is vergrendeld, kan geen programma uitvoeren.")
        end
    end
end

-- Laat de gebruiker lokaal iets intypen en uitvoeren
local function listenForKeyboard()
    while true do
        -- Als turtle vergrendeld is, stop dan de uitvoering van deze functie
        blockTurtle()

        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if not locked and input ~= "" then
            runProgramAsync(input)
        elseif locked then
            print("Turtle is vergrendeld, kan geen programma uitvoeren.")
        end
    end
end

-- Start permanent luisterende lussen
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
