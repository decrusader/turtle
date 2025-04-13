-- Controleer of modem aan de linkerkant zit
if peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

rednet.open("left")

-- === Persistent Lock Opslag ===
local function loadLockStatus()
    if fs.exists("locked_status.txt") then
        local file = fs.open("locked_status.txt", "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)
    end
    return false
end

local function saveLockStatus(status)
    local file = fs.open("locked_status.txt", "w")
    file.write(textutils.serialize(status))
    file.close()
end

local locked = loadLockStatus()
local runningTask = nil

-- === Asynchrone Programma Runner ===
local function runProgramAsync(name)
    if runningTask then
        print("Er draait al een programma.")
        return
    end

    runningTask = function()
        print("Start programma: " .. name)
        local success, err = pcall(function()
            shell.run(name)
        end)

        if not success then
            print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
        else
            print("Programma " .. name .. " is afgerond.")
        end
        runningTask = nil
    end

    -- Start het programma in een aparte thread
    parallel.waitForAny(
        runningTask,
        function()
            while runningTask do
                if locked then
                    print("Programma afgebroken door vergrendeling.")
                    runningTask = nil
                    return
                end
                os.sleep(0.5)
            end
        end
    )
end

-- === Rednet Luisteraar ===
local function listenForRednet()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "destruct" or msg == "stop" then
            if not locked then
                locked = true
                saveLockStatus(true)
                print("Turtle is nu permanent geblokkeerd.")
            end

        elseif msg == "start" then
            if locked then
                locked = false
                saveLockStatus(false)
                print("Turtle is weer vrijgegeven.")
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
                    runProgramAsync(name)
                end
            end

        elseif not locked then
            runProgramAsync(msg)
        end
    end
end

-- === Lokale Input Luisteraar ===
local function listenForKeyboard()
    while true do
        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if input ~= "" and not locked then
            runProgramAsync(input)
        end
    end
end

-- === Bij opstart: blokkeer indien nodig ===
if locked then
    print("Turtle is geblokkeerd. Gebruik 'start' om hem te activeren.")
end

-- Start alles in parallel
parallel.waitForAny(
    listenForRednet,
    listenForKeyboard
)
