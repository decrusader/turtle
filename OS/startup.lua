-- startup.lua
-- CoreLogic OS startup met download-animatie (zonder laatste ".")

-- Functie: download een bestand en toon animatie
local function downloadFile(url, filename)
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading:")

    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        local f = fs.open(filename, "w")
        f.write(content)
        f.close()

        -- Animatie minimaal 2 seconden
        local startTime = os.clock()
        while os.clock() - startTime < 2 do
            term.setCursorPos(1,3)
            print(".  ") sleep(0.3)
            term.setCursorPos(1,3)
            print(".. ") sleep(0.3)
            term.setCursorPos(1,3)
            print("...") sleep(0.3)
        end
    else
        print("Fout: kon "..filename.." niet downloaden!")
    end
end

-- URL naar animation.lua (RAW GitHub link!)
local animationURL = "https://raw.githubusercontent.com/<username>/<repo>/main/animation.lua"

-- Als animation.lua niet bestaat, downloaden
if not fs.exists("animation.lua") then
    downloadFile(animationURL, "animation.lua")
end

-- Laad en speel animatie af
local animation = dofile("animation.lua")
animation.play()

-- Hier kan je OS starten, bv:
-- dofile("main.lua")
