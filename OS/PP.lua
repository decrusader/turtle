-- PP.lua
-- Presentatie Player met opslag + autoload + resume state

local SAVE_FILE = "slides.txt"
local SESSION_FILE = "session.dat"

-- Schrijf sessie
local f = fs.open(SESSION_FILE, "w")
f.writeLine("PP.lua")
f.close()

-- Zoek modem en monitors
local modem = peripheral.find("modem")
local screens = {}
if modem then
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(screens, name)
        end
    end
end

-- Tekst splitsen
local function splitText(text, width)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        local current = ""
        for word in line:gmatch("%S+") do
            if #current + #word + 1 > width then
                table.insert(lines, current)
                current = word
            else
                if current == "" then
                    current = word
                else
                    current = current .. " " .. word
                end
            end
        end
        if current ~= "" then table.insert(lines, current) end
    end
    return lines
end

-- Gecentreerde weergave
local function showCenteredText(target, text)
    target.clear()
    local w, h = target.getSize()
    local lines = splitText(text, w)
    local startY = math.floor((h - #lines) / 2) + 1
    for i, line in ipairs(lines) do
        local x = math.floor((w - #line) / 2) + 1
        local y = startY + i - 1
        if y <= h then
            target.setCursorPos(x, y)
            target.write(line)
        end
    end
end

-- Toon op monitors
local function showOnMonitors(text)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            mon.setTextScale(1)
            showCenteredText(mon, text)
        end
    end
end

-- Load slides van file
local function loadSlides()
    if not fs.exists(SAVE_FILE) then return {} end
    local f = fs.open(SAVE_FILE, "r")
    local content = f.readAll()
    f.close()

    local slides = {}
    for line in content:gmatch("[^\n]+") do
        local sep = line:find("|")
        if sep then
            local text = line:sub(1, sep - 1)
            local duration = tonumber(line:sub(sep + 1))
            if text and duration then
                table.insert(slides, {text=text, time=duration})
            end
        end
    end
    return slides
end

-- Save slides naar file
local function saveSlides(slides)
    local f = fs.open(SAVE_FILE, "w")
    for _, slide in ipairs(slides) do
        f.write(slide.text .. "|" .. slide.time .. "\n")
    end
    f.close()
end

-- Slides ophalen
local slides = loadSlides()

-- Indien geen slides → invoer vragen
if #slides == 0 then
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("=== Presentatie Builder ===")
        print("Typ de tekst voor de dia, of 'klaar' om te stoppen.")
        term.write("Tekst: ")
        local text = read()

        if text == "klaar" then break end
        if text == "" then
            print("Lege tekst is niet toegestaan!")
            sleep(1)
        else
            term.write("Duur (seconden): ")
            local duration = tonumber(read())
            if not duration or duration <= 0 then
                print("Ongeldige tijd, probeer opnieuw.")
                sleep(1)
            else
                table.insert(slides, {text=text, time=duration})
                print("Dia toegevoegd ("..text.." - "..duration.."s)")
                sleep(1)
            end
        end
    end
    if #slides == 0 then
        term.clear()
        term.setCursorPos(1,1)
        print("Geen dia's toegevoegd, afsluiten...")
        return
    end
    saveSlides(slides)
end

-- Countdown
term.clear()
term.setCursorPos(1,1)
print("Presentatie start over 2 seconden...")
sleep(2)

-- Speel slides af
local function playSlides()
    for _, slide in ipairs(slides) do
        showCenteredText(term, slide.text)
        showOnMonitors(slide.text)
        sleep(slide.time)
    end
end

-- Clear alles
local function clearAll()
    term.clear()
    term.setCursorPos(1,1)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then mon.clear() end
    end
end

-- Parallel processen
local function presenter()
    while true do playSlides() end
end
local function stopper() os.pullEvent("key") end
local function mouseStopper() os.pullEvent("mouse_click") end

parallel.waitForAny(presenter, stopper, mouseStopper)

clearAll()
print("Presentatie gestopt!")

-- Sessie verwijderen
if fs.exists(SESSION_FILE) then
    fs.delete(SESSION_FILE)
end
