-- startup.lua
-- CoreLogic OS startup met automatische download en mirrored animation

-- Functie: download een bestand en toon animatie (minimaal 2 sec)
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
        sleep(2)
    end
end

-- RAW GitHub links
local files = {
    { url = "https://raw.githubusercontent.com/<username>/<repo>/main/animation.lua", name = "animation.lua" },
    { url = "https://raw.githubusercontent.com/<username>/<repo>/main/PP.lua",        name = "PP.lua" }
}

-- Download ontbrekende bestanden
for _, file in ipairs(files) do
    if not fs.exists(file.name) then
        downloadFile(file.url, file.name)
    end
end

-- Zoek wired modem en aangesloten monitors
local modem = peripheral.find("modem")
local screens = {}
if modem then
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(screens, name)
        end
    end
end

-- Functie om mirrored output te sturen naar schermen
local function mirrorToScreens(msg)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            mon.clear()
            mon.setCursorPos(1,1)
            mon.write(msg)
        end
    end
end

-- === STARTUP SEQUENCE ===

-- 1) Speel animatie altijd af
mirrorToScreens("Starting Animation...")
local animation = dofile("animation.lua")
animation.play()

-- Klaar voor gebruik
term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS klaar voor gebruik!")
mirrorToScreens("CoreLogic OS klaar voor gebruik!")
