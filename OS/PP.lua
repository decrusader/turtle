-- PP.lua
-- Presentatie Player met autosave + resume

local stateFile = "session.dat"
local saveFile  = "pp_state.json"

-- JSON helpers (CC:Tweaked heeft textutils.serializeJSON)
local function saveState(data)
    local f = fs.open(saveFile, "w")
    f.write(textutils.serializeJSON(data))
    f.close()
    -- schrijf ook naar session.dat zodat startup weet wat te openen
    local s = fs.open(stateFile, "w")
    s.writeLine("PP.lua")
    s.close()
end

local function loadState()
    if not fs.exists(saveFile) then return nil end
    local f = fs.open(saveFile, "r")
    local content = f.readAll()
    f.close()
    return textutils.unserializeJSON(content)
end

local function clearState()
    if fs.exists(saveFile) then fs.delete(saveFile) end
    if fs.exists(stateFile) then fs.delete(stateFile) end
end

-- Zoek monitors
local modem = peripheral.find("modem")
local screens = {}
if modem then
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(screens, name)
        end
    end
end

-- Tekstschalen
local function splitText(text, width)
    local lines, start = {}, 1
    while start <= #text do
        local chunk = text:sub(start, start + width - 1)
        table.insert(lines, chunk)
        start = start + width
    end
    return lines
end

local function scaleTextForMonitor(mon, text)
    local w, h = mon.getSize()
    local lines = splitText(text, w)
    if #lines > h then
        local maxLines = h
        lines = {}
        for i = 1, maxLines do
            if i == maxLines then
                lines[i] = string.rep(".", w)
            else
                lines[i] = text:sub((i-1)*w +1, i*w)
            end
        end
    end
    return lines
end

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

local function showOnMonitors(text)
    for _, name in ipairs(screens) do
        local mon = peripheral.wrap(name)
        if mon then showOnMonitor(mon, text) end
    end
end

-- Laad bestaande state of nieuw
local state = loadState() or { slides = {}, current = 1 }

-- Als geen slides → vraag input
if #state.slides == 0 then
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
                table.insert(state.slides, {text=text, time=duration})
                print("Dia toegevoegd! ("..text.." - "..duration.."s)")
                sleep(1)
            end
        end
    end
    state.current = 1
    saveState(state)
end

if #state.slides == 0 then
    term.clear()
    term.setCursorPos(1,1)
    print("Geen dia's toegevoegd, afsluiten...")
    clearState()
    return
end

-- Countdown
term.clear()
term.setCursorPos(1,1)
print("Presentatie start/resume over 2 seconden...")
sleep(2)

-- Slide loop
local function playSlides()
    while state.current <= #state.slides do
        local slide = state.slides[state.current]

        -- Lokale scherm
        term.clear()
        local w, h = term.getSize()
        local lines = splitText(slide.text, w)
        local startY = math.floor((h - #lines) / 2) + 1
        for i, line in ipairs(lines) do
            local x = math.floor((w - #line) / 2) + 1
            local y = startY + i - 1
            if y <= h then
                term.setCursorPos(x, y)
                term.write(line)
            end
        end

        -- Monitors
        showOnMonitors(slide.text)

        local startTime = os.clock()
        while os.clock() - startTime < slide.time do
            -- tijdens afspelen event checken
            local ev = {os.pullEventRaw()}
            if ev[1] == "terminate" or ev[1] == "key" or ev[1] == "mouse_click" then
                saveState(state) -- huidige state opslaan
                term.clear()
                term.setCursorPos(1,1)
                print("Presentatie gepauzeerd. Hervat na reboot!")
                return
            end
        end

        -- Volgende slide
        state.current = state.current + 1
        saveState(state)
    end

    -- Klaar -> opschonen
    term.clear()
    term.setCursorPos(1,1)
    print("Presentatie voltooid!")
    clearState()
    for _, name in ipairs(screens) do
        local mon = peripheral.wrap(name)
        if mon then mon.clear() end
    end
end

playSlides()
