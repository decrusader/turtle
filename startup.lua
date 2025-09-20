-- CoreLogic Login Animatie
term.clear()
term.setCursorPos(1,1)

local w, h = term.getSize()
local text = "CoreLogic"
local x = math.floor((w - #text) / 2)
local y = math.floor(h / 2)

-- Simpele typewriter animatie
term.setCursorPos(x, y)
for i = 1, #text do
    term.write(text:sub(i,i))
    sleep(0.1)
end

sleep(0.5)

-- Extra animatie: pulserende blokjes
for i = 1, 3 do
    term.setCursorPos(x + #text + 1, y)
    term.write(".")
    sleep(0.2)
    term.setCursorPos(x + #text + 2, y)
    term.write(".")
    sleep(0.2)
    term.setCursorPos(x + #text + 3, y)
    term.write(".")
    sleep(0.2)

    -- wissen
    term.setCursorPos(x + #text + 1, y)
    term.write("   ")
end

sleep(0.5)

-- Klaar bericht
term.setCursorPos(x, y + 2)
print("Login succesvol!")
sleep(1.5)

term.clear()
term.setCursorPos(1,1)
print("Welkom bij CoreLogic OS")

