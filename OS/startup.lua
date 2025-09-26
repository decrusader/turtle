-- PP.lua
-- CoreLogic Presentatie Player - continuous loop, monitors, speakers, autosave

local stateFile = "session.dat"
local saveFile  = "pp_state.json"

-- =========================
-- Helper functies
-- =========================
local function saveState(state)
    local f = fs.open(saveFile, "w")
    f.write(textutils.serializeJSON(state))
    f.close()
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

-- =========================
-- Peripherals
-- =========================
local monitors = {}
local speakers = {}
for _, name in ipairs(peripheral.getNames()) do
    local t = peripheral.getType(name)
    if t == "monitor" then
        table.insert(monitors, peripheral.wrap(name))
    elseif t == "speaker" then
        table.insert(speakers, peripheral.wrap(name))
    end
end

local function playNotification()
    for _, spk in ipairs(speakers) do
        if spk then pcall(spk.playSound, "minecraft:note_block.pling") end
    end
end

-- =========================
-- Tekst weergave
-- =========================
local function splitText(text, width)
    local lines = {}
    local line = ""
    for word in text:gmatch("%S+") do
        if #line + #word + 1 <= width then
            if line == "" then
                line = word
            else
                line = line .. " " .. word
            end
        else
            table.insert(lines, line)
            line = word
        end
    end
    if line ~= "" then table.insert(lines, line) end
    return lines
end

local function showOnMonitor(mon, text)
    mon.clear()
    local w, h = mon.getSize()
    local lines = splitText(text, w)
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
    for _, mon in ipairs(monitors) do
        showOnMonitor(mon, text)
    end
end

-- =========================
-- j/n prompt
-- =========================
local function askYesNo(prompt)
    while true do
        term.write(prompt .. " (j/n): ")
        local ans = read()
        if ans then
            ans = ans:lower()
            if ans == "j" or ans == "y" then return true end
            if ans == "n" then return false end
        end
        print("Ongeldige invoer, typ j of n.")
    end
end

-- =========================
-- Laad of bouw slides
-- =========================
local state = loadState() or { slides = {}, current = 1, paused = false }

if #state.slides == 0 then
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("=== Presentatie Builder ===")
        print("Typ de tekst voor een dia, of 'klaar' om te stoppen.")
        term.write("Tekst: ")
        local text = read()
        if text == "klaar" then break end
        if text ~= "" then
            term.write("Duur (seconden): ")
            local dur = tonumber(read())
            if dur and dur > 0 then
                table.insert(state.slides, {text=text, time=dur})
                print("Dia toegevoegd! ("..text.." - "..dur.."s)")
                sleep(1)
            else
                print("Ongeldige tijd, probeer opnieuw.")
                sleep(1)
            end
        end
    end
    state.current = 1
    state.paused = false
    saveState(state)
end

if #state.slides == 0 then
    term.clear()
    term.setCursorPos(1,1)
    print("Geen dia's toegevoegd, afsluiten...")
    clearState()
    return
end

-- =========================
-- Pauze check bij resume
-- =========================
if state.paused then
    term.clear()
    term.setCursorPos(1,1)
    print("Presentatie gepauzeerd op dia " .. state.current)
    local resume = askYesNo("Wil je hervatten?")
    if not resume then state.current = 1 end
    state.paused = false
    saveState(state)
end

-- Countdown
term.clear()
term.setCursorPos(1,1)
print("Presentatie start over 2 seconden...")
sleep(2)

-- =========================
-- Main loop (continuous)
-- =========================
local totalSlides = #state.slides
local currentIndex = state.current

while true do
    local slide = state.slides[currentIndex]

    -- Sla huidige index meteen op
    state.current = currentIndex
    saveState(state)

    -- Terminal weergave
    term.clear()
    local w, h = term.getSize()
    local lines = splitText(slide.text, w)
    local startY = math.floor((h - #lines) / 2) + 1
    for j, line in ipairs(lines) do
        local x = math.floor((w - #line) / 2) + 1
        local y = startY + j - 1
        if y <= h then
            term.setCursorPos(x, y)
            term.write(line)
        end
    end

    -- Monitoren
    showOnMonitors(slide.text)

    -- Speaker notificatie
    playNotification()

    -- Start timer voor deze dia
    local timerId = os.startTimer(slide.time)

    -- Event loop tot timer afloopt of gebruiker pauzeert
    while true do
        local event, id = os.pullEventRaw()
        if event == "timer" and id == timerId then
            break -- ga door naar volgende dia
        elseif event == "terminate" or event == "key" or event == "mouse_click" then
            state.paused = true
            saveState(state)
            term.clear()
            term.setCursorPos(1,1)
            print("Presentatie gepauzeerd. Hervat na reboot!")
            return
        end
    end

    -- Volgende slide
    currentIndex = currentIndex + 1
    if currentIndex > totalSlides then currentIndex = 1 end
end
