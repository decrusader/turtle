-- CoreLogic Pulsing Animatie
term.clear()
term.setCursorPos(1,1)

-- Schermgrootte ophalen
local w, h = term.getSize()
local text = "CoreLogic"
local centerY = math.floor(h / 2)
local centerX = math.floor((w - #text) / 2)

-- Functie om tekst in het midden te schrijven
local function centerWrite(text)
    term.setCursorPos(centerX, centerY)
    term.write(text)
end

-- Puls animatie: tekst verschijnt en verdwijnt meerdere keren
for i = 1, 6 do
    term.clear()
    if i % 2 == 1 then
        centerWrite(text)
    end
    sleep(0.4)
end

-- Eindbericht
term.clear()
local finalText = "Welkom bij CoreLogic OS"
local fx = math.floor((w - #finalText) / 2)
term.setCursorPos(fx, centerY)
print(finalText)
sleep(2)

-- Klaar voor gebruik
term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS is klaar voor gebruik!")
