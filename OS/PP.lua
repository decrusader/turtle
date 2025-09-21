-- PP.lua
-- Presentatie Player met geschaalde tekst voor kleine schermen

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

-- Functie: splits lange tekst in meerdere regels
local function splitText(text, width)
    local lines = {}
    local start = 1
    while start <= #text do
        local chunk = text:sub(start, start + width - 1)
        table.insert(lines, chunk)
        start = start + width
    end
    return lines
end

-- Functie: schaal tekst voor monitoren
local function scaleTextForMonitor(mon, text)
    local w, h = mon.getSize()
    -- Als tekst te breed is, probeer in meerdere regels
    local lines = splitText(text, w)
    -- Als er nog steeds meer lijnen zijn dan hoogtescherm, gebruik verkorte weergave
    if #lines > h then
        local maxLines = h
        lines = {}
        for i = 1, maxLines do
            if i == maxLines then
                lines[i] = string.rep(".", w) -- placeholder voor te lange tekst
            else
                lines[i] = text:sub((i-1)*w +1, i*w)
            end
        end
    end
    return lines
end

-- Toon tekst op een monitor
local function showOnMonitor(mon, text)
    mon.clear()
    local w, h = mon.getSize()
    local lines = scaleTextForMonitor(mon, text)
    local startY = math.floor((h - #lines) / 2) + 1
    for i, line in ipairs(lines) do
        local x = math.floor((w - #line) / 2) + 1
        local y = startY + i - 1
        if y <= h then
            mon.setCursorPos(x, y)
            mon.write(line)
        end
    end
end

-- Toon tekst op alle monitors
local function showOnMonitors(text)
    for _, screenName in ipairs(screens) do
        local mon = peripheral.wrap(screenName)
        if mon then
            showOnMonitor(mon, text)
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
        -- Lokaal scherm
        local w, h = term.getSize()
        local lines = scaleTextForMonitor({getSize=function() return w,h end, setCursorPos=function() end, write=function() end}, slide.text)
        local startY = math.floor((h - #lines) / 2) + 1
        for i, line in ipairs(lines) do
            local x = math.floor((w - #line) / 2) + 1
            local y = startY + i - 1
            if y <= h then
                term.setCursorPos(x, y)
                term.write(line)
            end
        end

        -- Alle monitors
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
    function() os.pullEvent("key") end,
    function() os.pullEvent("mouse_click") end
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
