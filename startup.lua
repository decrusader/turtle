-- Controleer of modem links zit
if not peripheral.getType("left") or peripheral.getType("left") ~= "modem" then
    print("Geen modem aan de linkerkant gevonden. Programma gestopt.")
    return
end

-- Open rednet via linker modem
rednet.open("left")
print("Rednet geopend via linker modem.")

local locked = false

-- Hoofdlus
while true do
    local id, msg = rednet.receive()

    if msg == "ping" then
        rednet.send(id, "pong")

    elseif msg == "stop" then
        locked = true
        print("Turtle is vergrendeld.")

    elseif msg == "go" then
        locked = false
        print("Turtle is geactiveerd.")

    elseif string.sub(msg, 1, 7) == "delete:" then
        local name = string.sub(msg, 8)
        if fs.exists(name) then
            fs.delete(name)
            print("Programma verwijderd: " .. name)
        end

    elseif string.sub(msg, 1, 8) == "program:" then
        local rest = string.sub(msg, 9)
        local name, code = rest:match("([^:]+):(.+)")
        if name and code then
            local file = fs.open(name, "w")
            file.write(code)
            file.close()
            print("Programma opgeslagen als: " .. name)
        end

    elseif not locked then
        print("Ontvangen onbekend commando (geen actie ondernomen).")
    else
        print("Turtle is gelockt. Geen acties toegestaan.")
    end
end
