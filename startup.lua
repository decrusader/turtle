-- startup.lua
-- CoreLogic login shrink-animatie voor CC:Tweaked

-- Maak scherm schoon
term.clear()
term.setCursorPos(1,1)

-- Schermgrootte ophalen
local w, h = term.getSize()

-- Frames voor de animatie
local frames = {
    "CoreLogic",
    "CorLogi",
    "CoLog",
    "CLo",
    "CL"
}

-- Functie om tekst in het midden te tekenen
local function centerWrite(text, y)
    local x = math.floor((w - #text) / 2)
    term.setCursorPos(x, y)
    term.write(text)
end

-- Animatie afspelen
for _, text in ipairs(frames) do
    term.clear()
    centerWrite(text, math.floor(h / 2))
    sleep(0.5)
end

-- Eindscherm tonen
sleep(0.5)
term.clear()
local final = "Welkom bij CoreLogic OS"
centerWrite(final, math.floor(h / 2))
sleep(2)

-- Hier kan je je eigen "main menu" of programma starten
term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS is klaar voor gebruik!")
