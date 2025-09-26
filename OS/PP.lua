-- PP.lua
-- Presentatie Player met multi-line scaling per monitor

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

-- Tekst netjes splitsen op basis van breedte
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
        if current ~= "" then
            table.insert(lines, current)
        end
    end
    return lines
end

-- Toon tekst gecentreerd (werkt voor monitor én term)
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

-- Toon tekst op alle monitors
local function showOnMonitors(text)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            mon.setTextScale(1) -- schaal standaardiseren
            showCenteredText(mon, text)
        end
    end
end

-- Inputfase: verzamel slides
local slides = {}
while true do
    term.clear()
    term.setCursorPos(1,1)
    print("=== Presentatie Builder ===")
    print("Typ de tekst voor de dia, of 'klaar' om te stoppen.")
    term.write("Tekst: ")
    local text = read()

    if text == "klaar" then break end
    if text == "" then
        print("  Lege tekst is niet toegestaan!")
        sleep(1)
    else
        term.write("Duur (seconden): ")
        local duration = tonumber(read())
        if not duration or duration <= 0 then
            print("  Ongeldige tijd, probeer opnieuw.")
            sleep(1)
        else
            table.insert(slides, {text=text, time=duration})
            print(" Dia toegevoegd! ("..text.." - "..duration.."s)")
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

-- Countdown
term.clear()
term.setCursorPos(1,1)
print("Presentatie start over 2 seconden...")
sleep(2)

-- Functie om slides af te spelen
local function playSlides()
    for _, slide in ipairs(slides) do
        showCenteredText(term, slide.text)
        showOnMonitors(slide.text)
        sleep(slide.time)
    end
end

-- Zorg dat monitors altijd leeggemaakt worden bij einde
local function clearAll()
    term.clear()
    term.setCursorPos(1,1)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then mon.clear() end
    end
end

-- Parallel: presentatie + afbreken met key/muisklik
local function presenter()
    while true do
        playSlides()
    end
end

local function stopper()
    os.pullEvent("key")
end

local function mouseStopper()
    os.pullEvent("mouse_click")
end

parallel.waitForAny(presenter, stopper, mouseStopper)

-- Stop
clearAll()
print("Presentatie gestopt!")
