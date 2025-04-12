-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

local locked = false
local runningTasks = {}

-- Voer een programma in de achtergrond uit
local function runProgramAsync(name)
    local task = function()
        local success, err = pcall(function()
            shell.run(name)
        end)
        if not success then
            print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
        end
    end

    table.insert(runningTasks, task)
end

-- Verwerk rednet berichten
local function listenForRednet()
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
            runProgramAsync(msg)
        end
    end
end

-- Laat de gebruiker ook lokaal iets typen en uitvoeren
local function listenForKeyboard()
    while true do
        term.setCursorBlink(true)
        term.setCursorPos(1, 1)
        print("Typ een commando om uit te voeren (lokaal):")
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if not locked and input ~= "" then
            runProgramAsync(input)
        end
    end
end

-- Combineer rednet luisteren, keyboard en actieve taken
while true do
    local tasks = {listenForRednet, listenForKeyboard}

    -- Voeg elke actieve taak toe aan de tasklist
    for _, task in ipairs(runningTasks) do
        table.insert(tasks, task)
    end

    -- Wacht tot één van de taken klaar is, dan herstart alles
    parallel.waitForAny(table.unpack(tasks))
end
