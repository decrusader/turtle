-- CoreLogic Fade-in Animatie
term.clear()
term.setCursorPos(1,1)

-- Schermgrootte
local w, h = term.getSize()
local text = "CoreLogic"
local centerX = math.floor((w - #text) / 2)
local centerY = math.floor(h / 2)

-- Kleuren van donkergrijs naar wit (CC:Tweaked kleuren)
local colors = {
    colors.gray,
    colors.lightGray,
    colors.white
}

-- Functie om gecentreerde tekst te schrijven
local function centerWrite(text, color)
    term.setTextColor(color)
    term.setCursorPos(centerX, centerY)
    term.write(text)
end

-- Fade-in animatie
for _, color in ipairs(colors) do
    term.clear()
    centerWrite(text, color)
    sleep(0.5)
end

-- Zet kleur weer op wit
term.setTextColor(colors.white)

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
