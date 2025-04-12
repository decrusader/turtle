-- Controleer of modem aan de linkerkant zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

-- Laad de vergrendelingsstatus uit bestand bij opstarten
local function loadLockStatus()
    if fs.exists("locked_status.txt") then
        local file = fs.open("locked_status.txt", "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)  -- Zet de opgeslagen tekst om in een boolean
    else
        return false  -- Als er geen bestand is, is de turtle niet vergrendeld
    end
end

-- Sla de vergrendelingsstatus op in een bestand
local function saveLockStatus(status)
    local file = fs.open("locked_status.txt", "w")
    file.write(textutils.serialize(status))
    file.close()
end

-- Vergrendel de turtle (blokkeren voor de uitvoering van commando's)
local function blockTurtle()
    while locked do
        os.sleep(1)  -- Wacht 1 seconde tussen de checks
    end
end

-- Voer programma's uit
local function runProgram(name)
    if locked then return end  -- Voorkom uitvoeren als de turtle is vergrendeld

    print("Programma " .. name .. " wordt uitgevoerd...")
    local success, err = pcall(function()
        shell.run(name)
    end)

    if not success then
        print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
    end

    print("Programma " .. name .. " is afgerond.")
end

-- Verwerk rednet berichten
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            if not locked then
                locked = true
                saveLockStatus(locked)  -- Directe opslaan van status
                print("Turtle is nu geblokkeerd. Het programma zal stoppen en turtle afsluiten.")
                -- Turtle afsluiten na een korte pauze zodat de boodschap wordt weergegeven
                os.sleep(2)
                os.shutdown()  -- Sluit de turtle af

            end

        elseif msg == "start" then
            if locked then
                locked = false
                saveLockStatus(locked)  -- Directe opslaan van status
                print("Turtle is nu ontgrendeld en kan weer werken.")
            end

        elseif msg:sub(1, 7) == "delete:" then
            local name = msg:sub(8)
            if fs.exists(name) then
                fs.delete(name)
            end

        elseif msg:sub(1, 8) == "program:" then
            local rest = msg:sub(9)
            local name, code = rest:match("([^:]+):(.+)")
            if name and code then
                local file = fs.open(name, "w")
                file.write(code)
                file.close()

                if not locked then
                    runProgram(name)
                end
            end

        elseif not locked then
            runProgram(msg)
        end
    end
end

-- Laat de gebruiker lokaal een programma uitvoeren
local function listenForKeyboard()
    while true do
        blockTurtle()

        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if input ~= "" and not locked then
            runProgram(input)
        end
    end
end

-- Laad de vergrendelingsstatus bij opstarten
local locked = loadLockStatus()

-- Check of de turtle geblokkeerd is bij opstarten en sluit af als dat nodig is
if locked then
    print("Turtle is geblokkeerd en kan niet worden gebruikt.")
    print("De turtle zal zichzelf afsluiten.")
    os.sleep(2)  -- Wacht een moment om de boodschap te tonen
    os.shutdown()  -- Sluit de turtle af
end

-- Start de rednet en keyboard luisteraars
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
