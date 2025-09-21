-- startup.lua
-- CoreLogic OS startup met automatische her-download van alle bestanden

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

-- Download altijd opnieuw
for _, file in ipairs(files) do
    downloadFile(file.url, file.name)
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

-- Functie om monitors te clearen
local function clearScreens()
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            mon.clear()
        end
    end
end

-- === STARTUP SEQUENCE ===

-- 1) Speel animatie altijd af
mirrorToScreens("Starting Animation...")
local animation = dofile("animation.lua")
animation.play()

-- 2) Clear monitors zodat later programma's hun eigen output kunnen tonen
clearScreens()

-- 3) Terminal klaar voor gebruik
term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS klaar voor gebruik!")
