-- main.lua

-- Controleer of modem links zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

rednet.open("left")

-- Bestandsnaam voor lock status
local LOCK_FILE = "locked_status.txt"

-- Laad status
local function loadLockStatus()
    if fs.exists(LOCK_FILE) then
        local f = fs.open(LOCK_FILE, "r")
        local data = textutils.unserialize(f.readAll())
        f.close()
        return data == true
    end
    return false
end

-- Sla status op
local function saveLockStatus(state)
    local f = fs.open(LOCK_FILE, "w")
    f.write(textutils.serialize(state))
    f.close()
end
-- testcode
local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            if not locked then
                locked = true
                saveLockStatus(true)
                print("Turtle geblokkeerd door master. Uitvoering wordt gestopt.")
                os.sleep(2)
                return -- Stop het programma (wordt herstart door startup.lua)
            end

        elseif msg == "start" then
            if locked then
                locked = false
                saveLockStatus(false)
                print("Turtle opnieuw geactiveerd.")
            end
end
-- testcode
-- Blokkeer turtle indien vergrendeld
local locked = loadLockStatus()

if locked then
    print("Turtle is geblokkeerd. Werking onmogelijk.")
    os.sleep(2)
    return
end

-- Voer een programma veilig uit
local function runProgram(name)
    if locked then return end

    print("Start programma: " .. name)
    local success, err = pcall(function()
        shell.run(name)
    end)
    if not success then
        print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
    else
        print("Programma voltooid.")
    end
end

-- Luister naar rednet
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            if not locked then
                locked = true
                saveLockStatus(true)
                print("Turtle geblokkeerd door master. Uitvoering wordt gestopt.")
                os.sleep(2)
                return -- Stop het programma (wordt herstart door startup.lua)
            end

        elseif msg == "start" then
            if locked then
                locked = false
                saveLockStatus(false)
                print("Turtle opnieuw geactiveerd.")
            end

        elseif msg == "destruct" then
            print("Turtle permanent uitgeschakeld.")
            os.sleep(2)
            os.shutdown()

        elseif msg:sub(1, 7) == "delete:" then
            local file = msg:sub(8)
            if fs.exists(file) then fs.delete(file) end

        elseif msg:sub(1, 8) == "program:" then
            local rest = msg:sub(9)
            local name, code = rest:match("([^:]+):(.+)")
            if name and code then
                local f = fs.open(name, "w")
                f.write(code)
                f.close()
                if not locked then runProgram(name) end
            end

        elseif not locked then
            runProgram(msg)
        end
    end
end

-- Lokale invoer (alleen als niet geblokkeerd)
local function listenForInput()
    while true do
        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if input and input ~= "" and not locked then
            runProgram(input)
        end
    end
end

-- Start alles tegelijk
parallel.waitForAll(
    listenForRednet,
    listenForInput
)
