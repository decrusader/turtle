-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

local locked = false
local runningTasks = {}

-- Functie om een programma in de achtergrond uit te voeren
local function runProgramAsync(name)
    local task = function()
        local success, err = pcall(function()
            shell.run(name)
        end)
        if not success then
            print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
        end
    end

    -- Start in een parallelle thread
    table.insert(runningTasks, task)
end

-- Event handler loop
local function listenForCommands()
    while true do
        local id, msg = rednet.receive()

        if msg == "ping" then
            rednet.send(id, "pong")

        elseif msg == "stop" then
            locked = true

        elseif msg == "go" then
            locked = false

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
            -- Als niet gelockt en onbekend commando, probeer als programma uit te voeren
            runProgramAsync(msg)
        end
    end
end

-- Parallel-loop: command listener + alle async taken
while true do
    local tasks = {listenForCommands}

    -- Voeg actieve shell-runs toe
    for _, task in ipairs(runningTasks) do
        table.insert(tasks, task)
    end

    -- Wacht tot iets klaar is (of blijft luisteren als alles draait)
    parallel.waitForAny(table.unpack(tasks))
end
