-- Controleer of modem aan de linkerkant zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

-- Bestandspad voor lock status
local LOCK_FILE = "locked_status.txt"
local locked = false

-- Laad de vergrendelingsstatus uit bestand
local function loadLockStatus()
    if fs.exists(LOCK_FILE) then
        local file = fs.open(LOCK_FILE, "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data) or false
    else
        return false
    end
end

-- Sla de vergrendelingsstatus op
local function saveLockStatus(status)
    local file = fs.open(LOCK_FILE, "w")
    file.write(textutils.serialize(status))
    file.close()
end

-- Voer programma uit als turtle niet geblokkeerd is
local function runProgram(name)
    if locked then
        print("Kan programma niet uitvoeren. Turtle is geblokkeerd.")
        return
    end

    print("Start programma: " .. name)
    local success, err = pcall(function()
        shell.run(name)
    end)

    if not success then
        print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
    else
        print("Programma '" .. name .. "' is afgerond.")
    end
end

-- Verwerk rednet berichten
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            locked = true
            saveLockStatus(true)
            print("Turtle is nu geblokkeerd. Geen programma's kunnen worden uitgevoerd.")
        elseif msg == "destruct" then
            locked = true
            saveLockStatus(true)
            while true do
                print("Turtle is nu onbruikbaar gemaakt. Hij zal zichzelf altijd afsluiten.")
                os.sleep(2)
                os.shutdown()
            end

        elseif msg == "start" then
            locked = false
            saveLockStatus(false)
            print("Turtle is opnieuw geactiveerd.")

        elseif msg:sub(1, 7) == "delete:" then
            local name = msg:sub(8)
            if fs.exists(name) then
                fs.delete(name)
                print("Bestand '" .. name .. "' verwijderd.")
            end

        elseif msg:sub(1, 8) == "program:" then
            local rest = msg:sub(9)
            local name, code = rest:match("([^:]+):(.+)")
            if name and code then
                local file = fs.open(name, "w")
                file.write(code)
                file.close()
                print("Programma '" .. name .. "' opgeslagen.")
                if not locked then
                    runProgram(name)
                end
            end

        elseif not locked then
            runProgram(msg)
        else
            print("Ontvangen commando genegeerd. Turtle is geblokkeerd.")
        end
    end
end

-- Luister naar keyboard input voor lokale programma-oproep
local function listenForKeyboard()
    while true do
        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if input ~= "" then
            if not locked then
                runProgram(input)
            else
                print("Turtle is geblokkeerd. Voer eerst 'start' uit via master.")
            end
        end
    end
end

-- Laad initiële status bij opstart
locked = loadLockStatus()

if locked then
    print("Turtle is geblokkeerd. Wacht op 'start' commando via master...")
end

-- Start rednet en keyboard listeners
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
