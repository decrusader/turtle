-- Controleer of er een modem aan de linkerkant zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via de linker modem
rednet.open("left")

-- Laad de vergrendelingsstatus uit bestand
local function loadLockStatus()
    if fs.exists("locked_status.txt") then
        local file = fs.open("locked_status.txt", "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)  -- Zet de opgeslagen tekst om in een boolean
    else
        return false  -- Geen vergrendelingsbestand betekent standaard niet vergrendeld
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

-- Voer programma's uit, check of de turtle vergrendeld is
local function runProgram(name)
    if locked then
        print("Turtle is vergrendeld, kan programma niet uitvoeren.")
        return
    end

    print("Programma " .. name .. " wordt uitgevoerd...")
    
    local success, err = pcall(function()
        if not locked then
            shell.run(name)
        end
    end)

    if not success then
        print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
    end

    print("Programma " .. name .. " is afgerond.")
end

-- Verwerk rednet berichten
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()  -- Wacht op berichten
        print("Ontvangen bericht van id " .. id .. ": " .. msg)

        -- Ping-bericht: Beantwoord met 'pong', maar beïnvloedt geen vergrendelingsstatus
        if msg == "ping" then
            rednet.send(id, "pong")
            print("Ping ontvangen van id " .. id)

        -- Stop-bericht: Vergrendel de turtle
        elseif msg == "stop" then
            if not locked then
                locked = true
                saveLockStatus(locked)
                print("Turtle is nu geblokkeerd.")
            else
                print("Turtle is al geblokkeerd.")
            end

        -- Go-bericht: Ontgrendel de turtle
        elseif msg == "go" then
            if locked then
                locked = false
                saveLockStatus(locked)
                print("Turtle is ontgrendeld.")
            else
                print("Turtle is al ontgrendeld.")
            end

        -- Verwijder bestand-bericht
        elseif string.sub(msg, 1, 7) == "delete:" then
            local name = string.sub(msg, 8)
            if fs.exists(name) then
                fs.delete(name)
                print("Bestand " .. name .. " verwijderd.")
            end

        -- Programma uploaden
        elseif string.sub(msg, 1, 8) == "program:" then
            local rest = string.sub(msg, 9)
            local name, code = rest:match("([^:]+):(.+)")
            if name and code then
                local file = fs.open(name, "w")
                file.write(code)
                file.close()
                if not locked then
                    runProgram(name)
                end
            end

        -- Andere berichten: Voer het programma uit, maar alleen als de turtle niet vergrendeld is
        elseif not locked then
            runProgram(msg)
        else
            print("Programma kan niet worden uitgevoerd omdat de turtle is vergrendeld.")
        end
    end
end

-- Laat de gebruiker lokaal een programma uitvoeren
local function listenForKeyboard()
    while true do
        blockTurtle()  -- Blokkeer de turtle als deze vergrendeld is

        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if input ~= "" and not locked then
            runProgram(input)
        elseif locked then
            print("Programma kan niet worden uitgevoerd omdat de turtle is vergrendeld.")
        end
    end
end

-- Laad vergrendelingsstatus bij opstarten
local locked = loadLockStatus()
print("Begin status van turtle (na opstarten): " .. tostring(locked))

-- Zorg ervoor dat rednet opnieuw wordt geopend bij opstarten
if not rednet.isOpen("left") then
    rednet.open("left")
end

-- Start de rednet en keyboard luisteraars
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
