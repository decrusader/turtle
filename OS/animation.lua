-- animation.lua
-- CoreLogic Smooth Fade-in Animatie (losstaand bestand)

local animation = {}

function animation.play()
    term.clear()
    term.setCursorPos(1,1)

    -- Schermgrootte
    local w, h = term.getSize()
    local text = "CoreLogic"
    local centerX = math.floor((w - #text) / 2)
    local centerY = math.floor(h / 2)

    -- Kleuren van donker naar licht (meerdere stappen voor smooth effect)
    local fadeColors = {
        colors.black,
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

    -- Smooth fade-in animatie
    for i = 1, #fadeColors do
        for j = 1, 3 do
            term.clear()
            centerWrite(text, fadeColors[i])
            sleep(0.2)
        end
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
end

return animation
