-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")

local locked = false

-- Hoofdlus
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
                local success, err = pcall(function()
                    shell.run(name)
                end)
                if not success then
                    print("Fout bij uitvoeren van " .. name .. ": " .. tostring(err))
                end
            end
        end

    elseif not locked then
        -- Probeer elk ander bericht uit te voeren als shell commando
        local success, err = pcall(function()
            shell.run(msg)
        end)
        if not success then
            print("Fout bij uitvoeren commando: " .. tostring(err))
        end
    end
end
