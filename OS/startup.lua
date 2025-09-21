-- startup.lua
-- CoreLogic OS startup met automatische download van meerdere bestanden

-- Functie: download een bestand en toon animatie (minimaal 2 sec met . .. ...)
local function downloadFile(url, filename)
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading: " .. filename)

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

-- URLs naar bestanden (vervang door jouw GitHub RAW links!)
local files = {
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/animation.lua", name = "animation.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/PP.lua",        name = "PP.lua" }
}

-- Download ontbrekende bestanden
for _, file in ipairs(files) do
    if not fs.exists(file.name) then
        downloadFile(file.url, file.name)
    end
end

-- Laad en speel animatie af
local animation = dofile("animation.lua")
animation.play()

-- Hier kan je OS starten, bv:
-- dofile("main.lua")
