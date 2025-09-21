-- PP.lua
-- Presentatie Player met autosave, resume, pauze en speaker notificatie

local stateFile = "session.dat"
local saveFile  = "pp_state.json"

-- JSON helpers
local function saveState(data)
    local f = fs.open(saveFile, "w")
    f.write(textutils.serializeJSON(data))
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

-- Zoek monitors
local monitors = {}
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        table.insert(monitors, peripheral.wrap(name))
    end
end

-- Zoek speakers
local speakers = {}
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "speaker" then
        table.insert(speakers, peripheral.wrap(name))
    end
end

local function playNotification()
    for _, spk in ipairs(speakers) do
        if spk then
            spk.playSound("minecraft:note_block.pling")
        end
    end
end

-- Helpers voor tekst
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
    for _, mon in ipairs(monitors) do
        showOnMonitor(mon, text)
    end
end

-- Veilige j/n prompt
local function askYesNo(prompt)
    while true do
        term.write(prompt .. " (j/n): ")
        local answer = read()
        if answer then
            answer = answer:lower()
            if answer == "j" then return true end
            if answer == "n" then return false end
        end
        print("Ongeldige invoer, typ j of n.")
    end
end

-- Laad state
local state = loadState() or { slides = {}, current = 1, paused = false }
local slideShown = {} -- houdt bij welke slides al notificatie kregen

-- Dia toevoegen als er nog geen slides zijn
if #state.slides == 0 then
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("=== Presentatie Builder ===")
        print("Typ de tekst voor de dia, of 'klaar' om te stoppen.")
        term.write("Tekst: ")
        local text = read()
        if text == "klaar" then break end
        if text ~= "" then
            term.write("Duur (seconden): ")
            local duration = tonumber(read())
            if duration and duration > 0 then
                table.insert(state.slides, {text=text, time=duration})
                print("Dia toegevoegd! ("..text.." - "..duration.."s)")
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

-- Check pauze
if state.paused then
    term.clear()
    term.setCursorPos(1,1)
    print("Presentatie was gepauzeerd op dia " .. state.current)
    local resume = askYesNo("Wil je hervatten?")
    if not resume then
        state.current = 1
    end
    state.paused = false
    saveState(state)
end

-- Countdown
term.clear()
term.setCursorPos(1,1)
print("Presentatie start/resume over 2 seconden...")
sleep(2)

-- Slide loop
while state.current <= #state.slides do
    local slide = state.slides[state.current]

    -- Notification bij nieuwe slide
    if not slideShown[state.current] then
        slideShown[state.current] = true
        playNotification()
    end

    -- Lokale schermen
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

    -- Slide timer met events (fixed)
    local timer = os.startTimer(slide.time)
    while true do
        local event, id = os.pullEvent()
        if event == "timer" and id == timer then
            break -- dia klaar
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
    state.current = state.current + 1
    saveState(state)
end

-- Klaar
term.clear()
term.setCursorPos(1,1)
print("Presentatie voltooid!")
clearState()
for _, mon in ipairs(monitors) do mon.clear() end
