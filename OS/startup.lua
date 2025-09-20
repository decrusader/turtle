-- startup.lua
-- CoreLogic OS startup met automatische bestand-download

-- Functie om een bestand te downloaden
local function downloadFile(url, filename)
    print("Downloading "..filename.."...")
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        local f = fs.open(filename, "w")
        f.write(content)
        f.close()
        print(filename.." downloaded successfully!")
    else
        print("Fout: kon "..filename.." niet downloaden!")
    end
end

-- Controleer of animation.lua bestaat, anders downloaden
if not fs.exists("animation.lua") then
    -- Vervang deze URL door de raw link van jouw animation.lua
    local animationURL = "https://github.com/decrusader/turtle/blob/main/OS/animation.lua"
    downloadFile(animationURL, "animation.lua")
end

-- Laad en speel animatie af
local animation = dofile("animation.lua")
animation.play()

-- Hier kan je je eigen OS starten, bv:
-- dofile("main.lua")
