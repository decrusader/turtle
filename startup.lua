-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

local locked = false

-- Voer een programma in een aparte thread uit
local function runProgramAsync(name)
    local co = coroutine.create(function()
        local success, err = pcall(function()
            shell.run(name)
        end)
        if not success then
            print("Fout bij uitvoeren van '" .. name .. "': " .. tostring(err))
        end
    end)
    -- Start als coroutine in parallel
    parallel.waitForAny(function() coroutine.resume(co) end)
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

-- Laat de gebruiker lokaal iets intypen en uitvoeren
local function listenForKeyboard()
    while true do
        term.setCursorBlink(true)
        io.write("> ")
        local input = read()
        term.setCursorBlink(false)

        if not locked and input ~= "" then
            runProgramAsync(input)
        end
    end
end

-- Start permanent luisterende lussen
parallel.waitForAll(
    listenForRednet,
    listenForKeyboard
)
