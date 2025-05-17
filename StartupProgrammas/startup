local programs = {
    {name = "Master", url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/StartupProgrammas/MasterComputer/master.lua?token=GHSAT0AAAAAADCDTGAPVY6G7X4ELAHVLLJK2BITLSA"},
    {name = "Music", url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/music.lua?token=GHSAT0AAAAAADCDTGAOYB634IA6JB6HWH7M2BITM7Q"},
    {name = "Debug Status Editor", url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/StartupProgrammas/MasterComputer/debug_status.lua?token=GHSAT0AAAAAADCDTGAPIRUGXSGXPRF3Z4FO2BITJVQ"} -- <- Replace with your real raw URL
}
 
-- === SETUP ===
local savedir = "/programs"
local statusFile = savedir .. "/status.json"
 
if not fs.exists(savedir) then fs.makeDir(savedir) end
if not fs.exists(statusFile) then
    local f = fs.open(statusFile, "w")
    f.write(textutils.serializeJSON({}))
    f.close()
end
 
local function loadStatus()
    local f = fs.open(statusFile, "r")
    local data = f.readAll()
    f.close()
    return textutils.unserializeJSON(data) or {}
end
 
local function saveStatus(data)
    local f = fs.open(statusFile, "w")
    f.write(textutils.serializeJSON(data))
    f.close()
end
 
local statusData = loadStatus()
local termW, termH = term.getSize()
local scrollOffset = 0
local selectedIndex = 1
local displayCount = termH - 2
local isTouch = term.isColor()
 
-- === UTILS ===
local function readFile(path)
    if not fs.exists(path) then return nil end
    local f = fs.open(path, "r")
    local data = f.readAll()
    f.close()
    return data
end
 
-- === ANIMATION ===
local function loadingAnimation(duration)
    local startTime = os.clock()
    local dotCount = 0
    while os.clock() - startTime < duration do
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(math.floor(termW/2 - 7), math.floor(termH/2))
        local dots = string.rep(".", dotCount)
        term.write("Loading" .. dots)
        dotCount = (dotCount + 1) % 4
        sleep(0.5)
    end
    term.clear()
end
 
-- === UI DRAW ===
local function drawUI()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
 
    -- Title
    local title = "== Welkom to Byte v1.0 =="
    local titleX = math.floor((termW - #title) / 2) + 1
    term.setCursorPos(titleX, 1)
    term.setTextColor(colors.yellow)
    term.write(title)
    term.setTextColor(colors.white)
 
    for i = 1, displayCount do
        local idx = i + scrollOffset
        local program = programs[idx]
        if program then
            local status = statusData[program.name] or "Unknown"
            local prefix = (idx == selectedIndex) and "> " or "  "
            local lineText = prefix .. program.name .. " [" .. status .. "]"
            local x = math.floor((termW - #lineText) / 2) + 1
            term.setCursorPos(x, i + 1)
            if idx == selectedIndex then
                term.setTextColor(colors.green)
                term.write(lineText)
                term.setTextColor(colors.white)
            else
                term.write(lineText)
            end
        else
            term.setCursorPos(1, i + 1)
            term.write(string.rep(" ", termW))
        end
    end
end
 
-- === RUN PROGRAM ===
local function runProgram(index)
    local program = programs[index]
    local filename = savedir .. "/" .. program.name:gsub(" ", "_") .. ".lua"
    print("\nDownloading " .. program.name .. "...")
 
    local success, res = pcall(http.get, program.url)
    if not success or not res then
        print("Download failed!")
        statusData[program.name] = "Download Failed"
        saveStatus(statusData)
        sleep(2)
        return
    end
 
    local newContent = res.readAll()
    res.close()
 
    if not newContent or #newContent == 0 then
        print("Empty or invalid file.")
        statusData[program.name] = "Empty File"
        saveStatus(statusData)
        sleep(2)
        return
    end
 
    local currentContent = readFile(filename)
    if currentContent ~= newContent then
        local f = fs.open(filename, "w")
        f.write(newContent)
        f.close()
        print("Successfully downloaded.")
        statusData[program.name] = "Updated"
    else
        print("No update needed.")
        statusData[program.name] = "Up to Date"
    end
 
    saveStatus(statusData)
    sleep(1)
    shell.run(filename, statusFile)
end
 
-- === TOUCH SUPPORT ===
local function handleTouch(x, y)
    local relativeY = y - 1
    local index = scrollOffset + relativeY
    if index >= 1 and index <= #programs then
        selectedIndex = index
        runProgram(index)
    end
end
 
-- === MAIN LOOP ===
loadingAnimation(2)
 
while true do
    drawUI()
    local event, p1, p2, p3 = os.pullEvent()
 
    if event == "key" then
        if p1 == keys.up and selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
            if selectedIndex < scrollOffset + 1 then
                scrollOffset = scrollOffset - 1
            end
        elseif p1 == keys.down and selectedIndex < #programs then
            selectedIndex = selectedIndex + 1
            if selectedIndex > scrollOffset + displayCount then
                scrollOffset = scrollOffset + 1
            end
        elseif p1 == keys.enter then
            runProgram(selectedIndex)
        end
 
    elseif event == "mouse_click" and isTouch then
        handleTouch(p2, p3)
 
    elseif event == "mouse_scroll" then
        if p1 == 1 and scrollOffset < #programs - displayCount then
            scrollOffset = scrollOffset + 1
        elseif p1 == -1 and scrollOffset > 0 then
            scrollOffset = scrollOffset - 1
        end
    end
end
