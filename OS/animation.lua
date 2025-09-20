-- animation.lua
-- CoreLogic Smooth Fade-in Animatie

local animation = {}

function animation.play()
    term.clear()
    term.setCursorPos(1,1)

    local w, h = term.getSize()
    local text = "CoreLogic"
    local centerX = math.floor((w - #text) / 2)
    local centerY = math.floor(h / 2)

    local fadeColors = {colors.black, colors.gray, colors.lightGray, colors.white}

    local function centerWrite(text, color)
        term.setTextColor(color)
        term.setCursorPos(centerX, centerY)
        term.write(text)
    end

    for i = 1, #fadeColors do
        for j = 1, 3 do
            term.clear()
            centerWrite(text, fadeColors[i])
            sleep(0.2)
        end
    end

    term.setTextColor(colors.white)

    term.clear()
    local finalText = "Welkom bij CoreLogic OS"
    local fx = math.floor((w - #finalText) / 2)
    term.setCursorPos(fx, centerY)
    print(finalText)
    sleep(2)

    term.clear()
    term.setCursorPos(1,1)
    print("CoreLogic OS is klaar voor gebruik!")
end

return animation
