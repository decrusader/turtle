-- startup.lua
-- Self-protecting CoreLogic startup

-- Functie voor eenvoudige checksum
local function checksum(str)
    local sum = 0
    for i = 1, #str do
        sum = sum + string.byte(str, i)
    end
    return sum
end

-- Lees eigen bestand
local f = fs.open("startup.lua", "r")
local content = f.readAll()
f.close()

-- Originele checksum van startup.lua
local originalChecksum = 29250  -- bereken dit eenmalig van jouw originele startup.lua

-- Controleer of startup.lua is gewijzigd
if checksum(content) ~= originalChecksum then
    term.clear()
    term.setCursorPos(1,1)
    print("Waarschuwing: startup.lua is gewijzigd!")
    print("Systeem wordt afgesloten ter bescherming.")
    sleep(5)
    term.clear()
    return
end

-- Laad en speel animatie af
local animation = dofile("animation.lua")
animation.play()

-- Hier kan je main OS starten
-- bijv: dofile("main.lua")
