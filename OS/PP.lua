-- PP.lua
-- Presentatie Player (loopt tot key of klik, mirrored op monitors)

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

-- Functie om tekst mirrored op alle monitors te tonen
local function showOnMonitors(text)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            mon.clear()
            local w, h = mon.getSize()
            local x = math.floor((w - #text) / 2)
            local y = math.floor(h / 2)
            mon.setCursorPos(x, y)
            mon.write(text)
        end
    end
end

-- Invoer van dia's
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
            print("Dia toegevoegd! ("..text.." - "..duration.."s)")
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

-- Functie om slides 1x te tonen
local function playSlides()
    for _, slide in ipairs(slides) do
        term.clear()
        local w, h = term.getSize()
        local x = math.floor((w - #slide.text) / 2)
        local y = math.floor(h / 2)
        term.setCursorPos(x, y)
        print(slide.text)

        -- Toon op alle monitors
        showOnMonitors(slide.text)

        sleep(slide.time)
    end
end

-- Blijf loopen tot key of klik
parallel.waitForAny(
    function()
        while true do
            playSlides()
        end
    end,
    function()
        os.pullEvent("key")        -- stop bij toets
    end,
    function()
        os.pullEvent("mouse_click") -- stop bij klik
    end
)

-- Stop
term.clear()
term.setCursorPos(1,1)
print("Presentatie gestopt!")

-- Clear monitors
for _, screenName in ipairs(screens) do
    local mon = peripheral.wrap(screenName)
    if mon then mon.clear() end
end
