-- Controleer of modem aan de linkerkant zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

-- Laad de vergrendelingsstatus uit bestand
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

-- Vergrendel de turtle
local function blockTurtle()
    while locked do
        os.sleep(1)  -- Wacht 1 seconde tussen de checks
    end
end

-- Voer programma's uit
local function runProgramAsync(name)
    if locked then
        return
    end
    local success, err = pcall(function() shell.run(name) end)
    if not success then
        print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
    end
end

-- Verwerk rednet berichten
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            -- Vergrendel de turtle zonder automatisch afsluiten
            locked = true
            saveLockStatus(locked)

        elseif msg == "go" then
            -- Ontgrendel de turtle
            locked = false
            saveLockStatus(locked)

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
                end
            end

        elseif not locked then
            runProgramAsync(msg)
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
            runProgramAsync(input)
        end
    end
end

-- Laad vergrendelingsstatus bij opstarten
local locked = loadLockStatus()

-- Start de rednet en keyboard luisteraars
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
